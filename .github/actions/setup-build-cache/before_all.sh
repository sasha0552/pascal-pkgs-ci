#!/bin/sh -e

# Capture path of `tempfile` module
TEMPFILE_PY=$(python3 -c "import tempfile; print(tempfile.__file__)")

# Implement selection of name sequence based on prefix
cat << "EOF" >> "$TEMPFILE_PY"
class _DeterministicNameSequence:
  i = -1

  def __iter__(self):
    return self

  def __next__(self):
    self.i += 1
    return format(self.i, "08")

__get_candidate_names = _get_candidate_names
def _get_candidate_names(locals={}):
  if "pre" in locals:
    prefix = locals["pre"]

  if "prefix" in locals:
    prefix = locals["prefix"]

  if prefix == "pip-build-env-":
    return _DeterministicNameSequence()

  return __get_candidate_names()
EOF

# Pass local variables to _get_candidate_names
sed --in-place "s/_get_candidate_names()$/_get_candidate_names(locals())/g" "$TEMPFILE_PY"

# Copy sccache from host
cp /host/opt/hostedtoolcache/sccache/*/*/sccache /usr/bin

# Show cache stats
sccache --show-stats
