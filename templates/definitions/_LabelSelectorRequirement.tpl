{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#labelselectorrequirement-v1-meta
  - https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/labels/
  - https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#resources-that-support-set-based-requirements
*/ -}}
{{- define "definitions.LabelSelectorRequirement" -}}
  {{- $__operatorListEquality := list "In" "NotIn" }}
  {{- $__operatorListSet := list "Exists" "DoesNotExists" }}

  {{- range $v := . }}
    {{- /*
      reference: https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/labels/#label-selectors
    */ -}}
    {{- $__regexEquality := "^[A-Za-z0-9-]*\\s+([=]{1,2}|!=)\\s+[A-Za-z0-9-]*" }}
    {{- $__regexSet := "^[A-Za-z0-9-]*\\s+([iI][nN]|[nN][oO][tT][iI][nN])\\s+\\(([A-Za-z0-9-]*(,)?\\s*)*\\)" }}
    {{- $__regexSetExists := "^!?[A-Za-z0-9-]*" }}

    {{- $__key := "" }}
    {{- $__operator := "" }}
    {{- $__values := "" }}

    {{- if kindIs "map" $v }}
      {{- if and (hasKey $v "key") (hasKey $v "operator") }}
        {{- $__key = get $v "key" }}
        {{- $__operator = get $v "operator" }}
        {{- $__values = get $v "values" }}
      {{- else }}
        {{- fail "matchExpressions (map) invalid - definitions.LabelSelectorRequirement" }}
      {{- end }}
    {{- else if kindIs "string" $v }}
      {{- $__vv := mustRegexReplaceAll "(,)?\\s*" $v " " | replace "(" "" | replace ")" "" }}
      {{- $__regexSlice := mustRegexSplit " " $__vv -1 }}

      {{- if mustRegexMatch $__regexEquality $v }}
        {{- $__key = index $__regexSlice 0 }}
        {{- if mustRegexMatch "=+" (index $__regexSlice 1) }}
          {{- $__operator = "In" }}
        {{- else if mustRegexMatch "!=" (index $__regexSlice 1) }}
          {{- $__operator = "NotIn" }}
        {{- end }}
        {{- $__values = index $__regexSlice 2 | list }}
      {{- else if mustRegexMatch $__regexSet $v }}
        {{- $__key = index $__regexSlice 0 }}
        {{- if mustRegexMatch "[iI][nN]" (index $__regexSlice 1) }}
          {{- $__operator = "In" }}
        {{- else if mustRegexMatch "[nN][oO][tT][iI][nN]" (index $__regexSlice 1) }}
          {{- $__operator = "NotIn" }}
        {{- end }}
        {{- $__values = slice $__regexSlice 2 }}
      {{- else if mustRegexMatch $__regexSetExists $v }}
        {{- $__key = mustRegexReplaceAll "^!" (index $__regexSlice 0) "" }}
        {{- $__operator = "Exists" }}
        {{- if mustRegexMatch "^!.*" (index $__regexSlice 0) }}
          {{- $__operator = "DoesNotExists" }}
        {{- end }}
      {{- else }}
        {{- fail "matchExpressions (string) invalid - definitions.LabelSelectorRequirement" }}
      {{- end }}
    {{- end }}

    {{- if and $__key (or (mustHas $__operator $__operatorListEquality) (mustHas $__operator $__operatorListSet)) }}
      {{- nindent 0 "" -}}- key: {{ $__key }}
      {{- nindent 2 "" -}}  operator: {{ $__operator }}
      {{- if mustHas $__operator $__operatorListEquality }}
        {{- if not $__values }}
          {{- fail "the operator is In or NotIn, the values array must be non-empty" }}
        {{- end }}
        {{- nindent 2 "" -}}  values:
          {{- $__values | toYaml | nindent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
