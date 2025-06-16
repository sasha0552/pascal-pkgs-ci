import torch
import math
from typing import Optional, Tuple
from torch.nn import functional as F

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
    
    # Determine if we can use optimized kernels
    use_optimized = False
    if hasattr(F, 'scaled_dot_product_attention'):
        # Check GPU compatibility
        major, minor = torch.cuda.get_device_capability()
        compute_capability = major * 10 + minor
        
        # Check dtype compatibility
        dtype_supported = q.dtype in [torch.float16, torch.float32]
        
        # Only use optimized path for supported GPUs and dtypes
        if compute_capability >= 80 and dtype_supported and q_seqlen <= 2048 and k_seqlen <= 2048:
            use_optimized = True
    
    if use_optimized:
        # Rearrange to [batch, heads, seqlen, dim]
        q_t = q.transpose(1, 2)
        k_t = k.transpose(1, 2)
        v_t = v.transpose(1, 2)
        
        # Compute scale value
        scale_val = softmax_scale if softmax_scale is not None else (1.0 / math.sqrt(head_dim))
        
        # Use the most efficient available kernel
        with torch.backends.cuda.sdp_kernel(enable_flash=True, enable_mem_efficient=True, enable_math=True):
            context = F.scaled_dot_product_attention(
                q_t, k_t, v_t,
                attn_mask=None,
                dropout_p=dropout_p if torch.is_grad_enabled() else 0.0,
                is_causal=causal,
                scale=scale_val
            )
        
        # Rearrange back to [batch, seqlen, heads, dim]
        context = context.transpose(1, 2).contiguous()
        
        if return_attn_probs:
            print("Warning: return_attn_probs=True not supported with optimized attention")
            return context, None
        return context
    
    # For unsupported configurations, use memory-efficient chunked attention
    # Auto-tune chunk sizes based on available memory
    if torch.cuda.is_available():
        free_mem, _ = torch.cuda.mem_get_info()
        available_mem = free_mem * 0.5  # Use 50% of free memory
        # Calculate chunk sizes based on memory requirements
        divisor = batch_size * num_heads * head_dim * 4
        if divisor > 0:
            q_chunk_size = max(8, min(64, int((available_mem / divisor) ** 0.5)))
            k_chunk_size = max(64, min(512, q_chunk_size * 8))
        else:
            # Fallback to safe values
            q_chunk_size = 16
            k_chunk_size = 128
    else:
        # CPU fallback
        q_chunk_size = 16
        k_chunk_size = 128
    
    # Rearrange to [batch, heads, seqlen, dim]
    q = q.transpose(1, 2).contiguous()
    k = k.transpose(1, 2).contiguous()
    v = v.transpose(1, 2).contiguous()
    
    output = torch.zeros_like(q)
    scale_val = softmax_scale if softmax_scale is not None else (1.0 / math.sqrt(head_dim))
    
    # Precompute causal mask if needed
    if causal:
        full_mask = torch.triu(
            torch.full((q_seqlen, k_seqlen), float('-inf'), device=q.device),
            diagonal=1
        )
    
    # Process query chunks
    for q_start in range(0, q_seqlen, q_chunk_size):
        q_end = min(q_start + q_chunk_size, q_seqlen)
        q_chunk = q[:, :, q_start:q_end]
        
        # Initialize output for this chunk
        chunk_output = torch.zeros_like(q_chunk)
        
        # Process key chunks
        for k_start in range(0, k_seqlen, k_chunk_size):
            k_end = min(k_start + k_chunk_size, k_seqlen)
            k_chunk = k[:, :, k_start:k_end]
            v_chunk = v[:, :, k_start:k_end]
            
            # Compute scores for this chunk
            scores = torch.matmul(q_chunk, k_chunk.transpose(-1, -2)) * scale_val
            
            # Apply causal mask if needed
            if causal:
                # Use precomputed mask for the current chunks
                mask_chunk = full_mask[q_start:q_end, k_start:k_end]
                scores = scores + mask_chunk.unsqueeze(0).unsqueeze(0)
            
            # Compute attention weights for this chunk
            attn_weights = torch.softmax(scores, dim=-1)
            
            if dropout_p > 0.0 and torch.is_grad_enabled():
                attn_weights = F.dropout(attn_weights, p=dropout_p)
            
            # Compute context chunk
            context_chunk = torch.matmul(attn_weights, v_chunk)
            chunk_output = chunk_output + context_chunk
        
        output[:, :, q_start:q_end] = chunk_output
    
    # Rearrange back to [batch, seqlen, heads, dim]
    output = output.transpose(1, 2).contiguous()
    
    if return_attn_probs:
        print("Warning: return_attn_probs=True not supported with chunked attention")
        return output, None
    return output
