{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#fcvolumesource-v1-core
  - https://github.com/kubernetes/examples/blob/master/staging/volumes/fibre_channel/fc.yaml
*/ -}}
{{- define "definitions.FCVolumeSource" -}}
  {{- $__fsTypeAllowed := list "ext4" "xfs" "ntfs" }}

  {{- with .}}
    {{- $__fsType := include "base.string" .fsType }}
    {{- if mustHas $__fsType $__fsTypeAllowed }}
      {{- nindent 0 "" -}}fsType: {{ coalesce $__fsType "ext4" }}
    {{- else }}
      {{- fail "definitions.FCVolumeSource .fsType not found" }}
    {{- end }}

    {{- $__lun := include "base.int" .lun }}
    {{- if $__lun }}
      {{- nindent 0 "" -}}lun: {{ $__lun }}
    {{- end }}

    {{- $__readOnly := include "base.bool" .readOnly }}
    {{- if $__readOnly }}
      {{- nindent 0 "" -}}readOnly: {{ $__readOnly }}
    {{- end }}

    {{- $__targetWWNs := include "base.fmt.slice" (dict "s" (list .targetWWNs)) }}
    {{- if $__targetWWNs }}
      {{- nindent 0 "" -}}targetWWNs:
      {{- $__targetWWNs | nindent 0 }}
    {{- end }}

    {{- $__wwids := include "base.fmt.slice" (dict "s" (list .wwids)) }}
    {{- if and $__wwids (not (and $__lun $__targetWWNs)) }}
      {{- nindent 0 "" -}}wwids:
      {{- $__wwids | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
