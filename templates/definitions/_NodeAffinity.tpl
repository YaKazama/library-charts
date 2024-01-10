{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nodeaffinity-v1-core
*/ -}}
{{- define "definitions.NodeAffinity" -}}
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
          {{- fail "definitions.PreferredSchedulingTerm: not support, please use slice or map" }}
        {{- end }}
        {{- range $k, $v := $__val }}
          {{- $__preferred = mustAppend $__preferred (include "definitions.PreferredSchedulingTerm" (dict $k $v) | fromYaml) }}
        {{- end }}
        {{- if $__preferred }}
          {{- nindent 0 "" -}}preferredDuringSchedulingIgnoredDuringExecution:
          {{- toYaml $__preferred | nindent 0 }}
        {{- end }}
      {{- else }}
        {{- fail "definitions.NodeAffinity: preferred not support, please use map or slice" }}
      {{- end }}
    {{- end }}

    {{- if .required }}
      {{- if or (kindIs "slice" .required) (kindIs "map" .required) }}
        {{- $__required := include "definitions.NodeSelector" .required }}
        {{- if $__required }}
          {{- nindent 0 "" -}}requiredDuringSchedulingIgnoredDuringExecution:
            {{- $__required | indent 2 }}
        {{- end }}
      {{- else }}
        {{- fail "definitions.NodeAffinity: required not support, please use slice or map" }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
