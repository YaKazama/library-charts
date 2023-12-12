{{- define "definitions.RoleRef" -}}
  {{- with . }}
    {{- nindent 0 "" -}}apiGroup: {{ coalesce .apiGroup "rbac.authorization.k8s.io" }}
    {{- nindent 0 "" -}}kind: {{ coalesce .kind "ClusterRole" }}
    {{- if .name }}
      {{- nindent 0 "" -}}name: {{ .name }}
    {{- else }}
      {{- fail "definitions.RoleRef: .name not found" }}
    {{- end }}
  {{- end }}
{{- end }}
