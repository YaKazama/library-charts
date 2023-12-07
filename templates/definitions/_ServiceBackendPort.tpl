{{- define "definitions.ServiceBackendPort" -}}
  {{- with . }}
    {{- if .portName }}
      {{- nindent 0 "" -}}name: {{ .portName }}
    {{- else if .portNumber }}
      {{- nindent 0 "" -}}number: {{ toString .portNumber }}
    {{- end }}
  {{- end }}
{{- end }}
