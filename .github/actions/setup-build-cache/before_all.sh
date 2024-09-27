#!/bin/sh -e

# Copy sccache from host
cp /host/opt/hostedtoolcache/sccache/*/*/sccache.orig /usr/bin/sccache

# Create symlinks to sccache
if [ $# -eq 1 ] && [ "$1" = "--symlinks" ]; then
  ln -s /usr/bin/sccache /usr/local/bin/clang
  ln -s /usr/bin/sccache /usr/local/bin/clang++
  ln -s /usr/bin/sccache /usr/local/bin/gcc
  ln -s /usr/bin/sccache /usr/local/bin/g++
  ln -s /usr/bin/sccache /usr/local/bin/nvcc
fi

# Capture path of `build.env` module
ENV_PY=$(python3 -c "import build.env; print(build.env.__file__)")

# Use static, deterministic directory name
sed --in-place "s/tempfile.mkdtemp(prefix='build-env-')/os.path.join(tempfile.gettempdir(), 'build-env-00000000'); os.mkdir(path, 0o700)/g" "$ENV_PY"

# Update stats periodically
nohup sh -c "                                                                 \
  while true; do                                                              \
    sccache --show-stats                     > /host/tmp/sccache_stats.txt  ; \
    sccache --show-stats --stats-format=json > /host/tmp/sccache_stats.json ; \
    sleep 3                                                                 ; \
  done                                                                        \
"                                                                             &

# Disown background jobs
disown
