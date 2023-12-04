{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#podtemplatespec-v1-core
*/ -}}
{{- define "metadata.PodTemplateSpec" -}}
  {{- $_ := set . "_kind" "PodTemplateSpec" }}

  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
  {{- nindent 0 "" -}}spec:
    {{- include "workloads.PodSpec" . | trim | nindent 2 }}
{{- end }}
