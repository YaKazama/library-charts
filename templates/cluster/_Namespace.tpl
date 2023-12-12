{{- define "cluster.Namespace" -}}
  {{- $_ := set . "_kind" "Namespace" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: Namespace
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
{{- end }}
