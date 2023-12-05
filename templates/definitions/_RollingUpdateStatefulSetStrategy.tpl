{{- define "definitions.RollingUpdateStatefulSetStrategy" -}}
  {{- with . }}
    {{- if .maxUnavailable }}
      {{- nindent 0 "" -}}maxUnavailable: {{ coalesce (include "base.int.toString" .maxUnavailable) "1" }}
    {{- else }}
      {{- fail "definitions.RollingUpdateStatefulSetStrategy: maxUnavailable can not be 0" }}
    {{- end }}

    {{- if or .partition (eq 0 (int .partition)) }}
      {{- nindent 0 "" -}}partition: {{ coalesce (toString .partition) "0" }}
    {{- end }}
  {{- end }}
{{- end }}
