{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#podsecuritycontext-v1-core
  - https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
*/ -}}
{{- define "definitions.PodSecurityContext" -}}
  {{- with . }}
    {{- $__fsGroup := include "base.int.zero" (pluck "fsGroup" .) }}
    {{- if $__fsGroup }}
      {{- nindent 0 "" -}}fsGroup: {{ $__fsGroup }}
    {{- end }}

    {{- $__fsGroupChangePolicyAllowed := list "OnRootMismatch" "Always" }}
    {{- $__fsGroupChangePolicy := include "base.string" .fsGroupChangePolicy }}
    {{- if mustHas $__fsGroupChangePolicy $__fsGroupChangePolicyAllowed }}
      {{- nindent 0 "" -}}fsGroupChangePolicy: {{ coalesce .fsGroupChangePolicy "Always" }}
    {{- end }}

    {{- $__runAsGroup := include "base.int.zero" (pluck "runAsGroup" .) }}
    {{- if $__runAsGroup }}
      {{- nindent 0 "" -}}runAsGroup: {{ $__runAsGroup }}
    {{- end }}

    {{- $__runAsNonRoot := include "base.bool" .runAsNonRoot }}
    {{- if $__runAsNonRoot }}
      {{- nindent 0 "" -}}runAsNonRoot: {{ $__runAsNonRoot }}
    {{- end }}

    {{- $__runAsUser := include "base.int.zero" (pluck "runAsUser" .) }}
    {{- if $__runAsUser }}
      {{- nindent 0 "" -}}runAsUser: {{ $__runAsUser }}
    {{- end }}

    {{- $__seLinuxOptions := include "definitions.SELinuxOptions" .seLinuxOptions | fromYaml }}
    {{- if $__seLinuxOptions }}
      {{- nindent 0 "" -}}seLinuxOptions:
      {{- toYaml $__seLinuxOptions | nindent 2 }}
    {{- end }}

    {{- $__seccompProfile := include "definitions.SeccompProfile" .seccompProfile | fromYaml }}
    {{- if $__seccompProfile }}
      {{- nindent 0 "" -}}seccompProfile:
      {{- toYaml $__seccompProfile | nindent 2 }}
    {{- end }}

    {{- $__clean := list }}
    {{- if kindIs "string" .supplementalGroups }}
      {{- $__clean = mustAppend $__clean .supplementalGroups }}
    {{- else if kindIs "slice" .supplementalGroups }}
      {{- $__clean = concat $__clean .supplementalGroups }}
    {{- end }}
    {{- $__supplementalGroups := include "base.fmt.slice" (dict "s" $__clean "atoi" true) }}
    {{- if $__supplementalGroups }}
      {{- nindent 0 "" -}}supplementalGroups:
      {{- $__supplementalGroups | nindent 0 }}
    {{- end }}

    {{- $__sysctls := list }}
    {{- $__clean := list }}
    {{- if kindIs "string" .sysctls }}
      {{- $__clean = mustAppend $__clean .sysctls }}
    {{- else if kindIs "slice" .sysctls }}
      {{- $__clean = concat $__clean .sysctls }}
    {{- else if kindIs "map" .sysctls }}
      {{- range $k, $v := .sysctls }}
        {{- $__clean = mustAppend $__clean (dict $k $v) }}
      {{- end }}
    {{- end }}
    {{- range (mustCompact (mustUniq $__clean)) }}
      {{- $__sysctls = mustAppend $__sysctls (include "definitions.Sysctl" . | fromYaml) }}
    {{- end }}
    {{- if $__sysctls }}
      {{- nindent 0 "" -}}sysctls:
      {{- toYaml $__sysctls | nindent 0 }}
    {{- end }}

    {{- $__windowsOptions := include "definitions.WindowsSecurityContextOptions" .windowsOptions | fromYaml }}
    {{- if $__windowsOptions }}
      {{- nindent 0 "" -}}windowsOptions:
      {{- toYaml $__windowsOptions | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
