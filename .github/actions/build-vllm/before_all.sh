#!/bin/sh -e

# Debug
ls -lah /opt
ls -lah /opt/python
ls -lah /opt/python/*
exit 1

# Make tempfile deterministic
cat << "EOF" >> /opt/python/*/tempfile.py
class _RandomNameSequence:
  i = -1

  def __iter__(self):
    return self

  def __next__(self):
    self.i += 1
    return format(self.i, "08")
EOF

# Copy sccache from host
cp /host/opt/hostedtoolcache/sccache/*/*/sccache /usr/bin

# Show cache stats
sccache --show-stats
