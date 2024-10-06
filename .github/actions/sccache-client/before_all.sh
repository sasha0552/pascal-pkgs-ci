#!/bin/sh -e

# Copy sccache from host
cp /host/usr/bin/sccache /usr/bin

# Wrap compilers with sccache
if [ $# -eq 1 ] && [ "$1" = "--wrap" ]; then
  # Print PATH
  echo "$PATH"

  # Create hardlinks
  for compiler in clang clang++ gcc g++ nvcc; do
    # Create hardlink
    ln /usr/bin/sccache /usr/local/bin/$compiler

    # Print path to compiler
    which "$compiler"
  done
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
