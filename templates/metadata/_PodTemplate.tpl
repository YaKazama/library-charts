{{- define "metadata.PodTemplate" -}}
  {{- $_ := set . "_kind" "PodTemplate" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__template := include "metadata.PodTemplateSpec" . }}
  {{- if $__template }}
    {{- nindent 0 "" -}}template:
      {{- $__template | indent 2 }}
  {{- end }}
{{- end }}
