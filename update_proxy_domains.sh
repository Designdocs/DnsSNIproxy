#!/usr/bin/env bash
set -euo pipefail

# 从 v2fly/domain-list-community 拉取指定分类的域名，去重后合并到 proxy-domains.txt
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROXY_FILE="${SCRIPT_DIR}/proxy-domains.txt"
TMP_DIR="$(mktemp -d)"

BASE_URLS=(
    "https://raw.githubusercontent.com/v2fly/domain-list-community/master/data"
    "https://fastly.jsdelivr.net/gh/v2fly/domain-list-community@master/data"
)

CATEGORIES=(
    anthropic
    cerebras
    comfy
    cursor
    elevenlabs
    google-deepmind
    groq
    huggingface
    openai
    perplexity
    poe
    xai
    netflix
    hulu
    google-scholar
    google
    spotify
    disney
)

trap 'rm -rf "${TMP_DIR}"' EXIT

fetch_category() {
    local name="$1"
    local outfile="${TMP_DIR}/${name}.list"
    : > "${outfile}"
    local ok=0
    for base in "${BASE_URLS[@]}"; do
        local url="${base}/${name}"
        echo "Fetching ${url}"
        if curl -L --fail --retry 3 --retry-delay 2 --retry-all-errors --silent --show-error -o "${outfile}" "${url}"; then
            ok=1
            break
        else
            echo "Failed: ${url}"
        fi
    done
    if [ "${ok}" -ne 1 ]; then
        echo "All mirrors failed for ${name}" >&2
        return 1
    fi
    awk '
        /^[[:space:]]*(#|\/\/)/ {next}                     # 注释
        /^[[:space:]]*include:/ {next}                    # include 递归暂不处理
        /^[[:space:]]*regexp:/ {next}                     # 跳过正则
        /^[[:space:]]*keyword:/ {next}                    # 跳过关键词
        /^[[:space:]]*ipcidr:/ {next}                     # 跳过 IP 段
        {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0);  # trim
            line=$0;
            sub(/^(domain:|full:)/, "", line);            # 提取域名值
            # 仅保留形如 foo.bar 的域名
            if (line ~ /^[A-Za-z0-9.-]+\.[A-Za-z0-9.-]+$/) {
                print tolower(line);
            }
        }
    ' "${outfile}"
}

aggregate_domains() {
    local out="${TMP_DIR}/agg.txt"
    > "${out}"
    for cat in "${CATEGORIES[@]}"; do
        fetch_category "${cat}" >> "${out}"
    done
    # 合并现有 proxy-domains.txt，整体去重
    if [ -f "${PROXY_FILE}" ]; then
        cat "${PROXY_FILE}" >> "${out}"
    fi
    sort -u "${out}" > "${PROXY_FILE}.tmp"
    mv "${PROXY_FILE}.tmp" "${PROXY_FILE}"
}

aggregate_domains
echo "Done. Updated ${PROXY_FILE} with merged & deduplicated domains."
