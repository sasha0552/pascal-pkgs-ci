#!/bin/sh -e

# Update package lists
sudo apt-get update

# Install bubblewrap
sudo apt-get install --yes bubblewrap

# Download sccache
sudo wget https://github.com/sasha0552/sccache/releases/latest/download/sccache -O /usr/bin/sccache
sudo wget https://github.com/sasha0552/sccache/releases/latest/download/sccache-dist -O /usr/bin/sccache-dist

# Give executable perm
sudo chmod +x /usr/bin/sccache
sudo chmod +x /usr/bin/sccache-dist

# Install teardown script
cat << EOF | sudo install /dev/stdin /usr/bin/sccache-dist-teardown
#!/bin/sh -e

# Iterate over sequence
for i in \$(seq 0 18); do
  # Kill sccache-dist
  tailscale ssh "root@ppc-$SCCACHE_RANDOM-server-\$i" killall -SIGTERM sccache-dist || true
done
EOF

# Exit if sccache from action does not exists
if [ ! -f /opt/hostedtoolcache/sccache/*/*/sccache ]; then
  exit 0
fi

# Generate initial stats
sccache --show-stats                     > /tmp/sccache_stats.txt
sccache --show-stats --stats-format=json > /tmp/sccache_stats.json

# Install fake sccache
cat << "EOF" | sudo install /dev/stdin /opt/hostedtoolcache/sccache/*/*/sccache
#!/bin/sh -e

if [ $# -eq 1 ] && [ "$1" = "--show-stats" ]; then
  exec cat /tmp/sccache_stats.txt
fi

if [ $# -eq 2 ] && [ "$1" = "--show-stats" ] && [ "$2" = "--stats-format=json" ]; then
  exec cat /tmp/sccache_stats.json
fi

exit 1
EOF
