{{- define "definitions.IngressTLS" -}}
  {{- $__hosts := list }}
  {{- $__regexHost := "^(\\*\\.)?([a-zA-Z0-9][-a-zA-Z0-9]{0,62})(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$" }}
  {{- $__regexHostSplit := "(,)?\\s+" }}

  {{- with . }}
    {{- if kindIs "string" .hosts }}
      {{- range (mustRegexSplit $__regexHostSplit .hosts -1) }}
        {{- if mustRegexMatch $__regexHost . }}
          {{- $__hosts = mustAppend $__hosts . }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "slice" .hosts }}
      {{- $__hosts = concat $__hosts .hosts }}
    {{- else }}
      {{- fail "definitions.IngressTLS: .hosts not support" }}
    {{- end }}

    {{- $__hostsClean := mustCompact (mustUniq $__hosts) }}
    {{- if $__hostsClean }}
      {{- nindent 0 "" -}}hosts:
      {{- /*
        descr:
        - 有特殊字符, 故此处不使用 toYaml 函数, 改为递归打印
      */ -}}
      {{- range $__hostsClean }}
        {{- printf "- %s" (. | quote) | nindent 0 }}
      {{- end }}
    {{- end }}

    {{- if .secretName }}
      {{- nindent 0 "" -}}secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
{{- end }}
