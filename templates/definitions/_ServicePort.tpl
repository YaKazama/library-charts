{{- define "definitions.ServicePort" -}}
  {{- with . }}
    {{- $__appProtocol := include "base.string" .appProtocol }}
    {{- if $__appProtocol }}
      {{- nindent 0 "" -}}appProtocol: {{ $__appProtocol }}
    {{- end }}

    {{- $__name := include "base.string" (coalesce .name (printf "svc-%s" (randAlphaNum 8))) }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- end }}

    {{- $__typeNodePortAllowed := list "NodePort" "LoadBalancer" }}
    {{- if mustHas .type $__typeNodePortAllowed }}
      {{- $__nodePort := include "base.int.scope" (list .nodePort 1 65535) }}
      {{- if $__nodePort }}
        {{- nindent 0 "" -}}nodePort: {{ $__nodePort }}
      {{- end }}
    {{- end }}

    {{- $__port := include "base.int.scope" (list .port 1 65535) }}
    {{- if $__port }}
      {{- nindent 0 "" -}}port: {{ $__port }}
    {{- end }}

    {{- /*
      为空时，使用系统内置的默认值 TCP
    */ -}}
    {{- $__protocolAllowed := list "TCP" "UDP" "SCTP" }}
    {{- $__protocol := include "base.string" .protocol }}
    {{- if mustHas ($__protocol | upper) $__protocolAllowed }}
      {{- nindent 0 "" -}}protocol: {{ $__protocol }}
    {{- end }}

    {{- if not (eq .type "None") }}
      {{- /*
        为字符串时，此处使用 RFC1123 约定
        为数字时，此处使用 1-65535 的值
      */ -}}
      {{- $__regexTargetPort := "^([a-z0-9]{1,63}|[a-z0-9][a-z0-9-]{0,61}[a-z0-9])$|^([1-9]\\d{0,3}|[1-5]\\d{4}|6[0-4]\\d{3}|65[0-4]\\d{2}|655[0-2]\\d|6553[0-5])$" }}
      {{- $__targetPort := include "base.fmt" (dict "s" (coalesce .targePort .port) "r" $__regexTargetPort) }}
      {{- if $__targetPort }}
        {{- nindent 0 "" -}}targetPort: {{ $__targetPort }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
