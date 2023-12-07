{{- define "definitions.IngressClassParametersReference" -}}
  {{- $__scopeList := list "Cluster" "Namespace" }}

  {{- with . }}
    {{- if .apiGroup }}
      {{- nindent 0 "" -}}apiGroup: {{ .apiGroup }}
    {{- else }}
      {{- fail "definitions.IngressClassParametersReference: apiGroup must be exists" }}
    {{- end }}
    {{- if .kind }}
      {{- nindent 0 "" -}}kind: {{ .kind }}
    {{- else }}
      {{- fail "definitions.IngressClassParametersReference: kind must be exists" }}
    {{- end }}
    {{- if .name }}
      {{- nindent 0 "" -}}name: {{ .name }}
    {{- else }}
      {{- fail "definitions.IngressClassParametersReference: name must be exists" }}
    {{- end }}
    {{- if mustHas .scope $__scopeList }}
      {{- nindent 0 "" -}}scope: {{ coalesce .scope "Cluster" }}

      {{- if eq .scope "Namespace" }}
        {{- nindent 0 "" -}}namespace: {{ coalesce .namespace "default" }}
      {{- else if ne .scope "Cluster" }}
        {{- fail "definitions.IngressClassParametersReference: namespace is required when scope is set to \"Namespace\"" }}
      {{- end }}
    {{- else }}
      {{- fail "definitions.IngressClassParametersReference: scope not support" }}
    {{- end }}
  {{- end }}
{{- end }}
