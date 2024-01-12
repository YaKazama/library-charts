{{- define "definitions.ResourceRequirements" -}}
  {{- with . }}
    {{- $__clean := list }}
    {{- if kindIs "string" .claims }}
      {{- $__clean = mustAppend $__clean .claims }}
    {{- else if kindIs "map" .claims }}
      {{- $__clean = mustAppend $__clean (dig "name" "" .claims) }}
    {{- else if kindIs "slice" .claims }}
      {{- range .claims }}
        {{- if kindIs "string" . }}
          {{- $__clean = mustAppend $__clean . }}
        {{- else if kindIs "map" . }}
          {{- $__clean = mustAppend $__clean (dig "name" "" .) }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- $__clean = $__clean | mustUniq | mustCompact }}
    {{- $__claims := include "base.fmt.slice" (dict "s" $__clean "define" "definitions.ResourceClaim") }}
    {{- if $__claims }}
      {{- nindent 0 "" -}}claims:
      {{- $__claims | nindent 0 }}
    {{- end }}

    {{- if .limits }}
      {{- if kindIs "map" .limits }}
        {{- nindent 0 "" -}}limits:
          {{- toYaml .limits | nindent 2 }}
      {{- else }}
        {{- fail "definitions.ResourceRequirements: limits not support, please use map." }}
      {{- end }}
    {{- end }}

    {{- if .requests }}
      {{- if kindIs "map" .requests }}
        {{- nindent 0 "" -}}requests:
          {{- toYaml .requests | nindent 2 }}
      {{- else }}
        {{- fail "definitions.ResourceRequirements: requests not support, please use map." }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
