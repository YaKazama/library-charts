{{- /*
  variables (priority):
  - ._CTX.labels .Values.labels
  variables (bool):
  - ._CTX.helmLabels .Values.helmLabels: 是否展示内置的 HELM 相关的 Labels
    - true
    - false (默认值)
  reference:
  descr:
  - 默认会统一添加 name 标签
  - ._CTX.labels .Values.labels 会进行追加处理，但会覆盖同名 Key 的内容
  - HELM 相关的 Labels 同样会覆盖 ._CTX.labels .Values.labels 中出现的同名 Key 的内容
*/ -}}
{{- define "base.labels" -}}
  {{- $_ := set . "__baseLabels" dict }}

    {{- range $k, $v := ._CTX.annotations }}
      {{- $_ := set .__baseLabels $k $v }}
    {{- end }}

    {{- range $k, $v := .Values.annotations }}
      {{- $_ := set .__baseLabels $k $v }}
    {{- end }}

    {{- /*
      添加 HELM 相关的 Labels
      会覆盖已出现的同名 Key 的内容
    */ -}}
    {{- if or ._CTX.helmLabels .Values.helmLabels }}
      {{- $_ := set .__baseLabels "helm.sh/chart" (include "base.chart" .) }}
      {{- $_ := set .__baseLabels "app.kubernetes.io/version" (.Chart.AppVersion | quote) }}
      {{- $_ := set .__baseLabels "app.kubernetes.io/managed-by" .Release.Service }}
    {{- end }}

    {{- if .__baseLabels }}
      {{- -}}name: {{ include "base.fullname" . }}
      {{- range $k, $v := .__baseLabels }}
        {{- $k | nindent 0 }}: {{ $v }}
      {{- end }}
    {{- end }}

  {{- $_ := unset . "__baseLabels" }}
{{- end }}
