{{- define "cluster.ServiceAccount" -}}
  {{- $_ := set . "_kind" "ServiceAccount" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: ServiceAccount
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- if or (kindIs "bool" ._CTX.automountServiceAccountToken) (kindIs "bool" .Values.automountServiceAccountToken) }}
    {{- nindent 0 "" -}}automountServiceAccountToken: {{ coalesce (toString ._CTX.automountServiceAccountToken) (toString .Values.automountServiceAccountToken) }}
  {{- end }}

  {{- if or ._CTX.imagePullSecrets .Values.imagePullSecrets }}
    {{- $__imagePullSecretsList := list }}
    {{- if ._CTX.imagePullSecrets }}
      {{- $__imagePullSecretsList = concat ._CTX.imagePullSecrets }}
    {{- end }}
    {{- if .Values.imagePullSecrets }}
      {{- $__imagePullSecretsList = concat $__imagePullSecretsList .Values.imagePullSecrets }}
    {{- end }}
    {{- if $__imagePullSecretsList }}
      {{- nindent 0 "" -}}imagePullSecrets:
        {{- range $v := $__imagePullSecretsList | uniq }}
          {{- nindent 0 "" -}}- {{ include "definitions.LocalObjectReference" $v | trim }}
        {{- end }}
    {{- end }}
  {{- end }}

  {{- if or ._CTX.secrets .Values.secrets }}
    {{- $__cleanData := list }}
    {{- $__secrets := list }}

    {{- if ._CTX.secrets }}
      {{- $__cleanData = concat $__cleanData ._CTX.secrets }}
    {{- end }}
    {{- if .Values.target }}
      {{- $__cleanData = concat $__cleanData .Values.secrets }}
    {{- end }}

    {{- range $__cleanData }}
      {{- $__secrets = mustAppend $__secrets (include "definitions.ObjectReference" . | fromYaml) }}
    {{- end }}
    {{- if $__secrets }}
      {{- nindent 0 "" -}}secrets:
      {{- toYaml $__secrets | nindent 0 }}
    {{- end }}
  {{- end }}

{{- end }}
