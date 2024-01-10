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
  {{- $__clean := dict }}
  {{- $__defaultBackendSrc := pluck "defaultBackend" .Context .Values }}
  {{- range ($__defaultBackendSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__defaultBackend := include "definitions.IngressBackend" $__clean | fromYaml }}
  {{- if $__defaultBackend }}
    {{- nindent 0 "" -}}defaultBackend:
      {{- toYaml $__defaultBackend | nindent 2 }}
  {{- end }}

  {{- $__ingressClassName := include "base.string" (coalesce .Context.ingressClassName .Values.ingressClassName) }}
  {{- if $__ingressClassName }}
    {{- nindent 0 "" -}}ingressClassName: {{ $__ingressClassName }}
  {{- end }}

  {{- $__clean := list }}
  {{- $__rulesSrc := pluck "rules" .Context .Values }}
  {{- range ($__rulesSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustAppend $__clean . }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- $__clean = mustAppend $__clean . }}
        {{- else if kindIs "slice" . }}
          {{- $__clean = concat $__clean . }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- $__rules := list }}
  {{- range $k, $v := include "base.map.merge" (dict "s" ($__clean | mustUniq | mustCompact)) | fromYaml }}
    {{- $__rules = mustAppend $__rules (include "definitions.IngressRule" (dict "host" $k "http" $v) | fromYaml) }}
  {{- end }}
  {{- $__rules = $__rules | mustUniq | mustCompact }}
  {{- if $__rules }}
    {{- nindent 0 "" -}}rules:
    {{- toYaml $__rules | nindent 0 }}
  {{- end }}

  {{- $__clean := list }}
  {{- $__cleanWithoutHosts := list }}
  {{- $__tlsSrc := pluck "tls" .Context .Values }}
  {{- range ($__tlsSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- if and .hosts .secretName }}
        {{- $__clean = mustAppend $__clean (pick . "hosts" "secretName") }}
      {{- end }}
      {{- range $k, $v := (omit . "hosts" "secretName") }}
        {{- $__clean = mustAppend $__clean (dict "secretName" $k "hosts" $v) }}
      {{- end }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- if and .hosts .secretName }}
            {{- $__clean = mustAppend $__clean (pick . "hosts" "secretName") }}
          {{- end }}
          {{- range $k, $v := (omit . "hosts" "secretName") }}
            {{- $__clean = mustAppend $__clean (dict "secretName" $k "hosts" $v) }}
          {{- end }}
        {{- else if kindIs "string" . }}
          {{- $__cleanWithoutHosts = mustAppend $__cleanWithoutHosts (dict "secretName" .) }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "string" . }}
      {{- $__cleanWithoutHosts = mustAppend $__cleanWithoutHosts (dict "secretName" .) }}
    {{- end }}
  {{- end }}
  {{- $__valTls := list }}
  {{- if $__clean }}
    {{- $__val := list }}
    {{- range ($__clean | mustUniq | mustCompact) }}
      {{- with (include "definitions.IngressTLS" . | fromYaml) }}
        {{- $__val = mustAppend $__val (dict .secretName .hosts) }}
      {{- end }}
    {{- end }}
    {{- range $k, $v := include "base.map.merge" (dict "s" ($__val | mustUniq | mustCompact)) | fromYaml }}
      {{- $__valTls = mustAppend $__valTls (dict "secretName" $k "hosts" $v) }}
    {{- end }}
  {{- end }}
  {{- if $__cleanWithoutHosts }}
    {{- range ($__cleanWithoutHosts | mustUniq | mustCompact) }}
      {{- $__valTls = mustAppend $__valTls (include "definitions.IngressTLS" . | fromYaml) }}
    {{- end }}
  {{- end }}
  {{- $__tls := list }}
  {{- range $k, $v := (include "base.map.merge.single" (dict "s" ($__valTls | mustUniq | mustCompact) "k" "secretName") | fromYaml) }}
    {{- $__tls = mustAppend $__tls $v }}
  {{- end }}
  {{- if $__tls }}
    {{- nindent 0 "" -}}tls:
    {{- toYaml $__tls | nindent 0 }}
  {{- end }}
{{- end }}
