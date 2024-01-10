{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#labelselectorrequirement-v1-meta
  - https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/labels/
  - https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#resources-that-support-set-based-requirements
  - https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/labels/#label-selectors
*/ -}}
{{- define "definitions.LabelSelectorRequirement" -}}
  {{- with . }}
    {{- $__key := "" }}
    {{- $__operator := "" }}
    {{- $__values := "" }}

    {{- if kindIs "map" . }}
      {{- $__key = get . "key" }}
      {{- $__operator = get . "operator" }}
      {{- $__values = include "base.fmt.slice" (dict "s" (pluck "values" .)) }}
      {{- if not (or $__key $__operator $__values) }}
        {{- fail "definitions.LabelSelectorRequirement: matchExpressions or matchFields (map) key, operator and values must be exists" }}
      {{- end }}
    {{- else if kindIs "string" . }}
      {{- $__regexSplit := "\\s+|\\s*,\\s*" }}
      {{- $__v := mustRegexReplaceAll $__regexSplit . " " | replace "(" "" | replace ")" "" }}
      {{- $__regexSlice := mustRegexSplit " " $__v -1 }}

      {{- $__regexEquality := "^[A-Za-z0-9-]+\\s+([=]{1,2}|!=)\\s+[A-Za-z0-9-]+$" }}
      {{- $__regexSet := "^[A-Za-z0-9-]+\\s+([iI][nN]|[nN][oO][tT][iI][nN])\\s+\\(([A-Za-z0-9-]+(\\s+|\\s*,\\s*)*)+\\)$" }}
      {{- $__regexSetExists := "^!?[A-Za-z0-9-]+" }}

      {{- if mustRegexMatch $__regexEquality . }}
        {{- $__key = index $__regexSlice 0 }}
        {{- if mustRegexMatch "!=" (index $__regexSlice 1) }}
          {{- $__operator = "NotIn" }}
        {{- else if mustRegexMatch "=+" (index $__regexSlice 1) }}
          {{- $__operator = "In" }}
        {{- else if mustRegexMatch ">" (index $__regexSlice 1) }}
          {{- $__operator = "Gt" }}
        {{- else if mustRegexMatch "<" (index $__regexSlice 1) }}
          {{- $__operator = "Lt" }}
        {{- end }}
        {{- $__values = include "base.fmt.slice" (dict "s" (mustSlice $__regexSlice 2)) }}
      {{- else if mustRegexMatch $__regexSet . }}
        {{- $__key = index $__regexSlice 0 }}
        {{- if mustRegexMatch "[iI][nN]" (index $__regexSlice 1) }}
          {{- $__operator = "In" }}
        {{- else if mustRegexMatch "[nN][oO][tT][iI][nN]" (index $__regexSlice 1) }}
          {{- $__operator = "NotIn" }}
        {{- else if mustRegexMatch "[gG][tT]" (index $__regexSlice 1) }}
          {{- $__operator = "Gt" }}
        {{- else if mustRegexMatch "[lL][tT]" (index $__regexSlice 1) }}
          {{- $__operator = "Lt" }}
        {{- end }}
        {{- $__values = include "base.fmt.slice" (dict "s" (mustSlice $__regexSlice 2)) }}
      {{- else if mustRegexMatch $__regexSetExists . }}
        {{- $__key = mustRegexReplaceAll "^!" (index $__regexSlice 0) "" }}
        {{- $__operator = "Exists" }}
        {{- if mustRegexMatch "^!.*" (index $__regexSlice 0) }}
          {{- $__operator = "DoesNotExists" }}
        {{- end }}
      {{- else }}
        {{- fail "definitions.LabelSelectorRequirement: matchExpressions or matchFields (string) not support" }}
      {{- end }}
    {{- end }}

    {{- nindent 0 "" -}}key: {{ $__key }}
    {{- nindent 0 "" -}}operator: {{ $__operator }}

    {{- $__operatorG1 := list "In" "NotIn" }}
    {{- $__operatorG2 := list "Exists" "DoesNotExist" }}
    {{- $__operatorG3 := list "Gt" "Lt" }}

    {{- if mustHas $__operator $__operatorG1 }}
      {{- if not $__values }}
        {{- fail "definitions.LabelSelectorRequirement: values must be exists." }}
      {{- end }}
    {{- end }}
    {{- if not (mustHas $__operator $__operatorG2) }}
      {{- nindent 0 "" -}}values:
      {{- $__values | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
