{{- define "definitions.IngressServiceBackend" -}}
  {{- with . }}
    {{- if .name }}
      {{- nindent 0 "" -}}name: {{ .name }}
    {{- end }}

    {{- $__port := include "definitions.ServiceBackendPort" . }}
    {{- if $__port }}
      {{- nindent 0 "" -}}port:
        {{- $__port | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
