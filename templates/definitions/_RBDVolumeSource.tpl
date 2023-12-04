{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#rbdvolumesource-v1-core
  - https://github.com/kubernetes/examples/tree/master/volumes/rbd
*/ -}}
{{- define "definitions.RBDVolumeSource" -}}
  {{- $__fsTypeList := list "ext4" "xfs" "ntfs" }}

  {{- with . }}
    {{- if .monitors }}
      {{- nindent 0 "" -}}monitors:
      {{- toYaml .monitors | nindent 0 }}
    {{- else }}
      {{- fail "rbd.monitors is Required" }}
    {{- end }}
    {{- if mustHas .fsType $__fsTypeList }}
      {{- nindent 0 "" -}}fsType: {{ coalesce .fsType "ext4" }}
    {{- else }}
      {{- fail "rbd.fsType not found" }}
    {{- end }}
    {{- if .image }}
      {{- nindent 0 "" -}}image: {{ .image }}
    {{- end }}
    {{- if .pool }}
      {{- nindent 0 "" -}}pool: {{ coalesce .pool "rbd" }}
    {{- end }}
    {{- if and .readOnly (kindIs "bool" .readOnly) }}
      {{- nindent 0 "" -}}readOnly: true
    {{- end }}
    {{- if .keyring }}
      {{- nindent 0 "" -}}keyring: {{ coalesce .keyring "/etc/ceph/keyring" }}
    {{- else if .secretRef }}
      {{- nindent 0 "" -}}secretRef:
      {{- include "definitions.LocalObjectReference" .secretRef | indent 2 }}
    {{- end }}
    {{- if .user }}
      {{- nindent 0 "" -}}user: {{ coalesce .user "admin" }}
    {{- end }}
  {{- end }}
{{- end }}
