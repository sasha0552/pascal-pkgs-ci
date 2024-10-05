#!/bin/sh -e

# Start sccache-dist scheduler
cat << EOF | sccache-dist scheduler --config /dev/stdin
public_addr = "$(tailscale ip --4):10600"

[client_auth]
type = "DANGEROUSLY_INSECURE"

[server_auth]
type = "DANGEROUSLY_INSECURE"
EOF
