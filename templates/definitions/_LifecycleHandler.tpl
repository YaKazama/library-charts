{{- define "definitions.LifecycleHandler" -}}
  {{- with . }}
    {{- $__exec := include "definitions.ExecAction" .exec | fromYaml }}
    {{- if $__exec }}
      {{- nindent 0 "" -}}exec:
        {{- toYaml $__exec | nindent 2 }}
    {{- end }}

    {{- $__httpGet := include "definitions.HTTPGetAction" .httpGet | fromYaml }}
    {{- if $__httpGet }}
      {{- nindent 0 "" -}}httpGet:
        {{- toYaml $__httpGet | nindent 2 }}
    {{- end }}

    {{- $__tcpSocket := include "definitions.TCPSocketAction" .tcpSocket | fromYaml }}
    {{- if $__tcpSocket }}
      {{- nindent 0 "" -}}tcpSocket:
        {{- toYaml $__tcpSocket | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
