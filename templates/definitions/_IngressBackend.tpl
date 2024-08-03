{{- define "definitions.IngressBackend" -}}
  {{- with . }}
    {{- if or .resource (and .name .kind .apiGroup) }}
      {{- $__resource := dict }}
      {{- if .resource }}
        {{- $__resource = include "definitions.TypedLocalObjectReference" .resource | fromYaml }}
      {{- else if and .name .kind .apiGroup }}
        {{- $__resource = include "definitions.TypedLocalObjectReference" (pick . "name" "kind" "apiGroup") | fromYaml }}
      {{- end }}
      {{- nindent 0 "" -}}resource:
        {{- toYaml $__resource | nindent 2 }}
    {{- else if or .service (and .name (or .portName .portNumber)) }}
      {{- $__service := dict }}
      {{- if .service }}
        {{- $__service = include "definitions.IngressServiceBackend" .service | fromYaml }}
      {{- else if and .name (or .portName .portNumber) }}
        {{- $__service = include "definitions.IngressServiceBackend" (pick . "name" "portName" "portNumber") | fromYaml }}
      {{- end }}
      {{- nindent 0 "" -}}service:
        {{- toYaml $__service | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
