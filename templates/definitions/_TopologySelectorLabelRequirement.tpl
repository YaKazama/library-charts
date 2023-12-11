{{- define "definitions.TopologySelectorLabelRequirement" -}}
  {{- with . }}
    {{- nindent 0 "" -}}key: {{ .key }}
    {{- nindent 0 "" -}}values:
    {{- toYaml .values | nindent 0 }}
  {{- end }}
{{- end }}
