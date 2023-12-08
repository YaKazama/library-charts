{{- define "definitions.HTTPIngressPath" -}}
  {{- $__pathTypeList := list "Exact" "Prefix" "ImplementationSpecific" }}
  {{- $__backendDict := dict }}

  {{- with . }}
    {{- if mustHas .pathType $__pathTypeList }}
      {{- nindent 0 "" -}}pathType: {{ .pathType }}
    {{- else }}
      {{- fail "definitions.HTTPIngressPath: .pathType must be exists" }}
    {{- end }}

    {{- if isAbs .path }}
      {{- nindent 0 "" -}}path: {{ coalesce .path "/" }}
    {{- else }}
      {{- fail "definitions.HTTPIngressPath: .path must be exists" }}
    {{- end }}

    {{- $__backendDict = include "definitions.IngressBackend" . | trim }}
    {{- if $__backendDict }}
      {{- nindent 0 "" -}}backend:
        {{- $__backendDict | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
