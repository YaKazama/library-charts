{{- /*
reference:
- https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-configuration?hl=zh-cn#configuring_ingress_features_through_backendconfig_parameters
*/ -}}
{{- define "crds.gcp.BackendConfig" -}}
  {{- $_ := set . "_kind" "BackendConfig" }}

  {{- nindent 0 "" -}}apiVersion: cloud.google.com/v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__spec := include "crds.gcp.BackendConfig.BackendConfigSpec" . | fromYaml }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- toYaml $__spec | nindent 2 }}
  {{- end }}
{{- end }}
