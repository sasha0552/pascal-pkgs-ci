#!/bin/sh -e

# Copy sccache from host
cp /host/opt/hostedtoolcache/sccache/*/*/sccache /usr/bin

# Show cache stats
sccache --show-stats

# Install pytorch
python -m pip install torch
