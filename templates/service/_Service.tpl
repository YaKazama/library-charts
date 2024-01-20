{{- define "service.Service" -}}
  {{- $_ := set . "_kind" "Service" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}

  {{- /*
    - 若 .Context 中存在 service 或 Servcie 关键字，则会使用关键字的内容替换原有的 .Context
      - 生效顺序： service, Service
    - 如果 service 或 Service 中定义了 annotations 也会进行同步
  */ -}}
  {{- if or .Context.service .Context.Service }}
    {{- $__serviceSrc := list .Context.service .Context.Service }}
    {{- $__clean := dict }}
    {{- range ($__serviceSrc | mustUniq | mustCompact) }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
    {{- $_ := set . "Context" (mustMerge $__clean .Context) }}
  {{- end }}

  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__spec := include "service.ServiceSpec" . | fromYaml }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- toYaml $__spec | nindent 2 }}
  {{- end }}
{{- end }}
