#!/bin/sh -e

# If tailscale is not installed
if [ -z $(which tailscale) ]; then
  # Install tailscale
  curl -fsSL https://tailscale.com/install.sh | sh
fi

# Execute tailscale command
sudo tailscale "$@"
