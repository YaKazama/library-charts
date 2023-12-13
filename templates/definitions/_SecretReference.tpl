{{- define "definitions.SecretReference" -}}
  {{- with . }}
    {{- if .name }}
      {{- nindent 0 "" -}}name: {{ .name }}
    {{- end }}
    {{- if .namespace }}
      {{- nindent 0 "" -}}namespace: {{ .namespace }}
    {{- end }}
  {{- end }}
{{- end }}
