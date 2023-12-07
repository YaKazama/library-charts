{{- define "definitions.IngressBackend" -}}
  {{- with . }}
    {{- if eq .backendType "resource" }}
      {{- nindent 0 "" -}}resource:
        {{- include "definitions.TypedLocalObjectReference" . | nindent 2 }}
    {{- else if eq .backendType "service" }}
      {{- nindent 0 "" -}}service:
        {{- include "definitions.IngressServiceBackend" . | nindent 2 }}
    {{- else }}
      {{- fail "definitions.IngressBackend: .backendType not support" }}
    {{- end }}
  {{- end }}
{{- end }}
