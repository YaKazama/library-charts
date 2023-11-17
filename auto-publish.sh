#!/usr/bin/env bash
# @author: Ya Kazama <kazamaya.y@gmail.com>
# @date  : 2022-06-08 13:44:21
#

# REAL_PATH=$(cd "$(dirname $0)" && pwd)
# cd ${REAL_PATH} || exit 1

function publish() {
    local folder="$1"
    local index_url="$2"
    local ngx_upload="$3"
    local merge="$4"
    local nexus_login_info="$5"
    local cmd_helm
    local name
    local version
    local helm_upload_url

    cd ${folder} || exit 1

    cmd_helm=$(which helm)
    [[ ! -f "${cmd_helm}" ]] && echo "command: helm not found, please install it first." && exit 1

    if [[ -f "Chart.yaml" ]]; then
        name=$(grep -E "^name:" Chart.yaml | awk '{print $2}')
        version=$(grep -E "^version:" Chart.yaml | awk '{print $2}')
        # -u: 解决本地没有 dependencies 时，helm package 执行出错的问题
        # Error: found in Chart.yaml, but missing in charts/ directory: library-charts
        ${cmd_helm} package . -u
        if [[ -n "${nexus_login_info}" ]]; then
            curl -u "${nexus_login_info}" "${index_url}" --upload-file ${name}-${version}.tgz
        else
            if [[ "${merge^}" == "True" ]]; then
                curl -s -O -L "${index_url:?}/index.yaml"
                ${cmd_helm} repo index --merge index.yaml --url ${index_url} .
            else
                ${cmd_helm} repo index . --url ${index_url}
            fi

            [[ "${ngx_upload}" == "True" ]] && helm_upload_url="${index_url}/upload"

            curl -XPUT ${helm_upload_url}/${name}-${version}.tgz --data-binary @${name}-${version}.tgz
            curl -XPUT ${helm_upload_url}/index.yaml --data-binary @index.yaml
        fi

        rm -rf ${name}-${version}.tgz index.yaml
    else
        echo "Chart.yaml missing."
        exit 1
    fi
}

function usage() {
    echo "Usage: sh $0 <Helm Chart> [Options]"
    echo "Options:"
    echo "  -h, --help:                     帮助信息"
    echo "  -i <URL>, --index-url <URL>:    * HELM Chart 仓库 URL"
    echo "  --nexus-login <USER:PASS>:      Nexus 提供的 HELM Chart 仓库的 username and password。此时 --merge、-N 参数会失效"
    echo "  --merge:                        将生成的索引合并到给定的索引中"
    echo "  -N, --nginx-upload:             使用 Nginx 上传 / 下载站点时需要指定此参数"
    exit 0
}

function main() {
    [[ "$1" =~ (^-{1,2}(h|help)+$) ]] && usage

    local ARGS
    local ARGS_SHORT='h,i:,N'
    local ARGS_LONG='help,index-url:,merge,nexus-login:,nginx-upload'
    ARGS=$(getopt -o ${ARGS_SHORT} --long ${ARGS_LONG} -n "$0" -- "$@")
    eval set -- "${ARGS}"

    while :
    do
        case "$1" in
            -i|--index-url)     local INDEX_URL="$2";       shift 2 ;;
            --merge)            local MERGE_STATUS="True";  shift 1 ;;
            --nexus-login)      local _NEXUS_LOGIN="$2";    shift 2 ;;
            -N|--nginx-upload)  local _NGX_UPLOAD="True";   shift 1 ;;
            --)                 shift;                      break   ;;
            *)                  usage                               ;;
        esac
    done

    # how to use
    [[ -z "${INDEX_URL}" ]] && echo "HELM Chart 仓库未找到，--index-url 参数未指定！"
    [[ "${MERGE_STATUS}" != "True" ]] && MERGE_STATUS="False"
    [[ "${_NGX_UPLOAD}" != "True" ]] && _NGX_UPLOAD="False"
    [[ -z "$1" ]] && usage
    publish "$1" "${INDEX_URL}" "${_NGX_UPLOAD}" "${MERGE_STATUS}" "${_NEXUS_LOGIN}"
}

# main
main "$@"
