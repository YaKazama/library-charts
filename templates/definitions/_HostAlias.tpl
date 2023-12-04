{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#hostalias-v1-core
  descr:
  - 相同 IP 的配置会合并并去重
  - 可以支持 特定格式 (ip hostname1 hostname2 ... hostnameN) 的字符串、Slice、Map
*/ -}}
{{- define "definitions.HostAlias" -}}
  {{- $__regexHostList := "^((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\s+[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+)+$" }}

  {{- $__hostDict := dict }}

  {{- if kindIs "slice" . }}
    {{- range $v := . }}
      {{- $__ip := "" }}
      {{- $__hostnames := "" }}

      {{- if kindIs "string" $v }}
        {{- if not (mustRegexMatch $__regexHostList $v) }}
          {{- fail "Not a standard format, refer to the /etc/hosts file" }}
        {{- end }}

        {{- $__regexSlice := mustRegexSplit " " $v -1 }}
        {{- if le (len $__regexSlice) 1 }}
          {{- fail "ip or hostnames not found" }}
        {{- end }}

        {{- $__ip = index $__regexSlice 0 }}
        {{- $__hostnames = slice $__regexSlice 1 | uniq }}
      {{- else if kindIs "map" $v }}
        {{- if and (hasKey $v "ip") (hasKey $v "hostnames") }}
          {{- $__ip = get $v "ip" }}
          {{- $__hostnames = get $v "hostnames" }}
        {{- end }}
      {{- end }}

      {{- if and $__ip $__hostnames }}
        {{- nindent 0 "" -}}- ip: {{ $__ip }}
        {{- nindent 2 "" -}}  hostnames:
          {{- toYaml ($__hostnames | uniq) | nindent 2 }}
      {{- end }}
    {{- end }}
  {{- else if kindIs "map" . }}
    {{- range $k, $v := . }}
      {{- nindent 0 "" -}}- ip: {{ $k }}
      {{- nindent 2 "" -}}  hostnames:
        {{- toYaml ($v | uniq) | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
