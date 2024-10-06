#!/bin/sh -e

# Update package lists
sudo apt-get update

# Install bubblewrap
sudo apt-get install --yes bubblewrap

# Download sccache-dist
sudo wget https://github.com/sasha0552/sccache/releases/latest/download/sccache-dist -O /usr/bin/sccache-dist

# Give executable perm
sudo chmod +x /usr/bin/sccache-dist
