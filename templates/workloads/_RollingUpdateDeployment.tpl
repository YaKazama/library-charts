{{- define "workloads.RollingUpdateDeployment" -}}
  {{- with . }}
    {{- if or .maxSurge .maxUnavailable }}
      {{- if .maxSurge }}
        {{- nindent 0 "" -}}maxSurge: {{ coalesce (include "base.int.toString" .maxSurge) "25%" }}
      {{- end }}

      {{- if .maxUnavailable }}
        {{- nindent 0 "" -}}maxUnavailable: {{ coalesce (include "base.int.toString" .maxUnavailable) "25%" }}
      {{- end }}
    {{- else }}
      {{- fail "maxSurge and maxUnavailable can not be 0 both" }}
    {{- end }}
  {{- end }}
{{- end }}
