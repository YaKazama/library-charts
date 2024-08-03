{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#networkpolicyport-v1-networking-k8s-io
*/ -}}
{{- define "definitions.NetworkPolicyPort" -}}
  {{- with . }}
    {{- $__regexCheckPortStr := "[a-z][a-z0-9]*[a-z]" }}
    {{- if regexMatch $__regexCheckPortStr (toString .port) }}
      {{- $__port := include "base.string" .port }}
      {{- if $__port }}
        {{- nindent 0 "" -}}port: {{ $__port }}
      {{- end }}
    {{- else }}
      {{- $__port := include "base.int" .port }}
      {{- if $__port }}
        {{- $__port := include "base.int.scope" (list .port 1 65535) }}
        {{- nindent 0 "" -}}port: {{ $__port }}
      {{- end }}

      {{- if .endPort }}
        {{- $__endPort := include "base.int" .endPort }}
        {{- if and $__endPort (gt $__endPort $__port) }}
          {{- $__endPort := include "base.int.scope" (list .endPort 1 65535) }}
          {{- nindent 0 "" -}}endPort: {{ $__endPort }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- $__protocolAllowed := list "TCP" "UDP" "SCTP" }}
    {{- $__protocol := include "base.string" .protocol | upper }}
    {{- if mustHas $__protocol $__protocolAllowed }}
      {{- nindent 0 "" -}}protocol: {{ (coalesce $__protocol "TCP") | upper }}
    {{- end }}

  {{- end }}
{{- end }}
