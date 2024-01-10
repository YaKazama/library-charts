{{- define "definitions.SecurityContext" -}}
  {{- with . }}
    {{- $__allowPrivilegeEscalation := include "base.bool" .allowPrivilegeEscalation }}
    {{- if $__allowPrivilegeEscalation }}
      {{- nindent 0 "" -}}allowPrivilegeEscalation: {{ $__allowPrivilegeEscalation }}
    {{- end }}

    {{- $__capabilities := include "definitions.Capabilities" .capabilities | fromYaml }}
    {{- if $__capabilities }}
      {{- nindent 0 "" -}}capabilities:
        {{- toYaml $__capabilities | nindent 2 }}
    {{- end }}

    {{- $__privileged := include "base.bool" .privileged }}
    {{- if $__privileged }}
      {{- nindent 0 "" -}}privileged: {{ $__privileged }}
    {{- end }}

    {{- $__procMount := include "base.string" .procMount }}
    {{- if $__procMount }}
      {{- nindent 0 "" -}}procMount: {{ coalesce $__procMount "DefaultProcMount" }}
    {{- end }}

    {{- $__readOnlyRootFilesystem := include "base.bool" .readOnlyRootFilesystem }}
    {{- if $__readOnlyRootFilesystem }}
      {{- nindent 0 "" -}}readOnlyRootFilesystem: {{ $__readOnlyRootFilesystem }}
    {{- end }}

    {{- $__runAsGroup := include "base.int.zero" (list .runAsGroup) }}
    {{- if $__runAsGroup }}
      {{- nindent 0 "" -}}runAsGroup: {{ $__runAsGroup }}
    {{- end }}

    {{- $__runAsNonRoot := include "base.bool" .runAsNonRoot }}
    {{- if $__runAsNonRoot }}
      {{- nindent 0 "" -}}runAsNonRoot: {{ $__runAsNonRoot }}
    {{- end }}

    {{- $__runAsUser := include "base.int.zero" (list .runAsUser) }}
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

    {{- $__windowsOptions := include "definitions.WindowsSecurityContextOptions" .windowsOptions | fromYaml }}
    {{- if $__windowsOptions }}
      {{- nindent 0 "" -}}windowsOptions:
      {{- toYaml $__windowsOptions | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
