{{- define "definitions.AggregationRule" -}}
  {{- with . }}
    {{- $__clusterRoleSelectors := list }}
    {{- $__clusterRoleSelectors = mustAppend $__clusterRoleSelectors (include "definitions.LabelSelector" .clusterRoleSelectors | fromYaml) }}
    {{- $__clusterRoleSelectors = $__clusterRoleSelectors | mustUniq | mustCompact }}
    {{- if $__clusterRoleSelectors }}
      {{- nindent 0 "" -}}clusterRoleSelectors:
      {{- toYaml $__clusterRoleSelectors | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
