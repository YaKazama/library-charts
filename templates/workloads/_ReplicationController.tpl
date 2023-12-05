{{- define "workloads.ReplicationController" -}}
  {{- $_ := set . "_kind" "ReplicationController" }}

  {{- nindent 0 "" -}}apiVersion: core/v1
  {{- nindent 0 "" -}}kind: ReplicationController
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__spec := include "workloads.ReplicationControllerSpec" . | trim }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- $__spec | nindent 2 }}
  {{- end }}
{{- end }}
