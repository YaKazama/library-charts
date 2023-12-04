{{- define "workloads.DeploymentStrategy" -}}
  {{- $__typeList := list "RollingUpdate" "Recreate" }}

  {{- with . }}
    {{- if mustHas .type $__typeList }}
      {{- nindent 0 "" -}}type: {{ default "RollingUpdate" .type }}

      {{- if and (eq .type "RollingUpdate") .rollingUpdate }}
        {{- nindent 0 "" -}}rollingUpdate:
          {{- include "workloads.RollingUpdateDeployment" .rollingUpdate | indent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
