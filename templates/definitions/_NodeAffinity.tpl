{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nodeaffinity-v1-core
*/ -}}
{{- define "definitions.NodeAffinity" -}}
  {{- if .required }}
    {{- nindent 0 "" -}}requiredDuringSchedulingIgnoredDuringExecution:
      {{- include "definitions.NodeSelector" .required | indent 2 }}
  {{- end }}
  {{- if .preferred }}
    {{- $__preferredPST := include "definitions.PreferredSchedulingTerm" .preferred }}
    {{- if $__preferredPST }}
      {{- nindent 0 "" -}}preferredDuringSchedulingIgnoredDuringExecution:
      {{- $__preferredPST | indent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
