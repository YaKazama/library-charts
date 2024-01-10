{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#hostpathvolumesource-v1-core
  - https://kubernetes.io/docs/concepts/storage/volumes/#hostpath
*/ -}}
{{- define "definitions.HostPathVolumeSource" -}}
  {{- with . }}
    {{- $__path := include "base.fmt" (dict "s" .path "r" "^/.*") }}
    {{- if $__path }}
      {{- nindent 0 "" -}}path: {{ $__path }}
    {{- else }}
      {{- fail "definitions.HostPathVolumeSource: .path invalid" }}
    {{- end }}

    {{- $__typeAllowed := list "DirectoryOrCreate" "Directory" "FileOrCreate" "File" "Socket" "CharDevice" "BlockDevice" }}
    {{- $__type := include "base.string" .type }}
    {{- if mustHas $__type $__typeAllowed }}
      {{- nindent 0 "" -}}type: {{ coalesce $__type "" }}
    {{- end }}
  {{- end }}
{{- end }}
