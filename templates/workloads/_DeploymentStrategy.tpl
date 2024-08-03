{{- define "workloads.DeploymentStrategy" -}}
  {{- with . }}
    {{- $__type := include "base.string" .type }}

    {{- if or (empty $__type) (eq $__type "RollingUpdate") }}
      {{- $__rollingUpdate := include "workloads.RollingUpdateDeployment" .rollingUpdate | fromYaml }}
      {{- if $__rollingUpdate }}
        {{- nindent 0 "" -}}rollingUpdate:
          {{- toYaml $__rollingUpdate | nindent 2 }}
      {{- end }}
    {{- end }}

    {{- $__typeAllowed := list "RollingUpdate" "Recreate" }}
    {{- if mustHas $__type $__typeAllowed }}
      {{- nindent 0 "" -}}type: {{ $__type }}
    {{- end }}
  {{- end }}
{{- end }}
