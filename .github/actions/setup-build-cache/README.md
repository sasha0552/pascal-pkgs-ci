# setup-build-cache

To use:

```yaml
- name: Setup build cache
  uses: ./.github/actions/setup-build-cache

- name: Build wheels
  uses: pypa/cibuildwheel@...
  env:
    CIBW_BEFORE_ALL_LINUX: .github/actions/setup-build-cache/before_all.sh
    CIBW_ENVIRONMENT_PASS_LINUX: >
      ACTIONS_CACHE_URL
      ACTIONS_RUNTIME_TOKEN
      SCCACHE_DIRECT
      SCCACHE_GHA_ENABLED
```
