{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nfsvolumesource-v1-core
*/ -}}
{{- define "definitions.NFSVolumeSource" -}}
  {{- with . }}
    {{- if .path }}
      {{- nindent 0 "" -}}path: {{ .path }}
    {{- else }}
      {{- fail "nfs.path not found" }}
    {{- end }}
    {{- if and .readOnly (kindIs "bool" .readOnly) }}
      {{- nindent 0 "" -}}readOnly: true
    {{- end }}
    {{- if .server }}
      {{- nindent 0 "" -}}server: {{ .server }}
    {{- else }}
      {{- fail "nfs.server not found" }}
    {{- end }}
  {{- end }}
{{- end }}
