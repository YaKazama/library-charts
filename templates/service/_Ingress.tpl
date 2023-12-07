{{- define "service.Ingress" -}}
  {{- $_ := set . "_kind" "Ingress" }}

  {{- nindent 0 "" -}}apiVersion: networking.k8s.io/v1
  {{- nindent 0 "" -}}kind: Ingress
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
  {{- nindent 0 "" -}}spec:
    {{- include "service.IngressSpec" . | trim | nindent 2 }}
{{- end }}
