{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#sysctl-v1-core
  descr:
  - 可以支持 特定格式 (k = v) 的字符串、Slice、Map
*/ -}}
{{- define "definitions.Sysctl" -}}
  {{- $__regexSysctl := "[a-z_\\.]+\\s+=\\s+.+" }}

  {{- $__name := "" }}
  {{- $__value := "" }}

  {{- if kindIs "string" . }}
    {{- if not (mustRegexMatch $__regexSysctl .) }}
      {{- fail "Not a standard format, refer to the /etc/sysctl.conf file" }}
    {{- end }}

    {{- $__regexSlice := mustRegexSplit "=" . -1 }}
    {{- if le (len $__regexSlice) 1 }}
      {{- fail "name or value not found" }}
    {{- end }}

    {{- $__name = index $__regexSlice 0 | trim }}
    {{- $__value = index $__regexSlice 1 | trim }}

    {{- if and $__name $__value }}
      {{- nindent 0 "" -}}- name: {{ $__name | toString | trim }}
      {{- nindent 2 "" -}}  value: {{ $__value | toString | trim }}
    {{- end }}
  {{- else if kindIs "slice" . }}
    {{- range . }}
      {{- if kindIs "string" . }}
        {{- if not (mustRegexMatch $__regexSysctl .) }}
          {{- fail "Not a standard format, refer to the /etc/sysctl.conf file" }}
        {{- end }}

        {{- $__regexSlice := mustRegexSplit "=" . -1 }}
        {{- if le (len $__regexSlice) 1 }}
          {{- fail "name or value not found" }}
        {{- end }}

        {{- $__name = index $__regexSlice 0 }}
        {{- $__value = index $__regexSlice 1 }}
      {{- else if kindIs "map" . }}
        {{- if and (hasKey . "name") (hasKey . "value") }}
          {{- $__name = get . "name" }}
          {{- $__value = get . "value" }}
        {{- end }}
      {{- end }}

      {{- if and $__name $__value }}
        {{- nindent 0 "" -}}- name: {{ $__name | toString | trim }}
        {{- nindent 2 "" -}}  value: {{ $__value | toString | trim }}
      {{- end }}
    {{- end }}
  {{- else if kindIs "map" . }}
    {{- range $k, $v := . }}
      {{- nindent 0 "" -}}- name: {{ $k | toString | trim }}
      {{- nindent 2 "" -}}  value: {{ $v | toString | trim }}
    {{- end }}
  {{- else }}
    {{- fail "securityContext.sysctls: Unsupported format" }}
  {{- end }}
{{- end }}
