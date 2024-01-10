{{- define "crds.tencent.TkeServiceConfig.Listeners.L4" -}}
  {{- with . }}
    {{- $__protocolAllowed := list "TCP" "UDP" }}
    {{- $__protocol := include "base.string" .protocol }}
    {{- if mustHas $__protocol $__protocolAllowed }}
      {{- nindent 0 "" -}}protocol: {{ $__protocol | upper }}
    {{- else }}
      {{- fail "crds.tencent.TkeServiceConfig.Listeners.L4: protocol must be exists, please set it with TCP or UDP." }}
    {{- end }}

    {{- $__port := include "base.int.scope" (list .port 1 65535) }}
    {{- if $__port }}
      {{- nindent 0 "" -}}port: {{ $__port }}
    {{- else }}
      {{- fail "crds.tencent.TkeServiceConfig.Listeners.L4: protocol must be exists, please set it with scope 1-65535." }}
    {{- end }}

    {{- $__deregisterTargetRst := include "base.bool" .deregisterTargetRst }}
    {{- if $__deregisterTargetRst }}
      {{- nindent 0 "" -}}deregisterTargetRst: {{ $__deregisterTargetRst }}
    {{- end }}

    {{- $__session := include "crds.tencent.TkeServiceConfig.Session" .session | fromYaml }}
    {{- if $__session }}
      {{- nindent 0 "" -}}session:
        {{- toYaml $__session | nindent 2 }}
    {{- end }}

    {{- $__healthCheck := include "crds.tencent.TkeServiceConfig.HealthCheck" .healthCheck | fromYaml }}
    {{- if $__healthCheck }}
      {{- nindent 0 "" -}}healthCheck:
        {{- toYaml $__healthCheck | nindent 2 }}
    {{- end }}

    {{- $__schedulerAllowed := list "WRR" "LEAST_CONN" }}
    {{- $__scheduler := include "base.string" .scheduler }}
    {{- if mustHas $__scheduler $__schedulerAllowed }}
      {{- nindent 0 "" -}}scheduler: {{ $__scheduler | upper }}
    {{- end }}
  {{- end }}
{{- end }}


{{- define "crds.tencent.TkeServiceConfig.Listeners.L7" -}}
  {{- with . }}
    {{- $__protocolAllowed := list "HTTP" "HTTPS" }}
    {{- $__protocol := include "base.string" .protocol }}
    {{- if mustHas $__protocol $__protocolAllowed }}
      {{- nindent 0 "" -}}protocol: {{ $__protocol | upper }}
    {{- else }}
      {{- fail "crds.tencent.TkeServiceConfig.Listeners.L7: protocol must be exists, please set it with HTTP or HTTPS." }}
    {{- end }}

    {{- $__port := include "base.int.scope" (list .port 1 65535) }}
    {{- if $__port }}
      {{- nindent 0 "" -}}port: {{ $__port }}
    {{- else }}
      {{- fail "crds.tencent.TkeServiceConfig.Listeners.L7: protocol must be exists, please set it with scope 1-65535." }}
    {{- end }}

    {{- $__defaultServer := include "base.string" .defaultServer }}
    {{- if $__defaultServer }}
      {{- nindent 0 "" -}}defaultServer: {{ $__defaultServer }}
    {{- end }}

    {{- $__keepaliveEnable := include "base.int" .keepaliveEnable }}
    {{- if $__keepaliveEnable }}
      {{- nindent 0 "" -}}keepaliveEnable: 1
    {{- end }}

    {{- $__domains := list }}
    {{- range (.domains | mustUniq | mustCompact) }}
      {{- $__domains = mustAppend $__domains (include "crds.tencent.TkeServiceConfig.Domain" . | fromYaml) }}
    {{- end }}
    {{- $__domains = $__domains | mustUniq | mustCompact }}
    {{- if $__domains }}
      {{- nindent 0 "" -}}domains:
      {{- toYaml $__domains | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
