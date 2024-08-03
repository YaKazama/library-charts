{{- /*
reference:
- https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs?hl=zh-cn#setting_up_a_google-managed_certificate
*/ -}}
{{- define "crds.gcp.ManagedCertificate" -}}
  {{- $_ := set . "_kind" "ManagedCertificate" }}

  {{- nindent 0 "" -}}apiVersion: networking.gke.io/v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__spec := include "crds.gcp.ManagedCertificate.ManagedCertificateSpec" . | fromYaml }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- toYaml $__spec | nindent 2 }}
  {{- end }}
{{- end }}
