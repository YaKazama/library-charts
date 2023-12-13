{{- define "cluster.PersistentVolume" -}}
  {{- $_ := set . "_kind" "PersistentVolume" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: PersistentVolume
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__spec := include "cluster.PersistentVolumeSpec" . | trim }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- $__spec | nindent 2 }}
  {{- end }}
{{- end }}
