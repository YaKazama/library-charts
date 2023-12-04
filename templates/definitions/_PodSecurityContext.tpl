{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#podsecuritycontext-v1-core
  - https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
*/ -}}
{{- define "definitions.PodSecurityContext" -}}
  {{- if and .fsGroup (ge (int .fsGroup) 0) }}
    {{- nindent 0 "" -}}fsGroup: {{ int .fsGroup }}
  {{- end }}

  {{- $__fsGroupChangePolicyList := list "OnRootMismatch" "Always" }}
  {{- if mustHas .fsGroupChangePolicy $__fsGroupChangePolicyList }}
    {{- nindent 0 "" -}}fsGroupChangePolicy: {{ coalesce .fsGroupChangePolicy "Always" }}
  {{- end }}

  {{- if and .runAsGroup (ge (int .runAsGroup) 0) }}
    {{- nindent 0 "" -}}runAsGroup: {{ int .runAsGroup }}
  {{- end }}

  {{- if and .runAsNonRoot (kindIs "bool" .runAsNonRoot) }}
    {{- nindent 0 "" -}}runAsNonRoot: true
  {{- end }}

  {{- if and .runAsUser (ge (int .runAsUser) 0) }}
    {{- nindent 0 "" -}}runAsUser: {{ int .runAsUser }}
  {{- end }}

  {{- if .seLinuxOptions }}
    {{- nindent 0 "" -}}seLinuxOptions:
    {{- include "definitions.SELinuxOptions" .seLinuxOptions | indent 2 }}
  {{- end }}

  {{- if .seccompProfile }}
    {{- nindent 0 "" -}}seccompProfile:
    {{- include "definitions.SeccompProfile" .seccompProfile | indent 2 }}
  {{- end }}

  {{- if .supplementalGroups }}
    {{- nindent 0 "" -}}supplementalGroups:
    {{- toYaml .supplementalGroups | nindent 2 }}
  {{- end }}

  {{- if .sysctls }}
    {{- nindent 0 "" -}}sysctls:
    {{- include "definitions.Sysctl" .sysctls | indent 0 }}
  {{- end }}

  {{- if .windowsOptions }}
    {{- nindent 0 "" -}}windowsOptions:
    {{- include "definitions.WindowsSecurityContextOptions" .windowsOptions | indent 2 }}
  {{- end }}
{{- end }}
