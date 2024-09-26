#!/bin/sh -e

# Debug
ls -lah /opt
ls -lah /usr/lib
ls -lah /usr/lib/python*/tempfile.py

# Make tempfile deterministic
cat << "EOF" >> /usr/lib/python*/tempfile.py
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
