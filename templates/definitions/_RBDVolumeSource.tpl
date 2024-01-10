{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#rbdvolumesource-v1-core
  - https://github.com/kubernetes/examples/tree/master/volumes/rbd
*/ -}}
{{- define "definitions.RBDVolumeSource" -}}
  {{- with . }}
    {{- $__fsTypeAllowed := list "ext4" "xfs" "ntfs" }}
    {{- $__fsType := include "base.string" .fsType }}
    {{- if mustHas $__fsType $__fsTypeAllowed }}
      {{- nindent 0 "" -}}fsType: {{ coalesce $__fsType "ext4" }}
    {{- else }}
      {{- fail "definitions.RBDVolumeSource .fsType not found" }}
    {{- end }}

    {{- $__image := include "base.string" .image }}
    {{- if $__image }}
      {{- nindent 0 "" -}}image: {{ $__image }}
    {{- end }}

    {{- $__keyring := include "base.fmt" (dict "s" .keyring "r" "^/.*") }}
    {{- if $__keyring }}
      {{- nindent 0 "" -}}keyring: {{ coalesce $__keyring "/etc/ceph/keyring" }}
    {{- end }}

    {{- $__regexSplit := "\\s+|\\s*[\\|,]\\s*" }}
    {{- $__monitors := include "base.fmt.slice" (dict "s" (list .monitors) "r" $__regexSplit) }}
    {{- if $__monitors }}
      {{- nindent 0 "" -}}monitors:
      {{- $__monitors | nindent 0 }}
    {{- end }}

    {{- $__pool := include "base.string" .pool }}
    {{- if $__pool }}
      {{- nindent 0 "" -}}pool: {{ coalesce $__pool "rbd" }}
    {{- end }}

    {{- $__readOnly := include "base.bool" .readOnly }}
    {{- if $__readOnly }}
      {{- nindent 0 "" -}}readOnly: {{ $__readOnly }}
    {{- end }}

    {{- $__secretRef := include "definitions.LocalObjectReference" .secretRef | fromYaml }}
    {{- if $__secretRef }}
      {{- nindent 0 "" -}}secretRef:
        {{- toYaml $__secretRef | nindent 2 }}
    {{- end }}

    {{- $__user := include "base.string" .user }}
    {{- if $__user }}
      {{- nindent 0 "" -}}user: {{ coalesce $__user "admin" }}
    {{- end }}
  {{- end }}
{{- end }}
