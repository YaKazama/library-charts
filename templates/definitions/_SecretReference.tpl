{{- define "definitions.SecretReference" -}}
  {{- with . }}
    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- end }}

    {{- $__namespace := include "base.string" .namespace }}
    {{- if $__namespace }}
      {{- nindent 0 "" -}}namespace: {{ $__namespace }}
    {{- end }}
  {{- end }}
{{- end }}
