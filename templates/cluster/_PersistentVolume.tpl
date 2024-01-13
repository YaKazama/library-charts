{{- define "cluster.PersistentVolume" -}}
  {{- $_ := set . "_kind" "PersistentVolume" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__clean := dict }}
  {{- $__persistentVolumeSrc := list .Context .Context.spec .Context.persistentVolume .Values .Values.spec .Values.persistentVolume }}
  {{- range $__persistentVolumeSrc | mustUniq | mustCompact }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__spec := include "cluster.PersistentVolumeSpec" $__clean | fromYaml }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- toYaml $__spec | nindent 2 }}
  {{- end }}
{{- end }}
