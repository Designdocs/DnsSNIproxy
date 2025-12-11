#!/usr/bin/env bash
set -euo pipefail

# 获取最新 geoip.dat / geosite.dat（来自 V2Fly 官方发布）
GEOIP_URL="https://github.com/v2fly/geoip/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

download_file() {
    local url="$1"
    local target="$2"
    echo "Downloading ${url} -> ${target}"
    curl -L --fail --silent --show-error -o "${target}.tmp" "${url}"
    mv "${target}.tmp" "${target}"
}

download_file "${GEOIP_URL}" "${SCRIPT_DIR}/geoip.dat"
download_file "${GEOSITE_URL}" "${SCRIPT_DIR}/geosite.dat"

echo "Done. 请将 geoip.dat / geosite.dat 推送到仓库以便安装脚本同步。"
