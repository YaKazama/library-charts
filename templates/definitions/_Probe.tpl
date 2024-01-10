{{- define "definitions.Probe" -}}
  {{- with . }}
    {{- $__exec := include "definitions.ExecAction" .exec | fromYaml }}
    {{- if $__exec }}
      {{- nindent 0 "" -}}exec:
        {{- toYaml $__exec | nindent 2 }}
    {{- end }}

    {{- $__failureThreshold := include "base.int" .failureThreshold }}
    {{- if $__failureThreshold }}
      {{- nindent 0 "" -}}failureThreshold: {{ coalesce $__failureThreshold 3 }}
    {{- end }}

    {{- $__grpc := include "definitions.GRPCAction" .grpc | fromYaml }}
    {{- if $__grpc }}
      {{- nindent 0 "" -}}grpc:
        {{- toYaml $__grpc | nindent 2 }}
    {{- end }}

    {{- $__httpGet := include "definitions.HTTPGetAction" .httpGet | fromYaml }}
    {{- if $__httpGet }}
      {{- nindent 0 "" -}}httpGet:
        {{- toYaml $__httpGet | nindent 2 }}
    {{- end }}

    {{- if eq .__probeType "livenessProbe" }}
      {{- $__initialDelaySeconds := include "base.int" .initialDelaySeconds }}
      {{- if $__initialDelaySeconds }}
        {{- nindent 0 "" -}}initialDelaySeconds: {{ coalesce $__initialDelaySeconds 1 }}
      {{- end }}
    {{- end }}

    {{- $__periodSeconds := include "base.int" .periodSeconds }}
    {{- if $__periodSeconds }}
      {{- nindent 0 "" -}}periodSeconds: {{ coalesce $__periodSeconds 10 }}
    {{- end }}

    {{- $__successThreshold := include "base.int" .successThreshold }}
    {{- if $__successThreshold }}
      {{- if or (eq .__probeType "livenessProbe") (eq .__probeType "startupProbe") }}
        {{- $__successThreshold = 1 }}
      {{- end }}
      {{- nindent 0 "" -}}successThreshold: {{ coalesce $__successThreshold 1 }}
    {{- end }}

    {{- $__tcpSocket := include "definitions.TCPSocketAction" .tcpSocket | fromYaml }}
    {{- if $__tcpSocket }}
      {{- nindent 0 "" -}}tcpSocket:
        {{- toYaml $__tcpSocket | nindent 2 }}
    {{- end }}

    {{- $__terminationGracePeriodSeconds := include "base.int" .terminationGracePeriodSeconds }}
    {{- if $__terminationGracePeriodSeconds }}
      {{- nindent 0 "" -}}terminationGracePeriodSeconds: {{ coalesce $__terminationGracePeriodSeconds 1 }}
    {{- end }}

    {{- $__timeoutSeconds := include "base.int" .timeoutSeconds }}
    {{- if $__timeoutSeconds }}
      {{- nindent 0 "" -}}timeoutSeconds: {{ coalesce $__timeoutSeconds 1 }}
    {{- end }}

  {{- end }}
{{- end }}
