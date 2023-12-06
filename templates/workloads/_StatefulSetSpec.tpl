{{- define "workloads.StatefulSetSpec" -}}
  {{- if or ._CTX.minReadySeconds (kindIs "float64" ._CTX.minReadySeconds) .Values.minReadySeconds (kindIs "float64" .Values.minReadySeconds) }}
    {{- nindent 0 "" -}}minReadySeconds: {{ coalesce ._CTX.minReadySeconds .Values.minReadySeconds (int 0) }}
  {{- end }}

  {{- if or ._CTX.ordinals (kindIs "float64" ._CTX.ordinals) .Values.ordinals (kindIs "float64" .Values.ordinals) }}
    {{- nindent 0 "" -}}ordinals:
    {{- include "definitions.StatefulSetOrdinals" (coalesce ._CTX.ordinals .Values.ordinals) | indent 2 }}
  {{- end }}

  {{- $__podManagementPolicyList := list "OrderedReady" "Parallel" }}
  {{- if or (mustHas ._CTX.podManagementPolicy $__podManagementPolicyList) (mustHas .Values.podManagementPolicy $__podManagementPolicyList) }}
    {{- nindent 0 "" -}}podManagementPolicy: {{ coalesce ._CTX.podManagementPolicy .Values.podManagementPolicy "OrderedReady" }}
  {{- end }}

  {{- if or ._CTX.revisionHistoryLimit .Values.revisionHistoryLimit }}
    {{- nindent 0 "" -}}revisionHistoryLimit: {{ coalesce ._CTX.revisionHistoryLimit .Values.revisionHistoryLimit 10 }}
  {{- end }}

  {{- if or ._CTX.replicas (kindIs "float64" ._CTX.replicas) .Values.replicas (kindIs "float64" .Values.replicas) }}
    {{- nindent 0 "" -}}replicas: {{ coalesce (toString ._CTX.replicas) (toString .Values.replicas) (toString 1) }}
  {{- end }}

  {{- if or ._CTX.serviceName .Values.serviceName }}
    {{- nindent 0 "" -}}serviceName: {{ coalesce ._CTX.serviceName .Values.serviceName }}
  {{- end }}

  {{- if or ._CTX.updateStrategy .Values.updateStrategy }}
    {{- nindent 0 "" -}}updateStrategy:
    {{- include "definitions.StatefulSetUpdateStrategy" (coalesce ._CTX.updateStrategy .Values.updateStrategy) | indent 2 }}
  {{- end }}

  {{- if or ._CTX.volumeClaimTemplates .Values.volumeClaimTemplates }}
    {{- $__vct := list }}
    {{- $__vctVal := list }}

    {{- if ._CTX.volumeClaimTemplates }}
      {{- if kindIs "slice" ._CTX.volumeClaimTemplates }}
        {{- $__vctVal = concat $__vctVal ._CTX.volumeClaimTemplates }}
      {{- else if kindIs "map" ._CTX.volumeClaimTemplates }}
        {{- range $k, $v := ._CTX.volumeClaimTemplates }}
          {{- $_ := set $v "name" $k }}
          {{- $__vctVal = mustAppend $__vctVal $v }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- if .Values.volumeClaimTemplates }}
      {{- if kindIs "slice" .Values.volumeClaimTemplates }}
        {{- $__vctVal = concat $__vctVal .Values.volumeClaimTemplates }}
      {{- else if kindIs "map" .Values.volumeClaimTemplates }}
        {{- range $k, $v := .Values.volumeClaimTemplates }}
          {{- $_ := set $v "name" $k }}
          {{- $__vctVal = mustAppend $__vctVal $v }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- if $__vctVal }}
      {{- range $__vctVal }}
        {{- $__vct = mustAppend $__vct (include "configStorage.PersistentVolumeClaim.StatefulSet" . | fromYaml) }}
      {{- end }}
    {{- end }}
    {{- if (mustCompact (mustUniq $__vct)) }}
      {{- nindent 0 "" -}}volumeClaimTemplates:
      {{- toYaml (mustCompact (mustUniq $__vct)) | nindent 0 }}
    {{- end }}
  {{- end }}

  {{- nindent 0 "" -}}selector:
    {{- include "definitions.LabelSelector" . | indent 2 }}

  {{- nindent 0 "" -}}template:
    {{- include "metadata.PodTemplateSpec" . | indent 2 }}
{{- end }}
