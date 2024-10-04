#!/bin/sh -e

# Constants
readonly SCCACHE_VERSION=v0.8.2
readonly SCCACHE_DIST_BASE=sccache-dist-$SCCACHE_VERSION-x86_64-unknown-linux-musl
readonly SCCACHE_DIST_URL=https://github.com/mozilla/sccache/releases/download/$SCCACHE_VERSION/$SCCACHE_DIST_BASE.tar.gz

# If sccache-dist is not installed
if [ -z $(which sccache-dist) ]; then
  # Install sccache-dist
  curl -fssL "$SCCACHE_DIST_URL" | sudo tar -xz -C /usr/local/bin --strip-components=1 "$SCCACHE_DIST_BASE/sccache-dist"
fi
