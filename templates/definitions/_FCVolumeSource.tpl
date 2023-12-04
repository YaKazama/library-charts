{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#fcvolumesource-v1-core
  - https://github.com/kubernetes/examples/blob/master/staging/volumes/fibre_channel/fc.yaml
*/ -}}
{{- define "definitions.FCVolumeSource" -}}
  {{- $__fsTypeList := list "ext4" "xfs" "ntfs" }}

  {{- with .}}
    {{- if mustHas .fsType $__fsTypeList }}
      {{- nindent 0 "" -}}fsType: {{ coalesce .fsType "ext4" }}
    {{- else }}
      {{- fail "fc.fsType not found" }}
    {{- end }}
    {{- if .lun }}
      {{- nindent 0 "" -}}lun: {{ int .lun }}
    {{- end }}
    {{- if and .readOnly (kindIs "bool" .readOnly) }}
      {{- nindent 0 "" -}}readOnly: true
    {{- end }}
    {{- if .targetWWNs }}
      {{- nindent 0 "" -}}targetWWNs:
      {{- toYaml .targetWWNs | nindent 0 }}
    {{- end }}
    {{- if and .wwids (not (and .lun .targetWWNs)) }}
      {{- nindent 0 "" -}}wwids:
      {{- toYaml .wwids | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
