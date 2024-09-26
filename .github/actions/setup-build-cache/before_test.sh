#!/bin/sh -e

# Capture cache stats
sccache --show-stats                     > /host/tmp/sccache_stats.txt
sccache --show-stats --stats-format=json > /host/tmp/sccache_stats.json

# Install fake sccache
cat << "EOF" | install /dev/stdin /host/opt/hostedtoolcache/sccache/*/*/sccache
#!/bin/sh -e

if [ $# -eq 1 ] && [ "$1" = "--show-stats" ]; then
  exec cat /tmp/sccache_stats.txt
fi

if [ $# -eq 2 ] && [ "$1" = "--show-stats" ] && [ "$2" = "--stats-format=json" ]; then
  exec cat /tmp/sccache_stats.json
fi

exit 1
EOF
