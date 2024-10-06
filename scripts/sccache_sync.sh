#!/bin/sh -e

# Iterate over servers
i=0; while [ $i -lt $TS_SERVERCOUNT ]; do
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

  # Increment
  i=$((i + 1))
done
