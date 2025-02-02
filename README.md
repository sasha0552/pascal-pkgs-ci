# pascal-pkgs-ci

The main repository for building Pascal-compatible versions of ML applications and libraries.

1. vLLM `0.5.5`, `0.6.0`, `0.6.1`, `0.6.1.post1`, `0.6.1.post`, `0.6.2`, `0.6.3`, `0.6.3.post1`, `0.6.4`, `0.6.4.post1`, `0.6.5`, `0.6.6`, `0.6.6.post1`, `0.7.0`, `0.7.1` and `main` (nightly, updates daily) are available in this repository.
2. Triton `2.2.0`, `2.3.0`, `2.3.1`, `3.0.0`, `3.1.0` are available in this repository.

> [!IMPORTANT]
> **NEW:** vLLM docker images  
> You can now try out the vLLM docker images for Pascal GPUs.

## Installation (docker)

### [vllm](https://github.com/vllm-project/vllm)

```sh
# Pull the vLLM image
docker pull ghcr.io/sasha0552/vllm:v0.7.1  # you can omit the version specifier
                                           # to install nightly version

# You can now follow the official vLLM documentation.
# Replace the official image with this one.
```

## Installation (manual)

> [!WARNING]
> Wheels, as of v0.6.5, is currently in a soft-broken state due to PyTorch.
> To use them, you need to manually patch PyTorch after installation of vLLM.
>
> <details>
> <summary>Patching PyTorch</summary>
>
> Example command assuming you are using a virtual environment located in the current directory
>
> ```sh
> sed -e "s/.major < 7/.major < 6/g"                                 \
>     -e "s/.major >= 7/.major >= 6/g"                               \
>     -i                                                             \
>     venv/lib/python3.12/site-packages/torch/_inductor/scheduler.py \
>     venv/lib/python3.12/site-packages/torch/utils/_triton.py
> ```
> </details>

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

```sh
# Use this repository
export PIP_EXTRA_INDEX_URL="https://sasha0552.github.io/pascal-pkgs-ci/"

# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install vLLM
pip3 install vllm-pascal==0.7.1  # you can omit the version specifier
                                 # to install nightly version

# Install patched triton
transient-package install       \
  --interpreter venv/bin/python \
  --source triton               \
  --target triton-pascal

# Launch vLLM
vllm serve --help
```

### [aphrodite-engine](https://github.com/PygmalionAI/aphrodite-engine)

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
