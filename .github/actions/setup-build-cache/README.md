# setup-build-cache

To use:

```yaml
- name: Setup build cache
  uses: ./.github/actions/setup-build-cache
  with:
    key: abc

- name: Build wheels
  uses: pypa/cibuildwheel@...
  env:
    CIBW_BEFORE_ALL_LINUX: .github/actions/setup-build-cache/before_all.sh
    CIBW_CONTAINER_ENGINE: "docker; create_args: --volume /root/.cache:/root/.cache:rw"
```
