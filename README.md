# pascal-pkgs-ci

The main repository for building Pascal-compatible versions of ML applications and libraries.

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
