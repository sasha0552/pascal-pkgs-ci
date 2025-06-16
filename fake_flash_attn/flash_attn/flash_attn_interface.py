import torch  # IMPORT ADDED HERE
import math
from typing import Optional, Tuple
from .flash_attention import flash_attn_func

def _flash_attn_forward(*args, **kwargs):
    raise NotImplementedError("_flash_attn_forward is not implemented in fake_flash_attn")

def _flash_attn_backward(*args, **kwargs):
    raise NotImplementedError("_flash_attn_backward is not implemented in fake_flash_attn")

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
    # Convert unpadded to padded format
    batch_size = len(cu_seqlens_q) - 1
    num_heads = q.shape[1]
    head_dim = q.shape[2]
    
    q_padded = torch.zeros((batch_size, max_seqlen_q, num_heads, head_dim), device=q.device, dtype=q.dtype)
    k_padded = torch.zeros((batch_size, max_seqlen_k, num_heads, head_dim), device=k.device, dtype=k.dtype)
    v_padded = torch.zeros((batch_size, max_seqlen_k, num_heads, head_dim), device=v.device, dtype=v.dtype)
    
    for i in range(batch_size):
        q_start = cu_seqlens_q[i]
        q_end = cu_seqlens_q[i+1]
        k_start = cu_seqlens_k[i]
        k_end = cu_seqlens_k[i+1]
        
        q_padded[i, :q_end-q_start] = q[q_start:q_end]
        k_padded[i, :k_end-k_start] = k[k_start:k_end]
        v_padded[i, :k_end-k_start] = v[k_start:k_end]
    
    # Use our vanilla attention function
    result = flash_attn_func(
        q_padded, k_padded, v_padded,
        dropout_p=dropout_p,
        softmax_scale=softmax_scale,
        causal=causal,
        return_attn_probs=return_attn_probs,
        **kwargs
    )
    
    # Convert back to unpadded format if needed
    if return_attn_probs:
        output, attn_probs = result
        output_unpadded = torch.zeros_like(q)
        for i in range(batch_size):
            q_start = cu_seqlens_q[i]
            q_end = cu_seqlens_q[i+1]
            output_unpadded[q_start:q_end] = output[i, :q_end-q_start]
        return output_unpadded, None, attn_probs
    else:
        output_unpadded = torch.zeros_like(q)
        for i in range(batch_size):
            q_start = cu_seqlens_q[i]
            q_end = cu_seqlens_q[i+1]
            output_unpadded[q_start:q_end] = result[i, :q_end-q_start]
        return output_unpadded

def _flash_attn_varlen_forward(
    q: torch.Tensor,
    k: torch.Tensor,
    v: torch.Tensor,
    cu_seqlens_q: torch.Tensor,
    cu_seqlens_k: torch.Tensor,
    max_seqlen_q: int,
    max_seqlen_k: int,
    dropout_p: float,
    softmax_scale: float,
    causal: bool,
    window_size: Tuple[int, int],
    alibi_slopes: Optional[torch.Tensor],
    deterministic: bool,
    return_attn_probs: bool,
    **kwargs
) -> torch.Tensor:
    # For now, use our unpadded implementation
    print("Warning: Using fallback implementation for _flash_attn_varlen_forward")
    return flash_attn_unpadded_func(
        q, k, v,
        cu_seqlens_q, cu_seqlens_k,
        max_seqlen_q, max_seqlen_k,
        dropout_p=dropout_p,
        softmax_scale=softmax_scale,
        causal=causal,
        return_attn_probs=return_attn_probs,
        **kwargs
    )

def _flash_attn_varlen_backward(*args, **kwargs):
    raise NotImplementedError("_flash_attn_varlen_backward is not implemented in fake_flash_attn")

def flash_attn_varlen_func(
    q: torch.Tensor,
    k: torch.Tensor,
    v: torch.Tensor,
    cu_seqlens_q: torch.Tensor,
    cu_seqlens_k: torch.Tensor,
    max_seqlen_q: int,
    max_seqlen_k: int,
    dropout_p: float = 0.0,
    softmax_scale: Optional[float] = None,
    causal: bool = False,
    window_size: Tuple[int, int] = (-1, -1),
    alibi_slopes: Optional[torch.Tensor] = None,
    deterministic: bool = False,
    return_attn_probs: bool = False,
    **kwargs
) -> torch.Tensor:
    # For now, use our unpadded implementation
    print("Warning: Using fallback implementation for flash_attn_varlen_func")
    return flash_attn_unpadded_func(
        q, k, v,
        cu_seqlens_q, cu_seqlens_k,
        max_seqlen_q, max_seqlen_k,
        dropout_p=dropout_p,
        softmax_scale=softmax_scale,
        causal=causal,
        return_attn_probs=return_attn_probs,
        **kwargs
    )
