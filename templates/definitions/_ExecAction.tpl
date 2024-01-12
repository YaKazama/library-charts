{{- define "definitions.ExecAction" -}}
  {{- with . }}
    {{- $__regexSplit := "\\s+" }}
    {{- $__command := include "base.fmt.slice" (dict "s" (list .command) "r" $__regexSplit "sliceRedirect" true) }}
    {{- if $__command }}
      {{- nindent 0 "" -}}command:
      {{- $__command | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
