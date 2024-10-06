#!/bin/sh -e

# Iterate over sequence
for i in $(seq 0 18); do
  # Repeat infinitely
  while true; do
    # Print message
    echo "Waiting for ppc-$TS_RANDOM-server-$i..."

    # Try to execute command on server
    output=$(tailscale ssh "root@ppc-$TS_RANDOM-server-$i" echo alive 2>/dev/null || echo failure)

    # If command was executed
    if [ "$output" = "alive" ]; then
      # Move on
      break
    fi

    # Wait three seconds
    sleep 3
  done
done
