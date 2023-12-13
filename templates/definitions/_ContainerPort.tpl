{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#containerport-v1-core
  descr:
  - .name 如果指定
    - 未匹配 $__regexName 正则表达式时, 会使用 .name .containerPort .protocol 进行拼接
  - 如果 ports 是字符串, 且符合 $__regexStringPorts 正则表达式, 则被视为 containerPort
*/ -}}
{{- define "definitions.ContainerPort" -}}
  {{- $__protocolList := list "TCP" "UDP" "SCTP" }}
  {{- $__regexIP := "^((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\/\\d+)?$" }}
  {{- $__regexName := "^[A-Za-z]+-(6553[0-5]|655[0-2][0-9]|65[0-4][0-9]{2}|6[0-4][0-9]{3}|[1-5][0-9]{4}|[1-9][0-9]{1,3}|[1-9])-(tcp|udp|sctp)$" }}
  {{- $__regexStringPorts := "(\\d+((,)?\\s)*)*" }}

  {{- if kindIs "string" . }}
    {{- if mustRegexMatch $__regexStringPorts . }}
      {{- $__ports := mustRegexSplit "(,)?\\s*" . -1 }}
      {{- range $__ports }}
        {{- nindent 0 "" -}}- containerPort: {{ . }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- range . }}
      {{- with . }}
        {{- if .containerPort }}
          {{- nindent 0 "" -}}- containerPort: {{ int .containerPort }}
        {{- else }}
          {{- fail "containerPort not found" }}
        {{- end }}

        {{- if mustRegexMatch $__regexIP .hostIP }}
          {{- nindent 2 "" -}}hostIP: {{ .hostIP }}
        {{- end }}

        {{- if .hostPort }}
        {{- nindent 2 "" -}}hostPort: {{ .hostPort }}
        {{- end }}

        {{- if .name }}
          {{- if mustRegexMatch $__regexName .name }}
            {{- nindent 2 "" -}}name: {{ .name }}
          {{- else }}
            {{- nindent 2 "" -}}name: {{ printf "%s-%s-%s" .name (int .containerPort | toString) (lower (coalesce .protocol "TCP")) }}
          {{- end }}
        {{- end }}

        {{- if mustHas .protocol $__protocolList }}
          {{- nindent 2 "" -}}protocol: {{ coalesce (upper .protocol) "TCP" }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
