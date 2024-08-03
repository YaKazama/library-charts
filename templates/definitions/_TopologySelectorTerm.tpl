{{- define "definitions.TopologySelectorTerm" -}}
  {{- with . }}
    {{- $__clean := list }}
    {{- if kindIs "map" .matchLabelExpressions }}
      {{- with .matchLabelExpressions }}
        {{- if and .key .values }}
          {{- $__clean = mustAppend $__clean (pick . "key" "values") }}
        {{- end }}
        {{- range $k, $v := (omit . "key" "values") }}
          {{- $__clean = mustAppend $__clean (dict "key" $k "values" $v) }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "slice" .matchLabelExpressions }}
      {{- range .matchLabelExpressions }}
        {{- if kindIs "map" . }}
          {{- with . }}
            {{- if and .key .values }}
              {{- $__clean = mustAppend $__clean (pick . "key" "values") }}
            {{- end }}
            {{- range $k, $v := (omit . "key" "values") }}
              {{- $__clean = mustAppend $__clean (dict "key" $k "values" $v) }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- $__val := dict }}
    {{- range ($__clean | mustUniq | mustCompact) }}
      {{- with (include "definitions.TopologySelectorLabelRequirement" . | fromYaml) }}
        {{- $__val = mustMerge $__val (dict .key .values) }}
      {{- end }}
    {{- end }}
    {{- $__matchLabelExpressions := list }}
    {{- range $k, $v := $__val }}
      {{- $__matchLabelExpressions = mustAppend $__matchLabelExpressions (dict "keys" $k "values" $v) }}
    {{- end }}
    {{- $__matchLabelExpressions = $__matchLabelExpressions | mustUniq |mustCompact }}
    {{- if $__matchLabelExpressions }}
      {{- nindent 0 "" -}}matchLabelExpressions:
      {{- toYaml $__matchLabelExpressions | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
