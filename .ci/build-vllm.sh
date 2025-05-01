#!/bin/bash -e

# Variables
root="$1"
repository="$2"
ref="$3"
ghcr_user="$4"
ghcr_token="$5"

# Use root directory
cd "$root"

# Prepare virtual environment
"$root/.ci/common/prepare-venv.sh" "$root"

# Checkout repository
"$root/.ci/common/checkout.sh" "$root" "$repository" "$ref"

# Apply patches
"$root/.ci/common/apply-patches.sh" "$root" "$repository" "$ref"

# If GHCR token is provided
if [ -n "$ghcr_token" ]; then
  # Login to GitHub Container Registry
  echo "$ghcr_token" | docker login ghcr.io -u "$ghcr_user" --password-stdin
fi

# Compute vLLM version
# {
  # setuptools
  # {
    if [[ "$ref" == "main" ]]; then
      export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_VLLM="999.999.999"
    elif [[ "$ref" == v* ]]; then
      export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_VLLM="${ref:1}"
    fi
  # }

  # docker
  # {
    if [[ "$ref" == "main" ]]; then
      docker_tag="ghcr.io/$ghcr_user/vllm:latest"
    else
      docker_tag="ghcr.io/$ghcr_user/vllm:$ref"
    fi
  # }
# }

# Build wheels
mkdir -p "$root/tmp"
docker build \
  --build-arg "CUDA_VERSION=12.1.0" \
  --build-arg "torch_cuda_arch_list=6.0 6.1" \
  --build-arg "max_jobs=2" \
  --build-arg "nvcc_threads=2" \
  --output "type=tar,dest=$root/tmp/build.tar" \
  --secret "id=SETUPTOOLS_SCM_PRETEND_VERSION_FOR_VLLM" \
  --tag "$docker_tag" \
  --target "build" \
  "$root/$repository/$ref"

# Copy wheel files
tar --extract --file="$root/tmp/build.tar" --strip-components=1 workspace/dist
rm "$root/tmp/build.tar"

# Repackage wheels
export WHEEL_HOUSE="dist/*.whl"
export WHEEL_NAME="vllm_pascal"
"$root/.ci/common/repackage-wheels.sh" "$root"
