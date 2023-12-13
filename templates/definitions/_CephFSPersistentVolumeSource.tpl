{{- define "definitions.CephFSPersistentVolumeSource" -}}
  {{- with . }}
    {{- if .monitors }}
      {{- nindent 0 "" -}}monitors:
      {{- toYaml .monitors | nindent 0 }}
    {{- else }}
      {{- fail "cephfs.monitors is Required" }}
    {{- end }}
    {{- if .path }}
      {{- nindent 0 "" -}}path: {{ coalesce .path "/" }}
    {{- end }}
    {{- if and .readOnly (kindIs "bool" .readOnly) }}
      {{- nindent 0 "" -}}readOnly: true
    {{- end }}
    {{- if .secretFile }}
      {{- nindent 0 "" -}}secretFile: {{ coalesce .secretFile "/etc/ceph/user.secret" }}
    {{- end }}
    {{- if .secretRef }}
      {{- nindent 0 "" -}}secretRef:
        {{- include "definitions.SecretReference" .secretRef | indent 2 }}
    {{- end }}
    {{- if .user }}
      {{- nindent 0 "" -}}user: {{ coalesce .user "admin" }}
    {{- end }}
  {{- end }}
{{- end }}
