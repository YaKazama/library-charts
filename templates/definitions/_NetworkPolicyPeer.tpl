{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#networkpolicypeer-v1-networking-k8s-io
*/ -}}
{{- define "definitions.NetworkPolicyPeer" }}
  {{- with . }}
    {{- if not (kindIs "map" .) }}
      {{- fail "not support! the type must be map." }}
    {{- end }}

    {{- $__clean := dict }}
    {{- $__regexSplit := "\\s+|\\s*[\\|,]\\s*" }}
    {{- if kindIs "string" .ipBlock }}
      {{- $__val := mustRegexSplit $__regexSplit .ipBlock -1 | mustUniq | mustCompact }}
      {{- if eq (len $__val) 1 }}
        {{- $_ := set $__clean "cidr" (mustFirst $__val) }}
      {{- else if ge (len $__val) 2 }}
        {{- $_ := set $__clean "cidr" (mustFirst $__val) }}
        {{- $_ := set $__clean "except" (mustRest $__val) }}
      {{- end }}
    {{- else if kindIs "map" .ipBlock }}
      {{- $__clean = mustMerge $__clean .ipBlock }}
    {{- else if kindIs "slice" .ipBlock }}
      {{- range (.ipBlock | mustUniq | mustCompact) }}
        {{- if kindIs "string" . }}
          {{- $__val := mustRegexSplit $__regexSplit . -1 | mustUniq | mustCompact }}
          {{- if eq (len $__val) 1 }}
            {{- $_ := set $__clean "cidr" (mustFirst $__val) }}
          {{- else if ge (len $__val) 2 }}
            {{- $_ := set $__clean "cidr" (mustFirst $__val) }}
            {{- $_ := set $__clean "except" (mustRest $__val) }}
          {{- end }}
        {{- else if kindIs "map" . }}
          {{- $__clean = mustMerge $__clean . }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- $__ipBlock := include "definitions.IPBlock" $__clean | fromYaml }}
    {{- if $__ipBlock }}
      {{- nindent 0 "" -}}ipBlock:
        {{- toYaml $__ipBlock | nindent 2 }}
    {{- end }}

    {{- $__clean := dict "matchExpressions" list "matchLabels" dict }}
    {{- with .namespaceSelector }}
      {{- $__valMatchExpressions := list }}
      {{- $__valMatchLabels := dict }}

      {{- if kindIs "map" . }}
        {{- if kindIs "slice" .matchExpressions }}
          {{- $__valMatchExpressions = concat $__valMatchExpressions .matchExpressions }}
        {{- end }}
        {{- if kindIs "map" .matchLabels }}
          {{- $__valMatchLabels = mustMerge $__valMatchLabels .matchLabels }}
        {{- end }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- if kindIs "map" . }}
            {{- if kindIs "slice" .matchExpressions }}
              {{- $__valMatchExpressions = concat $__valMatchExpressions .matchExpressions }}
            {{- end }}
            {{- if kindIs "map" .matchLabels }}
              {{- $__valMatchLabels = mustMerge $__valMatchLabels .matchLabels }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
      {{- $_ := set $__clean "matchExpressions" (concat $__clean.matchExpressions $__valMatchExpressions) }}
      {{- $_ := set $__clean "matchLabels" (mustMerge $__clean.matchLabels $__valMatchLabels) }}
    {{- end }}
    {{- $__namespaceSelector := include "definitions.LabelSelector" $__clean | fromYaml }}
    {{- if $__namespaceSelector }}
      {{- nindent 0 "" -}}namespaceSelector:
        {{- toYaml $__namespaceSelector | nindent 2 }}
    {{- end }}

    {{- $__clean := dict "matchExpressions" list "matchLabels" dict }}
    {{- with .podSelector }}
      {{- $__valMatchExpressions := list }}
      {{- $__valMatchLabels := dict }}

      {{- if kindIs "map" . }}
        {{- if kindIs "slice" .matchExpressions }}
          {{- $__valMatchExpressions = concat $__valMatchExpressions .matchExpressions }}
        {{- end }}
        {{- if kindIs "map" .matchLabels }}
          {{- $__valMatchLabels = mustMerge $__valMatchLabels .matchLabels }}
        {{- end }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- if kindIs "map" . }}
            {{- if kindIs "slice" .matchExpressions }}
              {{- $__valMatchExpressions = concat $__valMatchExpressions .matchExpressions }}
            {{- end }}
            {{- if kindIs "map" .matchLabels }}
              {{- $__valMatchLabels = mustMerge $__valMatchLabels .matchLabels }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
      {{- $_ := set $__clean "matchExpressions" (concat $__clean.matchExpressions $__valMatchExpressions) }}
      {{- $_ := set $__clean "matchLabels" (mustMerge $__clean.matchLabels $__valMatchLabels) }}
    {{- end }}
    {{- $__podSelector := include "definitions.LabelSelector" $__clean | fromYaml }}
    {{- if $__podSelector }}
      {{- nindent 0 "" -}}podSelector:
        {{- toYaml $__podSelector | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
