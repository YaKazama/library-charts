{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#preferredschedulingterm-v1-core
*/ -}}
{{- define "definitions.PreferredSchedulingTerm" -}}
  {{- with . }}
    {{- range $k, $v := . }}
      {{- if $v }}
        {{- $__weight := include "base.int" (int (trimPrefix "weight" $k)) }}
        {{- $__preference := "" }}
        {{- if kindIs "slice" $v }}
          {{- $__expressions := list }}
          {{- $__fields := list }}

          {{- range $v }}
            {{- if .matchExpressions }}
              {{- if kindIs "slice" .matchExpressions }}
                {{- $__expressions = concat $__expressions .matchExpressions }}
              {{- else }}
                {{- fail "definitions.PreferredSchedulingTerm: matchExpressions not support, please use slice." }}
              {{- end }}
            {{- end }}
            {{- if .matchFields }}
              {{- if kindIs "slice" .matchFields }}
                {{- $__fields = concat $__fields .matchFields }}
              {{- else }}
                {{- fail "definitions.PreferredSchedulingTerm: matchFields not support, please use slice." }}
              {{- end }}
            {{- end }}
          {{- end }}

          {{- $__preference = include "definitions.NodeSelectorTerm" (dict "matchExpressions" (mustCompact (mustUniq $__expressions)) "matchFields" (mustCompact (mustUniq $__fields))) | fromYaml }}
        {{- else if kindIs "map" $v }}
          {{- $__preference = include "definitions.NodeSelectorTerm" $v | fromYaml }}
        {{- else }}
          {{- fail "definitions.PreferredSchedulingTerm: nodeAffinity.preferred not support, please use slice or map" }}
        {{- end }}

        {{- if and $__weight $__preference }}
          {{- if lt (int $__weight) 1 }}
            {{- $__weight = 1 }}
          {{- end }}
          {{- if gt (int $__weight) 100 }}
            {{- $__weight = 100 }}
          {{- end }}
          {{- nindent 0 "" -}}preference:
            {{- toYaml $__preference | nindent 2 }}
          {{- nindent 0 "" -}}weight: {{ $__weight }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
