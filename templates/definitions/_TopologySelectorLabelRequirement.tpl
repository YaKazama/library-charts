{{- define "definitions.TopologySelectorLabelRequirement" -}}
  {{- with . }}
    {{- $__key := include "base.string" .key }}
    {{- if $__key }}
      {{- nindent 0 "" -}}key: {{ $__key }}
    {{- end }}

    {{- $__values := include "base.fmt.slice" (dict "s" (list .values)) }}
    {{- if $__values }}
      {{- nindent 0 "" -}}values:
      {{- $__values | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
