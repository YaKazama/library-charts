{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#weightedpodaffinityterm-v1-core
*/ -}}
{{- define "definitions.WeightedPodAffinityTerm" -}}
  {{- with . }}
    {{- range $k, $v := . }}
      {{- if $v }}
        {{- $__weight := include "base.int" (int (trimPrefix "weight" $k)) }}
        {{- $__podAffinityTerm := "" }}
        {{- if kindIs "slice" $v }}
          {{- $__expressions := list }}
          {{- $__labels := dict }}

          {{- range $v }}
            {{- if .matchExpressions }}
              {{- if kindIs "slice" .matchExpressions }}
                {{- $__expressions = concat $__expressions .matchExpressions }}
              {{- else }}
                {{- fail "definitions.WeightedPodAffinityTerm: matchExpressions not support, please use slice." }}
              {{- end }}
            {{- end }}
            {{- if .matchLabels }}
              {{- if kindIs "map" .matchLabels }}
                {{- $__labels = mustMerge $__labels .matchLabels }}
              {{- else }}
                {{- fail "definitions.WeightedPodAffinityTerm: matchLabels not support, please use map." }}
              {{- end }}
            {{- end }}
          {{- end }}

          {{- $__podAffinityTerm = include "definitions.NodeSelectorTerm" (dict "matchExpressions" (mustCompact (mustUniq $__expressions)) "matchLabels" (mustCompact (mustUniq $__labels))) | fromYaml }}
        {{- else if kindIs "map" $v }}
          {{- $__podAffinityTerm = include "definitions.PodAffinityTerm" $v | fromYaml }}
        {{- else }}
          {{- fail "definitions.WeightedPodAffinityTerm: nodeAffinity.preferred not support, please use slice or map" }}
        {{- end }}

        {{- if and $__weight $__podAffinityTerm }}
          {{- if lt (int $__weight) 1 }}
            {{- $__weight = 1 }}
          {{- end }}
          {{- if gt (int $__weight) 100 }}
            {{- $__weight = 100 }}
          {{- end }}
          {{- nindent 0 "" -}}podAffinityTerm:
            {{- toYaml $__podAffinityTerm | nindent 2 }}
          {{- nindent 0 "" -}}weight: {{ $__weight }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
