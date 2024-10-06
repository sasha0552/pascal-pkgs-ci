#!/bin/sh -e

# Configure Docker to use Tailscale MagicDNS
jq --arg dns_search "$(awk '/^search/ { print substr($0, 8) }' /etc/resolv.conf)" \
   '. += { "dns": [ "100.100.100.100" ], "dns-search": $dns_search | split(" ") }' /etc/docker/daemon.json | \
      sudo sponge /etc/docker/daemon.json

# Restart Docker daemon
sudo systemctl restart docker.service
