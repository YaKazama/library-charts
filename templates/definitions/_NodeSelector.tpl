{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nodeselector-v1-core
*/ -}}
{{- define "definitions.NodeSelector" -}}
  {{- with . }}
    {{- $__nodeSelectorTerms := list }}

    {{- if kindIs "slice" . }}
      {{- $__expressions := list }}
      {{- $__fields := list }}

      {{- range . }}
        {{- if .matchExpressions }}
          {{- if kindIs "slice" .matchExpressions }}
            {{- $__expressions = concat $__expressions .matchExpressions }}
          {{- else }}
            {{- fail "definitions.NodeSelector: matchExpressions not support, please use slice." }}
          {{- end }}
        {{- end }}
        {{- if .matchFields }}
          {{- if kindIs "slice" .matchFields }}
            {{- $__fields = concat $__fields .matchFields }}
          {{- else }}
            {{- fail "definitions.NodeSelector: matchFields not support, please use slice." }}
          {{- end }}
        {{- end }}
      {{- end }}

      {{- $__nodeSelectorTerms = mustAppend $__nodeSelectorTerms (include "definitions.NodeSelectorTerm" (dict "matchExpressions" (mustCompact (mustUniq $__expressions)) "matchFields" (mustCompact (mustUniq $__fields))) | fromYaml) }}
    {{- else if kindIs "map" . }}
      {{- $__nodeSelectorTerms = mustAppend $__nodeSelectorTerms (include "definitions.NodeSelectorTerm" . | fromYaml) }}
    {{- else }}
      {{- fail "definitions.NodeSelector: nodeAffinity.required not support, please use slice or map" }}
    {{- end }}

    {{- if $__nodeSelectorTerms }}
      {{- nindent 0 "" -}}nodeSelectorTerms:
      {{- toYaml $__nodeSelectorTerms | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
