{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#podaffinity-v1-core
*/ -}}
{{- define "definitions.PodAffinity" -}}
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
          {{- fail "definitions.PodAffinity: not support, please use slice or map" }}
        {{- end }}
        {{- range $k, $v := $__val }}
          {{- $__preferred = mustAppend $__preferred (include "definitions.WeightedPodAffinityTerm" (dict $k $v) | fromYaml) }}
        {{- end }}
        {{- if $__preferred }}
          {{- nindent 0 "" -}}preferredDuringSchedulingIgnoredDuringExecution:
          {{- toYaml $__preferred | nindent 0 }}
        {{- end }}
      {{- else }}
        {{- fail "definitions.PodAffinity: preferred not support, please use map" }}
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
          {{- fail "definitions.PodAffinity: required not support, please use slice or map" }}
        {{- end }}

        {{- $__required = mustAppend $__required (include "definitions.PodAffinityTerm" $__val | fromYaml) }}

        {{- if $__required }}
          {{- nindent 0 "" -}}requiredDuringSchedulingIgnoredDuringExecution:
          {{- toYaml $__required | nindent 0 }}
        {{- end }}
      {{- else }}
        {{- fail "definitions.PodAffinity: required not support, please use slice or map" }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
