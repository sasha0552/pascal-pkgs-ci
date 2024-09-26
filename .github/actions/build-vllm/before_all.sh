#!/bin/sh -e

# Copy sccache from host
cp /host/opt/hostedtoolcache/sccache/*/*/sccache /usr/local/bin

# Start sccache daemon
SCCACHE_ERROR_LOG=/dev/stdout SCCACHE_LOG=debug SCCACHE_START_SERVER=1 sccache

# Print statistics
sccache --show-stats
