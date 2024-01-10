{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#cephfsvolumesource-v1-core
  - https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
*/ -}}
{{- define "definitions.CephFSVolumeSource" -}}
  {{- with . }}
    {{- $__regexSplit := "\\s+|\\s*[\\|,]\\s*" }}
    {{- $__monitors := include "base.fmt.slice" (dict "s" (list .monitors) "r" $__regexSplit) }}
    {{- if $__monitors }}
      {{- nindent 0 "" -}}monitors:
      {{- $__monitors | nindent 0 }}
    {{- end }}

    {{- $__path := include "base.fmt" (dict "s" .path "r" "^/.*") }}
    {{- if $__path }}
      {{- nindent 0 "" -}}path: {{ coalesce $__path "/" }}
    {{- else }}
      {{- fail "definitions.CephFSVolumeSource: .path invalid or not found" }}
    {{- end }}

    {{- $__readOnly := include "base.bool" .readOnly }}
    {{- if $__readOnly }}
      {{- nindent 0 "" -}}readOnly: {{ $__readOnly }}
    {{- end }}

    {{- $__secretFile := include "base.string" .secretFile }}
    {{- if $__secretFile }}
      {{- nindent 0 "" -}}secretFile: {{ coalesce $__secretFile "/etc/ceph/user.secret" }}
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
