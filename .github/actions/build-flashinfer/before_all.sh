#!/bin/sh -e

# Make tempfile deterministic
cat << "EOF" >> $(python3 -c "import tempfile; print(tempfile.__file__)")
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
