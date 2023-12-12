{{- define "definitions.PolicyRule" -}}
  {{- with . }}
    {{- if .apiGroups }}
      {{- nindent 0 "" -}}apiGroups:
      {{- toYaml .apiGroups | nindent 0 }}
    {{- else }}
      {{- fail "definitions.PolicyRule: .apiGroups not found" }}
    {{- end }}

    {{- if .resources }}
      {{- nindent 0 "" -}}resources:
      {{- toYaml .resources | nindent 0 }}
    {{- else }}
      {{- fail "definitions.PolicyRule: .resources not found" }}
    {{- end }}

    {{- if .verbs }}
      {{- nindent 0 "" -}}verbs:
      {{- toYaml .verbs | nindent 0 }}
    {{- else }}
      {{- fail "definitions.PolicyRule: .verbs not found" }}
    {{- end }}

    {{- if .nonResourceURLs }}
      {{- nindent 0 "" -}}nonResourceURLs:
      {{- toYaml .nonResourceURLs | nindent 0 }}
    {{- end }}

    {{- if .resourceNames }}
      {{- nindent 0 "" -}}resourceNames:
      {{- toYaml .resourceNames | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
