{{- define "definitions.ExecAction" -}}
  {{- with . }}
    {{- $__regexSplit := "\\s+|\\s*[\\:\\/\\-,]\\s*" }}
    {{- $__command := include "base.fmt.slice" (dict "s" (list .command) "r") }}
    {{- if $__command }}
      {{- nindent 0 "" -}}command:
      {{- $__command | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
