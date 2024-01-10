{{- define "definitions.TypedObjectReference" -}}
  {{- with . }}
    {{- $__apiGroup := include "base.string" .apiGroup }}
    {{- if $__apiGroup }}
      {{- nindent 0 "" -}}apiGroup: {{ $__apiGroup }}
    {{- end }}

    {{- $__kind := include "base.string" (coalesce .kind "ClusterRole") }}
    {{- if $__kind }}
      {{- nindent 0 "" -}}kind: {{ $__kind }}
    {{- end }}

    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- else }}
      {{- fail "definitions.TypedLocalObjectReference: name not found." }}
    {{- end }}

    {{- $__namespace := include "base.string" .namespace }}
    {{- if $__namespace }}
      {{- nindent 0 "" -}}namespace: {{ $__namespace }}
    {{- end }}
  {{- end }}
{{- end }}
