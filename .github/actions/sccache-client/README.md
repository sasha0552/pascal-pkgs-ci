# sccache-client

## cibuildwheel

```yaml
- name: Build wheels
  uses: pypa/cibuildwheel@...
  env:
    CIBW_BEFORE_ALL_LINUX: .github/actions/sccache-client/before_all.sh
    CIBW_ENVIRONMENT_PASS_LINUX: >
      ACTIONS_CACHE_URL
      ACTIONS_RUNTIME_TOKEN
      SCCACHE_DIST_SCHEDULER_URL
      SCCACHE_GHA_ENABLED
```
