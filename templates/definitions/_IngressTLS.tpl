{{- define "definitions.IngressTLS" -}}
  {{- with . }}
    {{- /*
      hosts 可以不填但 base.fmt.slice 不能传入空值
    */ -}}
    {{- if .hosts }}
      {{- $__regexHost := "^(\\*\\.)?([a-zA-Z0-9][-a-zA-Z0-9]{0,62})(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$" }}
      {{- $__hosts := include "base.fmt.slice" (dict "s" (list .hosts) "c" $__regexHost) }}
      {{- nindent 0 "" -}}hosts:
      {{- $__hosts | nindent 0 }}
    {{- end }}

    {{- $__secretName := include "base.string" .secretName }}
    {{- if $__secretName }}
      {{- nindent 0 "" -}}secretName: {{ $__secretName }}
    {{- end }}
  {{- end }}
{{- end }}
