{{- define "cluster.Binding" -}}
  {{- $_ := set . "_kind" "Binding" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: Binding
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- if or ._CTX.target .Values.target }}
    {{- $__cleanData := dict }}

    {{- if ._CTX.target }}
      {{- $__cleanData = mustMerge $__cleanData ._CTX.target }}
    {{- end }}
    {{- if .Values.target }}
      {{- $__cleanData = mustMerge $__cleanData .Values.target }}
    {{- end }}

    {{- $__target := include "definitions.ObjectReference" $__cleanData | trim }}
    {{- if $__target }}
      {{- nindent 0 "" -}}target:
        {{- $__target | nindent 2 }}
    {{- end }}
  {{- end }}

{{- end }}
