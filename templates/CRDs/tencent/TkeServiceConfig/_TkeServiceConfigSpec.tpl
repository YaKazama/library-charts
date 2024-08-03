{{- define "crds.tencent.TkeServiceConfig.TkeServiceConfigSpec" -}}
  {{- $__loadBalancer := include "crds.tencent.TkeServiceConfig.LoadBalancer" . | fromYaml }}
  {{- if $__loadBalancer }}
    {{- nindent 0 "" -}}loadBalancer:
      {{- toYaml $__loadBalancer | nindent 2 }}
  {{- end }}
{{- end }}
