{{- define "definitions.ObjectFieldSelector" -}}
  {{- with . }}
    {{- $__apiVersion := include "base.string" .apiVersion }}
    {{- if $__apiVersion }}
      {{- nindent 0 "" -}}apiVersion: {{ $__apiVersion }}
    {{- end }}

    {{- $__fieldPath := include "base.string" .fieldPath }}
    {{- if $__fieldPath }}
      {{- nindent 0 "" -}}fieldPath: {{ $__fieldPath }}
    {{- end }}
  {{- end }}
{{- end }}
