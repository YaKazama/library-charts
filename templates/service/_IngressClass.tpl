{{- define "service.IngressClass" -}}
  {{- $_ := set . "_kind" "IngressClass" }}

  {{- nindent 0 "" -}}apiVersion: networking.k8s.io/v1
  {{- nindent 0 "" -}}kind: IngressClass
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
  {{- nindent 0 "" -}}spec:
    {{- include "service.IngressClassSpec" . | trim | nindent 2 }}
{{- end }}
