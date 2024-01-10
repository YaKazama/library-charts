{{- define "definitions.PolicyRule" -}}
  {{- with . }}
    {{- $__apiGroups := include "base.fmt.slice" (dict "s" (list .apiGroups) "empty" true) }}
    {{- if $__apiGroups }}
      {{- nindent 0 "" -}}apiGroups:
      {{- $__apiGroups | nindent 0 }}
    {{- else }}
      {{- fail "definitions.PolicyRule: apiGroups not found." }}
    {{- end }}

    {{- $__nonResourceURLs := include "base.fmt.slice" (dict "s" (list .nonResourceURLs)) }}
    {{- if $__nonResourceURLs }}
      {{- nindent 0 "" -}}nonResourceURLs:
      {{- $__nonResourceURLs | nindent 0 }}
    {{- end }}

    {{- $__resourceNames := include "base.fmt.slice" (dict "s" (list .resourceNames)) }}
    {{- if $__resourceNames }}
      {{- nindent 0 "" -}}resourceNames:
      {{- $__resourceNames | nindent 0 }}
    {{- end }}

    {{- $__resources := include "base.fmt.slice" (dict "s" (list .resources)) }}
    {{- if $__resources }}
      {{- nindent 0 "" -}}resources:
      {{- $__resources | nindent 0 }}
    {{- else }}
      {{- fail "definitions.PolicyRule: resources not found." }}
    {{- end }}

    {{- $__verbs := include "base.fmt.slice" (dict "s" (list .verbs)) }}
    {{- if $__verbs }}
      {{- nindent 0 "" -}}verbs:
      {{- $__verbs | nindent 0 }}
    {{- else }}
      {{- fail "definitions.PolicyRule: verbs not found." }}
    {{- end }}
  {{- end }}
{{- end }}
