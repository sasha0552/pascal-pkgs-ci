#!/bin/sh -e

# Iterate over sequence
for i in $(seq 0 18); do
  # Kill sccache-dist
  tailscale ssh "root@ppc-$TS_RANDOM-server-$i" killall -SIGTERM sccache-dist || true
done
