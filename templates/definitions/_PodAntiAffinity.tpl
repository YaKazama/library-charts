{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#podantiaffinity-v1-core
*/ -}}
{{- define "definitions.PodAntiAffinity" -}}
  {{- if .required }}
    {{- $__requiredPAT := include "definitions.PodAffinityTerm" .required }}
    {{- if $__requiredPAT }}
      {{- nindent 0 "" -}}requiredDuringSchedulingIgnoredDuringExecution:
      {{- $__requiredPAT | indent 0 }}
    {{- end }}
  {{- end }}
  {{- if .preferred }}
    {{- $__preferredWPAT := include "definitions.WeightedPodAffinityTerm" .preferred }}
    {{- if $__preferredWPAT }}
      {{- nindent 0 "" -}}preferredDuringSchedulingIgnoredDuringExecution:
      {{- $__preferredWPAT | indent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
