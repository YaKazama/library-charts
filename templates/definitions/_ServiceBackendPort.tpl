{{- define "definitions.ServiceBackendPort" -}}
  {{- with . }}
    {{- /*
      name 与 number 同时出现时 number 先生效
    */ -}}
    {{- if .number }}
      {{- $__number := include "base.int.scope" (list .number 1 65535) }}
      {{- if $__number }}
        {{- nindent 0 "" -}}number: {{ $__number }}
      {{- end }}
    {{- else if .name }}
      {{- $__name := include "base.string" .name }}
      {{- if $__name }}
        {{- nindent 0 "" -}}name: {{ $__name }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
