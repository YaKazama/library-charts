{{- define "definitions.ConfigMapKeySelector" -}}
  {{- with . }}
    {{- $__key := include "base.string" .key }}
    {{- if $__key }}
      {{- nindent 0 "" -}}key: {{ $__key }}
    {{- end }}

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
