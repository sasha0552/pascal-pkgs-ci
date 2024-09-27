#!/bin/sh -e

# Copy sccache from host
cp /host/tmp/sccache /usr/bin

# Wrap compilers with sccache
if [ $# -eq 1 ] && [ "$1" = "--wrap" ]; then
  ln /usr/bin/sccache /usr/local/bin/clang
  ln /usr/bin/sccache /usr/local/bin/clang++
  ln /usr/bin/sccache /usr/local/bin/gcc
  ln /usr/bin/sccache /usr/local/bin/g++
  ln /usr/bin/sccache /usr/local/bin/nvcc
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
