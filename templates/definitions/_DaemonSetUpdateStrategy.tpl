{{- define "definitions.DaemonSetUpdateStrategy" -}}
  {{- $__typeList := list "RollingUpdate" "OnDelete" }}

  {{- with . }}
    {{- if mustHas .type $__typeList }}
      {{- nindent 0 "" -}}type: {{ default "RollingUpdate" .type }}

      {{- if and (eq .type "RollingUpdate") .rollingUpdate }}
        {{- $__rollingUpdate := include "workloads.RollingUpdateDaemonSet" .rollingUpdate }}
        {{- if $__rollingUpdate }}
          {{- nindent 0 "" -}}rollingUpdate:
            {{- $__rollingUpdate | indent 2 }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
