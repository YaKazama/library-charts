{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#networkpolicyspec-v1-networking-k8s-io
*/ -}}
{{- define "cluster.NetworkPolicySpec" -}}

  {{- /*
    合并 .Context .Values 中的 egress
    支持 slice, map 两种类型
  */ -}}
  {{- $__clean := list }}
  {{- $__egressSrc := pluck "egress" .Context .Values }}
  {{- range ($__egressSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustAppend $__clean . }}
    {{- else if kindIs "slice" . }}
      {{- $__clean = concat $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__egress := list }}
  {{- range (($__clean | mustUniq | mustCompact)) }}
    {{- $__egress = mustAppend $__egress (include "definitions.NetworkPolicyEgressRule" . | fromYaml) }}
  {{- end }}
  {{- if $__egress | mustUniq | mustCompact }}
    {{- nindent 0 "" -}}egress:
    {{- toYaml $__egress | nindent 0 }}
  {{- end }}

  {{- /*
    合并 .Context .Values 中的 ingress
    支持 slice, map 两种类型
  */ -}}
  {{- $__clean := list }}
  {{- $__ingressSrc := pluck "ingress" .Context .Values }}
  {{- range ($__ingressSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustAppend $__clean . }}
    {{- else if kindIs "slice" . }}
      {{- $__clean = concat $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__ingress := list }}
  {{- range (($__clean | mustUniq | mustCompact)) }}
    {{- $__ingress = mustAppend $__ingress (include "definitions.NetworkPolicyIngressRule" . | fromYaml) }}
  {{- end }}
  {{- if $__ingress | mustUniq | mustCompact }}
    {{- nindent 0 "" -}}ingress:
    {{- toYaml $__ingress | nindent 0 }}
  {{- end }}

  {{- $__clean := dict "matchExpressions" list "matchLabels" dict }}
  {{- $__podSelectorSrc := pluck "podSelector" .Context .Values }}
  {{- range ($__podSelectorSrc | mustUniq | mustCompact) }}
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

  {{- $__policyTypes := include "base.fmt.slice" (dict "s" (pluck "policyTypes" .Context .Values)) }}
  {{- if $__policyTypes }}
    {{- nindent 0 "" -}}policyTypes:
    {{- $__policyTypes | nindent 0 }}
  {{- end }}
{{- end }}
