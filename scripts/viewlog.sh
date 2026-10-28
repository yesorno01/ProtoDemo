#!/usr/bin/env bash
# 日志查看脚本：通过参数查看 /data/server/ 下的服务日志
set -u

LOG_DIR="/data/server"

# 服务名 -> 日志文件映射
declare -A LOG_FILES=(
    ["order"]="cmbd-order-service.log"
    ["longterm"]="cmbd-longterm-service.log"
    ["bff"]="cmbd-bff-cs.log"
)

usage() {
    cat <<EOF
用法: $0 <服务名> <操作> [参数]

服务名:
  order      cmbd-order-service.log
  longterm   cmbd-longterm-service.log
  bff        cmbd-bff-cs.log

操作:
  (不写操作)         默认实时跟踪最新日志，等同于 tail -f
  tail [行数]       查看最近 N 行日志（默认 200）
  -f | follow       实时跟踪日志（默认从最后 50 行开始）
  grep <关键词>     搜索含关键词的行

示例:
  $0 order tail 300
  $0 bff -f
  $0 longterm grep ERROR
EOF
}

main() {
    local service="${1:-longterm}"
    local action="${2:-}"

    if [[ -z "$service" || -z "${LOG_FILES[$service]:-}" ]]; then
        usage
        exit 1
    fi

    local file="${LOG_DIR}/${LOG_FILES[$service]}"

    if [[ ! -f "$file" ]]; then
        echo "错误: 日志文件不存在 -> $file"
        exit 1
    fi

    case "${action:-follow}" in
        tail)
            local lines="${3:-200}"
            tail -n "$lines" "$file"
            ;;
        -f|follow)
            local lines="${3:-50}"
            tail -n "$lines" -f "$file"
            ;;
        grep)
            local keyword="${3:-}"
            if [[ -z "$keyword" ]]; then
                echo "错误: grep 需要关键词参数"
                exit 1
            fi
            grep --color=auto -n "$keyword" "$file"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"