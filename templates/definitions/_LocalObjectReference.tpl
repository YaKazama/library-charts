{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#localobjectreference-v1-core
*/ -}}
{{- define "definitions.LocalObjectReference" -}}
  {{- if kindIs "map" . }}
    {{- with .name }}
      {{- nindent 0 "" -}}name: {{ .name }}
    {{- end }}
  {{- else }}
    {{- nindent 0 "" -}}name: {{ . | toString }}
  {{- end }}
{{- end }}
