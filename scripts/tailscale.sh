#!/bin/sh -e

# Install tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Execute tailscale command
sudo tailscale "$@"
