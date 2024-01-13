{{- define "cluster.ClusterRole" -}}
  {{- $_ := set . "_kind" "ClusterRole" }}

  {{- nindent 0 "" -}}apiVersion: rbac.authorization.k8s.io/v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__clean := dict }}
  {{- $__aggregationRuleSrc := pluck "aggregationRule" .Context .Values }}
  {{- range ($__aggregationRuleSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- $__clean = mustMerge $__clean . }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- $__aggregationRule := include "definitions.AggregationRule" $__clean | fromYaml }}
  {{- if $__aggregationRule }}
    {{- nindent 0 "" -}}aggregationRule:
      {{- toYaml $__aggregationRule | nindent 2 }}
  {{- end }}

  {{- $__clean := list }}
  {{- $__rulesSrc := pluck "rules" .Context .Values }}
  {{- range ($__rulesSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustAppend $__clean (pick . "apiGroups" "resources" "verbs") }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- $__clean = mustAppend $__clean (pick . "apiGroups" "resources" "verbs") }}
        {{- end }}
      {{- end }}
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
