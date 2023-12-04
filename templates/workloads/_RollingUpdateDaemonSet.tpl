{{- define "workloads.RollingUpdateDaemonSet" -}}
  {{- with . }}
    {{- if or .maxSurge .maxUnavailable }}
      {{- if .maxSurge }}
        {{- nindent 0 "" -}}maxSurge: {{ include "base.int.toString" .maxSurge }}
      {{- end }}

      {{- if .maxUnavailable }}
        {{- nindent 0 "" -}}maxUnavailable: {{ include "base.int.toString" .maxUnavailable }}
      {{- end }}
    {{- else }}
      {{- fail "maxSurge and maxUnavailable can not be 0 both" }}
    {{- end }}
  {{- end }}
{{- end }}
