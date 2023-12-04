{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#keytopath-v1-core
*/ -}}
{{- define "definitions.KeyToPath" -}}
  {{- range . }}
    {{- if .key }}
      {{- nindent 0 "" -}}- key: {{ .key }}
    {{- else }}
      {{- fail "KeyToPath.key not found" }}
    {{- end }}
    {{- if .mode }}
      {{- nindent 2 "" -}}  mode: {{ (coalesce .mode 0644) | toString }}
    {{- end }}
    {{- if .path }}
      {{- nindent 2 "" -}}  path: {{ .path }}
    {{- end }}
  {{- end }}
{{- end }}
