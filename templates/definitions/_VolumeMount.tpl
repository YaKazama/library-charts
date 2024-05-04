{{- define "definitions.VolumeMount" -}}
  {{- with . }}
    {{- $__mountPath := include "base.string" .mountPath }}
    {{- if $__mountPath }}
      {{- nindent 0 "" -}}mountPath: {{ $__mountPath }}
    {{- end }}

    {{- $__mountPropagation := include "base.string" .mountPropagation }}
    {{- if $__mountPropagation }}
      {{- nindent 0 "" -}}mountPropagation: {{ $__mountPropagation }}
    {{- end }}

    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name | trim | lower }}
    {{- end }}

    {{- $__readOnly := include "base.bool" .readOnly }}
    {{- if $__readOnly }}
      {{- nindent 0 "" -}}readOnly: {{ $__readOnly }}
    {{- end }}

    {{- $__subPath := include "base.string" .subPath }}
    {{- $__subPathExpr := include "base.string" .subPathExpr }}
    {{- if and $__subPath (not $__subPathExpr) }}
      {{- nindent 0 "" -}}subPath: {{ $__subPath }}
    {{- else if and $__subPathExpr (not $__subPath) }}
      {{- nindent 0 "" -}}subPathExpr: {{ $__subPathExpr }}
    {{- end }}
  {{- end }}
{{- end }}
