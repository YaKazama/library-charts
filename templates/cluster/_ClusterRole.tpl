{{- define "cluster.ClusterRole" -}}
  {{- $_ := set . "_kind" "ClusterRole" }}

  {{- nindent 0 "" -}}apiVersion: rbac.authorization.k8s.io/v1
  {{- nindent 0 "" -}}kind: ClusterRole
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- if or ._CTX.aggregationRule .Values.aggregationRule }}
    {{- $__aggregationRule := dict }}

    {{- if kindIs "map" ._CTX.aggregationRule }}
      {{- $__aggregationRule = mustMerge $__aggregationRule ._CTX.aggregationRule }}
    {{- end }}
    {{- if kindIs "map" .Values.aggregationRule }}
      {{- $__aggregationRule = mustMerge $__aggregationRule .Values.aggregationRule }}
    {{- end }}

    {{- $__clusterRoleSelectors := include "definitions.AggregationRule" $__aggregationRule | fromYaml }}
    {{- if $__clusterRoleSelectors }}
      {{- nindent 0 "" -}}aggregationRule:
        {{- toYaml $__clusterRoleSelectors | nindent 2 }}
    {{- end }}
  {{- end }}

  {{- if or ._CTX.rules .Values.rules }}
    {{- $__policyRules := list }}
    {{- $__rules := list }}

    {{- if ._CTX.rules }}
      {{- if kindIs "slice" ._CTX.rules }}
        {{- $__policyRules = concat $__policyRules ._CTX.rules }}
      {{- end }}
    {{- end }}
    {{- if .Values.rules }}
      {{- if kindIs "slice" .Values.rules }}
        {{- $__policyRules = concat $__policyRules .Values.rules }}
      {{- end }}
    {{- end }}

    {{- range $__policyRules }}
      {{- $__rules = mustAppend $__rules (include "definitions.PolicyRule" . | fromYaml) }}
    {{- end }}
    {{- if $__rules }}
      {{- nindent 0 "" -}}rules:
      {{- toYaml $__rules | nindent 0 }}
    {{- end }}
  {{- end }}

{{- end }}
