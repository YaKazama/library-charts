{{- define "workloads.DeploymentStrategy" -}}
  {{- $__typeList := list "RollingUpdate" "Recreate" }}

  {{- with . }}
    {{- if mustHas .type $__typeList }}
      {{- nindent 0 "" -}}type: {{ default "RollingUpdate" .type }}

      {{- if and (eq .type "RollingUpdate") .rollingUpdate }}
        {{- $__rollingUpdate := include "workloads.RollingUpdateDeployment" .rollingUpdate }}
        {{- if $__rollingUpdate }}
          {{- nindent 0 "" -}}rollingUpdate:
            {{- $__rollingUpdate | indent 2 }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
