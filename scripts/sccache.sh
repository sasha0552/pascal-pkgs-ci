#!/bin/sh -e

# Constants
readonly SCCACHE_VERSION=v0.8.2
readonly SCCACHE_BASE=sccache-$SCCACHE_VERSION-x86_64-unknown-linux-musl
readonly SCCACHE_URL=https://github.com/mozilla/sccache/releases/download/$SCCACHE_VERSION/$SCCACHE_BASE.tar.gz

# If sccache is not installed
if [ -z $(which sccache) ]; then
  # Install sccache
  curl -fssL "$SCCACHE_URL" | sudo tar -xz -C /usr/local/bin --strip-components=1 "$SCCACHE_BASE/sccache"
fi

# Create config directory
mkdir -p ~/.config/sccache

# Save config
cat << EOF > ~/.config/sccache/config
[dist]
scheduler_url = "http://$SCCACHE_SCHEDULER_HOSTNAME:10600"
EOF
