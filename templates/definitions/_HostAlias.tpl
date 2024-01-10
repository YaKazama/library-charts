{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#hostalias-v1-core
  descr:
  - 相同 IP 的配置会合并并去重
  - 可以支持 特定格式 (ip hostname1 hostname2 ... hostnameN) 的字符串、Slice、Map
*/ -}}

{{- define "definitions.HostAlias" -}}
  {{- $__regexHostAlias := "^((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\s+[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+)+$" }}

  {{- with . }}
    {{- $__ip := "" }}
    {{- $__hostnames := list }}

    {{- if kindIs "string" . }}
      {{- if not (mustRegexMatch $__regexHostAlias .) }}
        {{- fail "definitions.HostAlias: not a standard format, refer to the /etc/hosts file - 1" }}
      {{- end }}
      {{- $__val := mustRegexSplit " " . -1 }}
      {{- $__ip = index $__val 0 }}
      {{- $__hostnames = slice $__val 1 }}
    {{- else if kindIs "map" . }}
      {{- if and (hasKey . "ip") (hasKey . "hostnames") }}
        {{- $__ip = get . "ip" }}
        {{- $__hostnames = get . "hostnames" }}
      {{- else }}
        {{- range $k, $v := . }}
          {{- $__ip = $k }}
          {{- $__hostnames = $v }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "string" . }}
          {{- if not (mustRegexMatch $__regexHostAlias .) }}
            {{- fail "definitions.HostAlias: not a standard format, refer to the /etc/hosts file - 2" }}
          {{- end }}
          {{- $__val := mustRegexSplit " " . -1 }}
          {{- $__ip = index $__val 0 }}
          {{- $__hostnames = slice $__val 1 }}
        {{- else if kindIs "map" . }}
          {{- if and (hasKey . "ip") (hasKey . "hostnames") }}
            {{- $__ip = get . "ip" }}
            {{- $__hostnames = get . "hostnames" }}
          {{- else }}
            {{- range $k, $v := . }}
              {{- $__ip = $k }}
              {{- $__hostnames = $v }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- if and $__ip $__hostnames }}
      {{- nindent 0 "" -}}hostnames:
      {{- if kindIs "string" $__hostnames }}
        {{- include "base.fmt.slice" (dict "s" ($__hostnames | list)) | nindent 0 }}
      {{- else if kindIs "slice" $__hostnames }}
        {{- mustCompact (mustUniq $__hostnames) | toYaml | nindent 0 }}
      {{- else }}
        {{- fail "definitions.HostAlias: hostnames not support, please use string or slice" }}
      {{- end }}
      {{- nindent 0 "" -}}ip: {{ $__ip }}
    {{- end }}
  {{- end }}
{{- end }}
