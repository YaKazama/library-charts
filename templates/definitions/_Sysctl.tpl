{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#sysctl-v1-core
  descr:
  - 可以支持 特定格式 (k = v) 的字符串、Slice、Map
*/ -}}
{{- define "definitions.Sysctl" -}}
  {{- $__regexSysctl := "[a-z_\\.]+\\s*=\\s*.+" }}

  {{- with . }}
    {{- $__name := "" }}
    {{- $__value := "" }}

    {{- if kindIs "string" . }}
      {{- if not (mustRegexMatch $__regexSysctl .) }}
        {{- fail "definitions.Sysctl: not a standard format, refer to the /etc/sysctl.conf - 1" }}
      {{- end }}
      {{- $__val := mustRegexSplit "\\s*=\\s*" . -1 }}
      {{- $__name = index $__val 0 }}
      {{- $__value = index $__val 1 }}
    {{- else if kindIs "map" . }}
      {{- if and (hasKey . "name") (hasKey . "value") }}
        {{- $__name = get . "name" }}
        {{- $__value = get . "value" }}
      {{- else }}
        {{- range $k, $v := . }}
          {{- $__name = $k }}
          {{- $__value = $v }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "string" . }}
          {{- if not (mustRegexMatch $__regexSysctl .) }}
            {{- fail "definitions.Sysctl: not a standard format, refer to the /etc/sysctl.conf - 2" }}
          {{- end }}
          {{- $__val := mustRegexSplit "\\s*=\\s*" . -1 }}
          {{- $__name = index $__val 0 }}
          {{- $__value = index $__val 1 }}
        {{- else if kindIs "map" . }}
          {{- if and (hasKey . "name") (hasKey . "value") }}
            {{- $__name = get . "name" }}
            {{- $__value = get . "value" }}
          {{- else }}
            {{- range $k, $v := . }}
              {{- $__name = $k }}
              {{- $__value = $v }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- if and $__name $__value }}
      {{- nindent 0 "" -}}name: {{ $__name }}
      {{- nindent 0 "" -}}value: {{ $__value }}
    {{- end }}
  {{- end }}
{{- end }}
