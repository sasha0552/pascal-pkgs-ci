import torch
import torch.nn as nn
from torch.utils.checkpoint import checkpoint
from flash_attn.flash_attention import flash_attn_func
import torch.cuda.amp

class FlashAttention(nn.Module):
    def __init__(self, *args, **kwargs):
        super().__init__()
        # Ignore original arguments since we're using vanilla attention

    def forward(
        self,
        q: torch.Tensor,
        k: torch.Tensor,
        v: torch.Tensor,
        **kwargs
    ) -> torch.Tensor:
        with torch.cuda.amp.autocast():
            return F.scaled_dot_product_attention(q, k, v, dropout_p=kwargs.get('dropout_p', 0.0), is_causal=kwargs.get('causal', False))
