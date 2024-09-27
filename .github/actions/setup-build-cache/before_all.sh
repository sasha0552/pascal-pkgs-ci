#!/bin/sh -e

# Copy sccache from host
cp /host/tmp/sccache /usr/bin

# Wrap compilers with sccache
if [ $# -eq 1 ] && [ "$1" = "--wrap" ]; then
  wrap() {
    # Program name
    local program=$1

    # Path to program
    local path=$(which $program)

    # If path not found, return
    if [ -z "$path" ]; then
      return
    fi

    # Move proram
    mv "$path" "$path.orig"

    # Create wrapper
    echo "#!/bin/sh -e" > "$path"
    echo "exec sccache $path.orig" >> "$path"

    # Add executable permission
    chmod +x "$path"
  }

  wrap clang
  wrap clang++
  wrap gcc
  wrap g++
  wrap nvcc
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
