#!/bin/sh -e

# Iterate over servers
i=0; while [ $i -lt $TS_SERVERCOUNT ]; do
  # Kill sccache-dist
  tailscale ssh "root@ppc-$TS_RANDOM-server-$i" killall -SIGTERM sccache-dist || true

  # Increment
  i=$((i + 1))
done
