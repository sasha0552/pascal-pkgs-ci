#!/bin/sh -e

# Copy sccache from host
cp /host/opt/hostedtoolcache/sccache/*/*/sccache /usr/bin

# Show cache stats
sccache --show-stats

# Install dependencies
python -m pip install setuptools torch wheel
