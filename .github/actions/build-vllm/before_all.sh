#!/bin/sh -e

# Version of sscache
sscache_version=0.8.1

# Download sccache
wget --progress=dot:mega https://github.com/mozilla/sccache/releases/download/v${sccache_version}/sccache-v${sccache_version}-$(arch)-unknown-linux-musl.tar.gz

# Install sccache
tar                                                                    \
  --directory /usr/local/bin                                           \
  --extract                                                            \
  --file sccache-v${sccache_version}-$(arch)-unknown-linux-musl.tar.gz \
  --strip-components 1                                                 \
  sccache-v${sccache_version}-$(arch)-unknown-linux-musl/sccache
