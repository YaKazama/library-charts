{{- define "definitions.HTTPHeader" -}}
  {{- with . }}
    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- end }}

    {{- $__value := include "base.string" .value }}
    {{- if $__value }}
      {{- nindent 0 "" -}}value: {{ $__value }}
    {{- end }}
  {{- end }}
{{- end }}
