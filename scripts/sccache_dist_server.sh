#!/bin/sh -e

# Environment variables
export SCCACHE_LOG=trace
export SCCACHE_NO_DAEMON=1

# Start sccache-dist server
cat << EOF | sudo sccache-dist server --config /dev/stdin
cache_dir = "/tmp/toolchains"
public_addr = "$(tailscale ip --4):10501"
scheduler_url = "http://$SCCACHE_SCHEDULER_HOSTNAME:10600"

[builder]
build_dir = "/tmp/build"
bwrap_path = "/usr/bin/bwrap"
type = "overlay"

[scheduler_auth]
type = "DANGEROUSLY_INSECURE"
EOF
