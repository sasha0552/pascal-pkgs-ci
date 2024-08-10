# pascal-pkgs-ci

The main repository for building Pascal-compatible versions of ML applications and libraries.

1. vLLM is rebuilt automatically every day at `01:30` UTC.
2. Triton `2.2.0`, `2.3.0`, `2.3.1` and `3.0.0` are available in this repository.

## Installation

### [vllm](https://github.com/vllm-project/vllm)

*Note: this repository holds "nightly" builds of vLLM.*

#### To install the patched vLLM:
```sh
# Use this repository
export PIP_EXTRA_INDEX_URL="https://sasha0552.github.io/pascal-pkgs-ci/"

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install vLLM
pip3 install vllm-pascal

# Remove triton
pip3 uninstall triton

# Install patched triton
pip3 install triton-pascal

# Launch vLLM
vllm serve --help
```

> [!NOTE]
Installation will be simplified in the future.

#### To update a patched vLLM between same vLLM release versions (e.g. `0.5.0` (commit `000000`) -> `0.5.0` (commit `ffffff`)):

```sh
# Use this repository
export PIP_EXTRA_INDEX_URL="https://sasha0552.github.io/pascal-pkgs-ci/"

# Activate virtual environment
source venv/bin/activate

# Update vLLM
pip3 install --force-reinstall --no-cache-dir --no-deps --upgrade vllm-pascal
```

> [!WARNING]
In rare cases, this may cause dependency errors; in that case, just reinstall vLLM.

### [aphrodite-engine](https://github.com/PygmalionAI/aphrodite-engine)

To install aphrodite-engine with the patched Triton:
```sh
# Use this repository
export PIP_EXTRA_INDEX_URL="https://sasha0552.github.io/pascal-pkgs-ci/"

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install aphrodite-engine
pip3 install --extra-index-url https://downloads.pygmalion.chat/whl aphrodite-engine

# Remove triton
pip3 uninstall triton

# Install patched triton
pip3 install triton-pascal

# Launch aphrodite-engine
aphrodite --help
```

> [!NOTE]
Installation will be simplified in the future.

### [triton](https://github.com/triton-lang/triton) (for other applications)

#### To install patched Triton:

```sh
# Use this repository
export PIP_EXTRA_INDEX_URL="https://sasha0552.github.io/pascal-pkgs-ci/"

# Remove triton
pip3 uninstall triton

# Install patched triton
pip3 install triton-pascal
```

> [!NOTE]
Installation will be simplified in the future.

---

<details>
<summary>Instructions for uploading to PyPI</summary>

```sh
# Download artifacts
gh run download <run id>

# Install twine
pip3 install twine

# Upload wheels
TWINE_PASSWORD=<pypi token> twine upload */*.whl
```
</details>
