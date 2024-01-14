{{- define "service.Service" -}}
  {{- $_ := set . "_kind" "Service" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- /*
    若 .Context 中存在 service 或 Servcie 关键字，则会使用上关键字替换原有的 .Context
    生效顺序： service, Service
  */ -}}
  {{- if .Context.service }}
    {{- $_ := set . "Context" .Context.service }}
  {{- else if .Context.Service }}
    {{- $_ := set . "Context" .Context.Service }}
  {{- end }}
  {{- $__spec := include "service.ServiceSpec" . | fromYaml }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- toYaml $__spec | nindent 2 }}
  {{- end }}
{{- end }}
