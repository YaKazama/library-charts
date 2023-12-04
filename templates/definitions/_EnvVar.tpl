{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#envvar-v1-core

    {{- nindent 0 "" -}}- name: {{ .name }}
    {{- if .value }}
      {{- nindent 2 "" -}}value: {{ .value | toString }}
    {{- else if .valueFrom }}
      {{- nindent 2 "" -}}valueFrom:
    {{- end }}

  TODO:
  - valueFrom 未处理
*/ -}}
{{- define "definitions.EnvVar" -}}
  {{- with . }}
  {{- end }}
{{- end }}
