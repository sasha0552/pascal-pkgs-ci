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
    CIBW_CONTAINER_ENGINE: "docker; create_args: --volume /home/runner/.cache:/root/.cache:rw"
    CIBW_ENVIRONMENT_PASS_LINUX: >
      ACTIONS_CACHE_URL
      ACTIONS_RUNTIME_TOKEN
      SCCACHE_DIRECT
      SCCACHE_GHA_ENABLED
```
