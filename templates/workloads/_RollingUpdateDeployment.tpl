{{- define "workloads.RollingUpdateDeployment" -}}
  {{- with . }}
    {{- $__maxSurge := include "base.fmt" (dict "s" .maxSurge "r" "^\\d+(\\%)?$") }}
    {{- $__maxUnavailable := include "base.fmt" (dict "s" .maxUnavailable "r" "^\\d+(\\%)?$") }}

    {{- if or $__maxSurge $__maxUnavailable }}
      {{- if $__maxSurge }}
        {{- nindent 0 "" -}}maxSurge: {{ $__maxSurge }}
      {{- end }}

      {{- if $__maxUnavailable }}
        {{- nindent 0 "" -}}maxUnavailable: {{ $__maxUnavailable }}
      {{- end }}
    {{- else }}
      {{- fail "workloads.RollingUpdateDaemonSet: maxSurge and maxUnavailable can not be 0 both" }}
    {{- end }}
  {{- end }}
{{- end }}
