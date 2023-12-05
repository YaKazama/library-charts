{{- define "definitions.TypedLocalObjectReference" -}}
  {{- with . }}
    {{- if .apiGroup }}
      {{- nindent 0 "" -}}apiGroup: {{ .apiGroup }}
    {{- end }}
    {{- if .kind }}
      {{- nindent 0 "" -}}kind: {{ .kind }}
    {{- end }}
    {{- if .name }}
      {{- nindent 0 "" -}}name: {{ .name }}
    {{- end }}
  {{- end }}
{{- end }}
