{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#emptydirvolumesource-v1-core
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#quantity-resource-core
*/ -}}
{{- define "definitions.EmptyDirVolumeSource" -}}
  {{- $__regexMediumList := list "Memory" }}

  {{- with . }}
    {{- if mustHas .medium $__regexMediumList }}
      {{- nindent 0 "" -}}medium: {{ coalesce .medium "" }}
    {{- end }}
    {{- if .sizeLimit }}
      {{- nindent 0 "" -}}sizeLimit: {{ .sizeLimit }}
    {{- end }}
  {{- end }}
{{- end }}
