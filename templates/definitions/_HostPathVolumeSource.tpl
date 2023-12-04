{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#hostpathvolumesource-v1-core
  - https://kubernetes.io/docs/concepts/storage/volumes/#hostpath
*/ -}}
{{- define "definitions.HostPathVolumeSource" -}}
  {{- $__typeList := list "DirectoryOrCreate" "Directory" "FileOrCreate" "File" "Socket" "CharDevice" "BlockDevice" }}

  {{- with . }}
    {{- if .path }}
      {{- nindent 0 "" -}}path: {{ .path }}
    {{- else }}
      {{- fail "hostPath.path not found" }}
    {{- end }}
    {{- if mustHas .type $__typeList }}
      {{- nindent 0 "" -}}type: {{ coalesce .type "" }}
    {{- end }}
  {{- end }}
{{- end }}
