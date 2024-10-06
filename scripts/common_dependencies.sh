#!/bin/sh -e

# Update package lists
sudo apt-get update

# Install bubblewrap and moreutils
sudo apt-get install --yes bubblewrap moreutils

# Install tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Install sccache-dist
curl -fssL https://github.com/sasha0552/sccache/releases/latest/download/sccache-dist | sudo install /dev/stdin /usr/bin/sccache-dist
