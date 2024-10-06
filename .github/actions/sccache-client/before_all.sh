#!/bin/sh -e

# Copy sccache from host
cp /host/usr/bin/sccache /usr/bin

# Wrap compilers with sccache
if [ $# -eq 1 ] && [ "$1" = "--wrap" ]; then
  ln /usr/bin/sccache /usr/local/bin/clang
  ln /usr/bin/sccache /usr/local/bin/clang++
  ln /usr/bin/sccache /usr/local/bin/gcc
  ln /usr/bin/sccache /usr/local/bin/g++
  ln /usr/bin/sccache /usr/local/bin/nvcc
fi

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
