#!/usr/bin/env bash
set -euo pipefail

strategy="${1:-}"
gradle_home="${GRADLE_USER_HOME:?GRADLE_USER_HOME must be set}"
mkdir -p "${gradle_home}/init.d"

case "$strategy" in
  actions-cache)
    cat > "${gradle_home}/init.d/benchmark-cache-policy.gradle" <<'GRADLE'
import org.gradle.caching.http.HttpBuildCache

gradle.settingsEvaluated { settings ->
    settings.buildCache {
        local {
            enabled = true
        }
        remote(HttpBuildCache) {
            enabled = false
        }
    }
}
GRADLE
    {
      echo "org.gradle.caching=true"
      echo "org.gradle.daemon=false"
    } >> "${gradle_home}/gradle.properties"
    ;;
  boringcache)
    # The BoringCache action owns the remote Gradle build-cache init script.
    # Keep it intact so the following Gradle command uses the action's proxy.
    cache_init="${gradle_home}/init.d/boringcache-gradle-build-cache.init.gradle"
    if [[ ! -s "$cache_init" ]]; then
      echo "BoringCache did not install its Gradle build-cache init script in ${gradle_home}." >&2
      exit 1
    fi
    ;;
  *)
    echo "Unsupported Gradle cache strategy: ${strategy:-<empty>}" >&2
    exit 1
    ;;
esac
