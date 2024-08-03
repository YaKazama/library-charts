{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#podantiaffinity-v1-core
*/ -}}
{{- define "definitions.PodAntiAffinity" -}}
  {{- with . }}
    {{- if .preferred }}
      {{- if or (kindIs "slice" .preferred) (kindIs "map" .preferred) }}
        {{- $__preferred := list }}
        {{- $__val := dict }}

        {{- if kindIs "slice" .preferred }}
          {{- range .preferred }}
            {{- $__val = mustMerge $__val . }}
          {{- end }}
        {{- else if kindIs "map" .preferred }}
            {{- $__val = mustMerge $__val .preferred }}
        {{- else }}
          {{- fail "definitions.PodAntiAffinity: not support, please use slice or map" }}
        {{- end }}
        {{- range $k, $v := $__val }}
          {{- $__preferred = mustAppend $__preferred (include "definitions.WeightedPodAffinityTerm" (dict $k $v) | fromYaml) }}
        {{- end }}
        {{- if $__preferred }}
          {{- nindent 0 "" -}}preferredDuringSchedulingIgnoredDuringExecution:
          {{- toYaml $__preferred | nindent 0 }}
        {{- end }}
      {{- else }}
        {{- fail "definitions.PodAntiAffinity: preferred not support, please use map" }}
      {{- end }}
    {{- end }}

    {{- if .required }}
      {{- if or (kindIs "slice" .required) (kindIs "map" .required) }}

        {{- $__required := list }}
        {{- $__val := dict }}

        {{- if kindIs "slice" .required }}
          {{- range .required }}
            {{- $__val = mustMerge $__val . }}
          {{- end }}
        {{- else if kindIs "map" .required }}
            {{- $__val = mustMerge $__val .required }}
        {{- else }}
          {{- fail "definitions.PodAntiAffinity: required not support, please use slice or map" }}
        {{- end }}

        {{- $__required = mustAppend $__required (include "definitions.PodAffinityTerm" $__val | fromYaml) }}

        {{- if $__required }}
          {{- nindent 0 "" -}}requiredDuringSchedulingIgnoredDuringExecution:
          {{- toYaml $__required | nindent 0 }}
        {{- end }}
      {{- else }}
        {{- fail "definitions.PodAntiAffinity: required not support, please use slice or map" }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}


{{- define "definitions.PodAntiAffinity1" -}}
  {{- if .required }}
    {{- $__requiredPAT := include "definitions.PodAffinityTerm" .required }}
    {{- if $__requiredPAT }}
      {{- nindent 0 "" -}}requiredDuringSchedulingIgnoredDuringExecution:
      {{- $__requiredPAT | indent 0 }}
    {{- end }}
  {{- end }}
  {{- if .preferred }}
    {{- $__preferredWPAT := include "definitions.WeightedPodAffinityTerm" .preferred }}
    {{- if $__preferredWPAT }}
      {{- nindent 0 "" -}}preferredDuringSchedulingIgnoredDuringExecution:
      {{- $__preferredWPAT | indent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
