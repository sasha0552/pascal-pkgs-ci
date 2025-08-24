import torch
import math
from typing import Optional, Tuple
from .flash_attention import flash_attn_func
import torch.cuda

def _flash_attn_forward(*args, **kwargs):
    # Adapt args to match our flash_attn_func signature
    q, k, v = args[0], args[1], args[2]
    dropout_p = kwargs.get('dropout_p', 0.0)
    softmax_scale = kwargs.get('softmax_scale', None)
    causal = kwargs.get('causal', False)
    window_size = kwargs.get('window_size', (-1, -1))
    return_attn_probs = kwargs.get('return_attn_probs', False)
    
    # Use our optimized attention function
    with torch.cuda.amp.autocast():
        return flash_attn_func(
            q, k, v,
            dropout_p=dropout_p,
            softmax_scale=softmax_scale,
            causal=causal,
            window_size=window_size,
            return_attn_probs=return_attn_probs
        )

def _flash_attn_backward(*args, **kwargs):
    # For Pascal GPUs, use gradient checkpointing for memory efficiency
    grad_out, q, k, v, out = args[0], args[1], args[2], args[3], args[4]
    
    # Clone inputs for gradient computation
    q = q.clone().detach().requires_grad_(True)
    k = k.clone().detach().requires_grad_(True)
    v = v.clone().detach().requires_grad_(True)
    
    # Recompute forward pass with AMP disabled for gradient calculation
    with torch.cuda.amp.autocast(False):
        output = flash_attn_func(q, k, v, **kwargs)
    
    # Compute gradients
    grad_q, grad_k, grad_v = torch.autograd.grad(
        outputs=output,
        inputs=(q, k, v),
        grad_outputs=grad_out
    )
    
    return grad_q, grad_k, grad_v

def flash_attn_unpadded_func(
    q: torch.Tensor,
    k: torch.Tensor,
    v: torch.Tensor,
    cu_seqlens_q: torch.Tensor,
    cu_seqlens_k: torch.Tensor,
    max_seqlen_q: int,
    max_seqlen_k: int,
    dropout_p: float,
    softmax_scale: Optional[float] = None,
    causal: bool = False,
    return_attn_probs: bool = False,
    **kwargs
) -> torch.Tensor:
    batch_size = len(cu_seqlens_q) - 1
    num_heads = q.shape[1]
    head_dim = q.shape[2]

    # Preallocate output
    output_unpadded = torch.zeros_like(q)

    # Vectorized batch processing
    for i in range(batch_size):
        q_start = cu_seqlens_q[i]
        q_end = cu_seqlens_q[i+1]
        k_start = cu_seqlens_k[i]
        k_end = cu_seqlens_k[i+1]

        q_batch = q[q_start:q_end]
        k_batch = k[k_start:k_end]
        v_batch = v[k_start:k_end]

        # Use our optimized attention function
        with torch.cuda.amp.autocast():
            result = flash_attn_func(
                q_batch.unsqueeze(0).half(), k_batch.unsqueeze(0).half(), v_batch.unsqueeze(0).half(),
                dropout_p=dropout_p,
                softmax_scale=softmax_scale,
                causal=causal,
                return_attn_probs=return_attn_probs,
                **kwargs
            )

        # Copy result back to output
        output_unpadded[q_start:q_end] = result[0, :q_end - q_start]

    return output_unpadded
