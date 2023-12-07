{{- /*
  variables (bool):
  - default: 是否为 defaultBackend 配置
  descr:
  - host 为必填项
  - 当 apiGroup kind name 存在时, 被视为 resource 配置
  - 当 portName name 或 portNumber name 存在时, 被视为 service 配置
    - portName 与 portNumber 互斥
  - resource 与 service 配置互斥
*/ -}}
{{- define "service.IngressSpec" -}}
  {{- if or ._CTX.ingressClassName .Values.ingressClassName }}
    {{- nindent 0 "" -}}ingressClassName: {{ coalesce ._CTX.ingressClassName .Values.ingressClassName }}
  {{- end }}

  {{- if or ._CTX.tls .Values.tls }}
    {{- $__tlsDict := dict }}

    {{- if ._CTX.tls }}
      {{- $__tlsDict = mustMerge $__tlsDict ._CTX.tls }}
    {{- end }}
    {{- if .Values.tls }}
      {{- $__tlsDict = mustMerge $__tlsDict .Values.tls }}
    {{- end }}

    {{- $__tls := include "definitions.IngressTLS" $__tlsDict | trim }}
    {{- if $__tls }}
      {{- nindent 0 "" -}}tls:
      {{- $__tls | nindent 2 }}
    {{- end }}
  {{- end }}

  {{- if or ._CTX.rules .Values.rules }}
    {{- $__rulesDict := dict }}
    {{- $__rules := list }}

    {{- if ._CTX.rules }}
      {{- $__rulesDict = mustMerge $__rulesDict ._CTX.rules }}
    {{- end }}
    {{- if .Values.rules }}
      {{- $__rulesDict = mustMerge $__rulesDict .Values.rules }}
    {{- end }}

    {{- range $host, $http := $__rulesDict }}
      {{- $__rules = mustAppend $__rules (include "definitions.IngressRule" (dict "host" $host "http" $http) | fromYaml) }}
    {{- end }}
    {{- $__rulesClean := mustCompact (mustUniq $__rules) }}
    {{- if $__rulesClean }}
      {{- nindent 0 "" -}}rules:
      {{- range $__rulesClean }}
        {{- printf "- host: %s" (.host | quote) | nindent 0 }}
        {{- toYaml .http | nindent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
