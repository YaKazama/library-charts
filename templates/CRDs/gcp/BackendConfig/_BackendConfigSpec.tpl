{{- define "crds.gcp.BackendConfig.BackendConfigSpec" -}}
  {{- /*
    后端服务超时
  */ -}}
  {{- $__timeoutSec := include "base.int.scope" (list (coalesce .Context.timeoutSec .Values.timeoutSec) 1 9223372036854775807) }}
  {{- if $__timeoutSec }}
    {{- nindent 0 "" -}}timeoutSec: {{ $__timeoutSec }}
  {{- end }}

  {{- /*
    连接排空超时
    超时持续时间可以介于 0 到 3600 秒之间。默认值为 0 ，此值也会停用连接排空。
  */ -}}
  {{- $__clean := dict }}
  {{- $__connectionDrainingSrc := pluck "connectionDraining" .Context .Values }}
  {{- range ($__connectionDrainingSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__connectionDraining := include "crds.gcp.BackendConfig.ConnectionDraining" $__clean | fromYaml }}
  {{- if $__connectionDraining }}
    {{- nindent 0 "" -}}connectionDraining:
      {{- toYaml $__connectionDraining | nindent 2 }}
  {{- end }}

  {{- /*
    自定义健康检查配置
  */ -}}
  {{- $__clean := dict }}
  {{- $__healthCheckSrc := pluck "healthCheck" .Context .Values }}
  {{- range ($__healthCheckSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__healthCheck := include "crds.gcp.BackendConfig.HealthCheck" $__clean | fromYaml }}
  {{- if $__healthCheck }}
    {{- nindent 0 "" -}}healthCheck:
      {{- toYaml $__healthCheck | nindent 2 }}
  {{- end }}

  {{- /*
    HTTP 访问日志记录
  */ -}}
  {{- $__clean := dict }}
  {{- $__loggingSrc := pluck "logging" .Context .Values }}
  {{- range ($__loggingSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__logging := include "crds.gcp.BackendConfig.Logging" $__clean | fromYaml }}
  {{- if $__logging }}
    {{- nindent 0 "" -}}logging:
      {{- toYaml $__logging | nindent 2 }}
  {{- end }}
{{- end }}
