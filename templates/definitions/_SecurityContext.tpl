{{- define "definitions.SecurityContext" -}}
  {{- with . }}
    {{- if and .allowPrivilegeEscalation (kindIs "bool" .allowPrivilegeEscalation) }}
      {{- nindent 0 "" -}}allowPrivilegeEscalation: true
    {{- end }}

    {{- if .capabilities }}
      {{- nindent 0 "" -}}capabilities:
      {{- toYaml .capabilities | nindent 2 }}
    {{- end }}

    {{- if and .privileged (kindIs "bool" .privileged) }}
      {{- nindent 0 "" -}}privileged: true
    {{- end }}

    {{- if .procMount }}
      {{- nindent 0 "" -}}procMount: {{ coalesce .procMount "DefaultProcMount" }}
    {{- end }}

    {{- if and .readOnlyRootFilesystem (kindIs "bool" .readOnlyRootFilesystem) }}
      {{- nindent 0 "" -}}readOnlyRootFilesystem: true
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

    {{- if .windowsOptions }}
      {{- nindent 0 "" -}}windowsOptions:
      {{- include "definitions.WindowsSecurityContextOptions" .windowsOptions | indent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
