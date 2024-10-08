# pascal-pkgs-ci

> [!IMPORTANT]
> NEW: vLLM docker image
> You can now try out the vLLM docker image for Pascal GPUs.

The main repository for building Pascal-compatible versions of ML applications and libraries.

1. vLLM is rebuilt automatically every day at `01:30` UTC.
2. Triton `2.2.0`, `2.3.0`, `2.3.1` and `3.0.0` are available in this repository.

## Installation (docker)

# vLLM

```sh
# Pull the vLLM image
docker pull ghcr.io/sasha0552/vllm:latest

# You can now follow the official vLLM documentation.
# Replace the official image with this one.
```

## Installation (manual)

I recommend installing [transient-package](https://pypi.org/project/transient-package) before proceeding. It simplifies the installation of `triton`.

You can install it globally with `pipx`:

```sh
pipx install transient-package
```

> [!IMPORTANT]
> <details>
> <summary>If you don't want to install transient-package</summary>
>
> If you don't want to install `transient-package`, you'll need to replace
>
> ```sh
> transient-package install       \
>   --interpreter venv/bin/python \
>   --source triton               \
>   --target triton-pascal
> ```
>
> with
>
> ```sh
> # Remove triton
> pip uninstall triton
>
> # Install patched triton
> pip install triton-pascal
> ```
>
> Note that `transient-package` does more than just `pip uninstall triton` and `pip install triton-pascal`.
> In particular, it tries to install the correct version of `triton`, and creates a bogus `triton` package in case the application checks for the presence of `triton`.
> </details>

### [vllm](https://github.com/vllm-project/vllm)

*Note: this repository holds both "release" and "nightly" builds of vLLM.*

#### To install the patched vLLM:
```sh
# Use this repository
export PIP_EXTRA_INDEX_URL="https://sasha0552.github.io/pascal-pkgs-ci/"

# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install vLLM
pip3 install vllm-pascal  # nightly build is installed by default
                          # you can specify, e.g., ==0.6.2 to install
                          # a specific release

# Install patched triton
transient-package install       \
  --interpreter venv/bin/python \
  --source triton               \
  --target triton-pascal

# Launch vLLM
vllm serve --help
```

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
> In rare cases, this may cause dependency errors; in that case, just reinstall vLLM.

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

# Install patched triton
transient-package install       \
  --interpreter venv/bin/python \
  --source triton               \
  --target triton-pascal

# Launch aphrodite-engine
aphrodite --help
```

### [triton](https://github.com/triton-lang/triton) (for other applications)

#### To install patched Triton:

```sh
# Use this repository
export PIP_EXTRA_INDEX_URL="https://sasha0552.github.io/pascal-pkgs-ci/"

# Install patched triton
transient-package install       \
  --interpreter venv/bin/python \
  --source triton               \
  --target triton-pascal
```

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
