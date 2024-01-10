{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#localobjectreference-v1-core
*/ -}}
{{- define "definitions.LocalObjectReference" -}}
  {{- with . }}
    {{- if kindIs "string" . }}
      {{- nindent 0 "" -}}name: {{ . }}
    {{- else if kindIs "map" . }}
      {{- nindent 0 "" -}}name: {{ .name }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- include "definitions.LocalObjectReference" . }}
      {{- end }}
    {{- else }}
      {{- fail "definitions.LocalObjectReference: type not support" }}
    {{- end }}
  {{- end }}
{{- end }}
