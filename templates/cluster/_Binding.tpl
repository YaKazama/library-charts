{{- define "cluster.Binding" -}}
  {{- $_ := set . "_kind" "Binding" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__clean := dict }}
  {{- $__targetSrc := pluck "target" .Context .Values }}
  {{- range ($__targetSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__target := include "definitions.ObjectReference" $__clean | fromYaml }}
  {{- if $__target }}
    {{- nindent 0 "" -}}target:
      {{- toYaml $__target | nindent 2 }}
  {{- end }}
{{- end }}
