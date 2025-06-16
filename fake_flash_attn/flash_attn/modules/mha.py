import torch
import torch.nn as nn
from flash_attn.flash_attention import flash_attn_func

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
        return flash_attn_func(q, k, v, **kwargs)
