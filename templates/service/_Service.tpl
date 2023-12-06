{{- define "service.Service" -}}
  {{- $_ := set . "_kind" "Service" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: Service
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
  {{- nindent 0 "" -}}spec:
    {{- include "service.ServiceSpec" . | trim | nindent 2 }}
{{- end }}
