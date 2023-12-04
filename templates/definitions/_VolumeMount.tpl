{{- define "definitions.VolumeMount" -}}
  {{- with . }}
    {{- if .name }}
      {{- nindent 0 "" -}}name: {{ .name }}
    {{- else }}
      {{- fail "volumeMounts.name not found" }}
    {{- end }}

    {{- if .mountPath }}
      {{- nindent 0 "" -}}mountPath: {{ .mountPath }}
    {{- end }}

    {{- if .mountPropagation }}
      {{- nindent 0 "" -}}mountPropagation: {{ .mountPropagation }}
    {{- end }}

    {{- if and .readOnly (kindIs "bool" .readOnly) }}
      {{- nindent 0 "" -}}readOnly: true
    {{- end }}

    {{- if and .subPath (not .subPathExpr) }}
      {{- nindent 0 "" -}}subPath: {{ .subPath }}
    {{- else if and .subPathExpr (not .subPath) }}
      {{- nindent 0 "" -}}subPathExpr: {{ .subPathExpr }}
    {{- end }}
  {{- end }}
{{- end }}
