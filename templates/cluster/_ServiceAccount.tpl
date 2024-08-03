{{- define "cluster.ServiceAccount" -}}
  {{- $_ := set . "_kind" "ServiceAccount" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__automountServiceAccountToken := include "base.bool" .automountServiceAccountToken }}
  {{- if $__automountServiceAccountToken }}
    {{- nindent 0 "" -}}automountServiceAccountToken: {{ $__automountServiceAccountToken }}
  {{- end }}

  {{- $__imagePullSecrets := include "base.fmt.slice" (dict "s" (pluck "imagePullSecrets" .Context .Values) "define" "definitions.LocalObjectReference") }}
  {{- if $__imagePullSecrets }}
    {{- nindent 0 "" -}}imagePullSecrets:
    {{- $__imagePullSecrets | indent 0 }}
  {{- end }}

  {{- $__clean := list }}
  {{- $__secretsSrc := pluck "secrets" .Context .Values }}
  {{- range ($__secretsSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustAppend $__clean . }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- $__clean = mustAppend $__clean . }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- $__secrets := list }}
  {{- range ($__clean | mustUniq | mustCompact) }}
    {{- $__secrets = mustAppend $__secrets (include "definitions.ObjectReference" . | fromYaml) }}
  {{- end }}
  {{- if $__secrets }}
    {{- nindent 0 "" -}}secrets:
    {{- toYaml $__secrets | nindent 0 }}
  {{- end }}
{{- end }}
