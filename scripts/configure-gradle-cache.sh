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
    cat > "${gradle_home}/init.d/benchmark-cache-policy.gradle" <<'GRADLE'
gradle.settingsEvaluated { settings ->
    settings.buildCache {
        local {
            enabled = false
        }
    }
}
GRADLE
    ;;
  *)
    echo "Unsupported Gradle cache strategy: ${strategy:-<empty>}" >&2
    exit 1
    ;;
esac
