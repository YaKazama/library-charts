{{- define "cluster.Binding" -}}
  {{- $_ := set . "_kind" "Binding" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: Binding
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__target := include "definitions.ObjectReference" . | trim }}
  {{- if $__target }}
    {{- nindent 0 "" -}}target:
      {{- $__target | nindent 2 }}
  {{- end }}
{{- end }}
