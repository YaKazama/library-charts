{{- define "definitions.AggregationRule" -}}
  {{- $__aggregationRule := list }}

  {{- $__aggregationRule = mustAppend $__aggregationRule (include "definitions.LabelSelector" . | fromYaml) }}
  {{- $__aggregationRule = mustCompact (mustUniq $__aggregationRule) }}
  {{- if $__aggregationRule }}
    {{- nindent 0 "" -}}clusterRoleSelectors:
    {{- toYaml $__aggregationRule | nindent 0 }}
  {{- end }}
{{- end }}
