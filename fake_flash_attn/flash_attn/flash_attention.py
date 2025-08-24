import torch
import math
from typing import Optional, Tuple
from torch.nn import functional as F
from torch.utils.checkpoint import checkpoint
import torch.cuda

def flash_attn_func(
    q: torch.Tensor,
    k: torch.Tensor,
    v: torch.Tensor,
    dropout_p: float = 0.0,
    softmax_scale: Optional[float] = None,
    causal: bool = False,
    window_size: Tuple[int, int] = (-1, -1),
    return_attn_probs: bool = False,
    **kwargs
) -> torch.Tensor:
    # Ignore unimplemented arguments
    if window_size != (-1, -1):
        print("Warning: window_size not implemented - using full attention")

    batch_size, q_seqlen, num_heads, head_dim = q.shape
    k_seqlen = k.size(1)

    # Ensure contiguous memory layout after permutation
    q = q.permute(0, 2, 1, 3).contiguous()
    k = k.permute(0, 2, 1, 3).contiguous()
    v = v.permute(0, 2, 1, 3).contiguous()

    output = torch.zeros_like(q)

    # Use math.sqrt with float conversion for better numerical stability
    scale = softmax_scale if softmax_scale is not None else (1.0 / math.sqrt(float(head_dim)))

    # Use PyTorch's built-in scaled_dot_product_attention for CUDA acceleration
    with torch.cuda.amp.autocast():
        # F.scaled_dot_product_attention handles causal masking, softmax, dropout, and V multiplication
        output = F.scaled_dot_product_attention(
            q,
            k,
            v,
            attn_mask=None,
            dropout_p=dropout_p if dropout_p > 0.0 and torch.is_grad_enabled() else 0.0,
            is_causal=causal,
        )

    # Rearrange back to [batch, seqlen, heads, dim]
    output = output.permute(0, 2, 1, 3)

    if return_attn_probs:
        print("Warning: return_attn_probs=True not supported with chunked attention")
        return output, None
    return output
