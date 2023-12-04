{{- define "workloads.RollingUpdateDaemonSet" -}}
  {{- with . }}
    {{- if or .maxSurge .maxUnavailable }}
      {{- if .maxSurge }}
        {{- nindent 0 "" -}}maxSurge: {{ coalesce (include "base.int.toString" .maxSurge) (int 0) }}
      {{- end }}

      {{- if .maxUnavailable }}
        {{- nindent 0 "" -}}maxUnavailable: {{ coalesce (include "base.int.toString" .maxUnavailable) (int 1) }}
      {{- end }}
    {{- else }}
      {{- fail "maxSurge and maxUnavailable can not be 0 both" }}
    {{- end }}
  {{- end }}
{{- end }}
