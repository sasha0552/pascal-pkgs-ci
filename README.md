# pascal-pkgs-ci

The main repository for building Pascal-compatible versions of ML applications and libraries.

## Installation

### [vllm](https://github.com/vllm-project/vllm)

*Note: this repository holds "nightly" builds of `vLLM`.*

To install the patched `vLLM`:
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
pip3 remove triton

# Install patched triton
pip3 install triton-pascal

# Launch vLLM
vllm serve --help
```

To update a patched `vLLM` between same `vLLM` release versions (e.g. `0.5.0` (commit `000000`) -> `0.5.0` (commit `ffffff`))
```sh
# Use this repository
export PIP_EXTRA_INDEX_URL="https://sasha0552.github.io/pascal-pkgs-ci/"

# Activate virtual environment
source venv/bin/activate

# Update vLLM
pip3 install --force-reinstall --no-cache-dir --upgrade vllm-pascal
```

### [triton](https://github.com/triton-lang/triton)

To install patched `triton`:

```sh
# Use this repository
export PIP_EXTRA_INDEX_URL="https://sasha0552.github.io/pascal-pkgs-ci/"

# Examine triton version
pip3 show triton
Name: triton
Version: 3.0.0 <--
...

# Remove triton
pip3 remove triton

# Install patched triton (specific version)
pip3 install triton-pascal==3.0.0
```

Note that installation will be simplified in the future.

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
