{{- define "definitions.ServicePort" -}}
  {{- $__protocolList := list "TCP" "UDP" "SCTP" }}
  {{- $__nodePortExposedList := list "NodePort" "LoadBalancer" }}
  {{- $__regexPattern := "^[A-Za-z]+-(6553[0-5]|655[0-2][0-9]|65[0-4][0-9]{2}|6[0-4][0-9]{3}|[1-5][0-9]{4}|[1-9][0-9]{1,3}|[1-9])-(6553[0-5]|655[0-2][0-9]|65[0-4][0-9]{2}|6[0-4][0-9]{3}|[1-5][0-9]{4}|[1-9][0-9]{1,3}|[1-9])(-[A-Za-z0-9]+)*$" }}
  {{- $__name := printf "svc-%s" (randAlphaNum 8) }}

  {{- with . }}
    {{- if .appProtocol }}
      {{- nindent 0 "" -}}appProtocol: {{ .appProtocol }}
    {{- end }}

    {{- if .name }}
      {{- if .__regexPattern }}
        {{- if mustRegexMatch .__regexPattern .name }}
          {{- $__name = .name }}
        {{- end }}
      {{- else }}
        {{- if mustRegexMatch $__regexPattern .name }}
          {{- $__name = .name }}
        {{- else }}
          {{- if and .port .nodePort .type }}
            {{- $__name = printf "%s-%s-%s-%s" (lower (coalesce .protocol "TCP")) (toString .port) (toString .nodePort) .name }}
          {{- else if and .port .targetPort .type }}
            {{- $__name = printf "%s-%s-%s-%s" (lower (coalesce .protocol "TCP")) (toString .port) (toString .targetPort) .name }}
          {{- else if and .port .type }}
            {{- $__name = printf "%s-%s-%s-%s" (lower (coalesce .protocol "TCP")) (toString .port) (toString .port) .name }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- end }}

    {{- if and (kindIs "float64" .nodePort) (mustHas .type $__nodePortExposedList) }}
      {{- if and (ge (int .nodePort) 1) (le (int .nodePort) 65535) }}
        {{- nindent 0 "" -}}nodePort: {{ toString .nodePort }}
      {{- else }}
        {{- fail "definitions.ServicePort: nodePort range error" }}
      {{- end }}
    {{- end }}


    {{- if kindIs "float64" .port }}
      {{- if and (ge (int .port) 1) (le (int .port) 65535) }}
        {{- nindent 0 "" -}}port: {{ toString .port }}
      {{- else }}
        {{- fail "definitions.ServicePort: port range error" }}
      {{- end }}
    {{- else }}
      {{- fail "definitions.ServicePort: port not support" }}
    {{- end }}

    {{- if mustHas .protocol $__protocolList }}
      {{- nindent 0 "" -}}protocol: {{ coalesce (upper .protocol) "TCP" }}
    {{- end }}

    {{- if .targetPort }}
      {{- if and (ge (int .targetPort) 1) (le (int .targetPort) 65535) }}
        {{- nindent 0 "" -}}targetPort: {{ toString .targetPort }}
      {{- else }}
        {{- fail "definitions.ServicePort: targetPort range error" }}
      {{- end }}
    {{- else }}
      {{- nindent 0 "" -}}targetPort: {{ toString .port }}
    {{- end }}
  {{- end }}
{{- end }}
