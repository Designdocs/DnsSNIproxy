#!/usr/bin/env bash
set -euo pipefail

# 获取最新 geoip.dat / geosite.dat（来自 V2Fly 官方发布），附带 CDN 备用
GEOIP_URLS=(
    "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat"
    "https://fastly.jsdelivr.net/gh/v2fly/geoip@release/geoip.dat"
)
GEOSITE_URLS=(
    "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat"
    "https://fastly.jsdelivr.net/gh/v2fly/domain-list-community@release/dlc.dat"
)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

download_with_fallback() {
    local target="$1"; shift
    for url in "$@"; do
        echo "Downloading ${url} -> ${target}"
        if curl -L --fail --retry 3 --retry-delay 3 --retry-all-errors --silent --show-error -o "${target}.tmp" "${url}"; then
            mv "${target}.tmp" "${target}"
            return 0
        else
            echo "Failed: ${url}"
        fi
    done
    echo "All mirrors failed for ${target}" >&2
    return 1
}

download_with_fallback "${SCRIPT_DIR}/geoip.dat" "${GEOIP_URLS[@]}"
download_with_fallback "${SCRIPT_DIR}/geosite.dat" "${GEOSITE_URLS[@]}"

echo "Done. 请将 geoip.dat / geosite.dat 推送到仓库以便安装脚本同步。"
