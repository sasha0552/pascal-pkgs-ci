#!/bin/sh -e

# Environment variables
export SCCACHE_LOG=trace
export SCCACHE_NO_DAEMON=1

# Start sccache-dist server
cat << EOF | sudo sccache-dist server --config /dev/stdin || true
cache_dir = "/var/tmp/toolchains"
public_addr = "$(tailscale ip --4):10501"
scheduler_url = "$SCCACHE_DIST_SCHEDULER_URL"

[builder]
build_dir = "/var/tmp/build"
bwrap_path = "/usr/bin/bwrap"
type = "overlay"

[scheduler_auth]
type = "DANGEROUSLY_INSECURE"
EOF
