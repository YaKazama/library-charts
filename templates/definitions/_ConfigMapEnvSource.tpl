{{- define "definitions.ConfigMapEnvSource" -}}
  {{- with . }}
    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- end }}

    {{- $__optional := include "base.bool" .optional }}
    {{- if $__optional }}
      {{- nindent 0 "" -}}optional: {{ $__optional }}
    {{- end }}
  {{- end }}
{{- end }}
