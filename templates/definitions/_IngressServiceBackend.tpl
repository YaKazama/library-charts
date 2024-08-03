{{- define "definitions.IngressServiceBackend" -}}
  {{- with . }}
    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- end }}

    {{- $__clean := dict }}
    {{- $__clean = mustMerge $__clean (coalesce .port (dict "name" .portName "number" .portNumber)) }}
    {{- $__port := include "definitions.ServiceBackendPort" $__clean | fromYaml }}
    {{- if $__port }}
      {{- nindent 0 "" -}}port:
        {{- toYaml $__port | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
