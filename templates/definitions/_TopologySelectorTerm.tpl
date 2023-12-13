{{- define "definitions.TopologySelectorTerm" -}}
  {{- with . }}
    {{- $__matchLabelExpressions := list }}

    {{- range $k, $v := . }}
      {{- $__val := list }}

      {{- if kindIs "string" $v }}
        {{- range (mustRegexSplit "(,)?\\s+" $v -1) }}
          {{- $__val = mustAppend $__val . }}
        {{- end }}
      {{- else if kindIs "slice" $v }}
        {{- $__val = concat $__val $v }}
      {{- else }}
        {{- fail "configStorage.StorageClass: allowedTopologies 106 not support" }}
      {{- end }}

      {{- $__matchLabelExpressions = mustAppend $__matchLabelExpressions (include "definitions.TopologySelectorLabelRequirement" (dict "key" $k "values" $__val) | fromYaml) }}
    {{- end }}

    {{- $__matchLabelExpressions = mustCompact (mustUniq $__matchLabelExpressions) }}
    {{- if $__matchLabelExpressions }}
      {{- nindent 0 "" -}}matchLabelExpressions:
      {{- toYaml $__matchLabelExpressions | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
