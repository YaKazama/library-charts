{{- define "cluster.Role" -}}
  {{- $_ := set . "_kind" "Role" }}

  {{- nindent 0 "" -}}apiVersion: rbac.authorization.k8s.io/v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__clean := list }}
  {{- $__rulesSrc := pluck "rules" .Context .Values }}
  {{- range ($__rulesSrc | mustUniq | mustCompact) }}
    {{- if kindIs "slice" . }}
      {{- $__clean = concat $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__rules := list }}
  {{- range ($__clean | mustUniq | mustCompact) }}
    {{- $__rules = mustAppend $__rules (include "definitions.PolicyRule" . | fromYaml) }}
  {{- end }}
  {{- if $__rules }}
    {{- nindent 0 "" -}}rules:
    {{- toYaml $__rules | nindent 0 }}
  {{- end }}
{{- end }}
