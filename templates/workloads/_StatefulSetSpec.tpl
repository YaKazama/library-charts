{{- define "workloads.StatefulSetSpec" -}}
  {{- $__minReadySeconds := include "base.int" (coalesce .Context.minReadySeconds .Values.minReadySeconds) }}
  {{- if $__minReadySeconds }}
    {{- nindent 0 "" -}}minReadySeconds: {{ $__minReadySeconds }}
  {{- end }}

  {{- $__clean := dict }}
  {{- $__ordinals := pluck "ordinals" .Context .Values }}
  {{- range ($__ordinals | mustUniq | mustCompact) }}
    {{- if or (kindIs "string" .) (kindIs "float64" .) (kindIs "int" .) (kindIs "int64" .) }}
      {{- $__clean = dict "start" . }}
    {{- else if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__ordinals := include "definitions.StatefulSetOrdinals" $__clean | fromYaml }}
  {{- if $__ordinals }}
    {{- nindent 0 "" -}}ordinals:
      {{- toYaml $__ordinals | nindent 2 }}
  {{- end }}

  {{- $__podManagementPolicyAllowed := list "OrderedReady" "Parallel" }}
  {{- $__podManagementPolicy := include "base.string" (coalesce .Context.podManagementPolicy .Values.podManagementPolicy) }}
  {{- if mustHas $__podManagementPolicy $__podManagementPolicyAllowed }}
    {{- nindent 0 "" -}}podManagementPolicy: {{ $__podManagementPolicy }}
  {{- end }}

  {{- $__replicas := include "base.int" (coalesce .Context.replicas .Values.replicas) }}
  {{- if $__replicas }}
    {{- nindent 0 "" -}}replicas: {{ $__replicas }}
  {{- end }}

  {{- $__revisionHistoryLimit := include "base.int" (coalesce .Context.revisionHistoryLimit .Values.revisionHistoryLimit) }}
  {{- if $__revisionHistoryLimit }}
    {{- nindent 0 "" -}}revisionHistoryLimit: {{ $__revisionHistoryLimit }}
  {{- end }}

  {{- $__clean := dict "matchExpressions" list "matchLabels" dict }}
  {{- $__selectorSrc := pluck "selector" .Context .Values }}
  {{- range ($__selectorSrc | mustUniq | mustCompact) }}
    {{- $__valMatchExpressions := list }}
    {{- $__valMatchLabels := dict }}

    {{- if kindIs "map" . }}
      {{- if kindIs "slice" .matchExpressions }}
        {{- $__valMatchExpressions = concat $__valMatchExpressions .matchExpressions }}
      {{- end }}
      {{- if kindIs "map" .matchLabels }}
        {{- $__valMatchLabels = mustMerge $__valMatchLabels .matchLabels }}
      {{- end }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- if kindIs "slice" .matchExpressions }}
            {{- $__valMatchExpressions = concat $__valMatchExpressions .matchExpressions }}
          {{- end }}
          {{- if kindIs "map" .matchLabels }}
            {{- $__valMatchLabels = mustMerge $__valMatchLabels .matchLabels }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- $_ := set $__clean "matchExpressions" (concat $__clean.matchExpressions $__valMatchExpressions) }}
    {{- $_ := set $__clean "matchLabels" (mustMerge $__clean.matchLabels $__valMatchLabels) }}
  {{- end }}
  {{- $__selector := include "definitions.LabelSelector" $__clean | fromYaml }}
  {{- /*
    追加 labels 到 selector ，受 ignoreLabels 参数影响
  */ -}}
  {{- $__ignoreLabels := false }}
  {{- if eq ._kind "Namespace" }}
    {{- $__ignoreLabels = include "base.bool" (coalesce .Context.ignoreLabels .Values.ignoreLabels) }}
  {{- end }}
  {{- if not $__ignoreLabels }}
    {{- $__selector = mustMerge $__selector (include "base.labels" . | fromYaml) }}
  {{- end }}
  {{- if $__selector }}
    {{- nindent 0 "" -}}selector:
      {{- toYaml $__selector | nindent 2 }}
  {{- end }}

  {{- $__serviceName := include "base.string" (coalesce .Context.serviceName .Values.serviceName) }}
  {{- if $__serviceName }}
    {{- nindent 0 "" -}}serviceName: {{ $__serviceName }}
  {{- end }}

  {{- $__template := include "metadata.PodTemplateSpec" . | fromYaml }}
  {{- if $__template }}
    {{- nindent 0 "" -}}template:
      {{- toYaml $__template | nindent 2 }}
  {{- end }}

  {{- $__clean := dict }}
  {{- $__updateStrategySrc := pluck "updateStrategy" .Context .Values }}
  {{- range ($__updateStrategySrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__updateStrategy := include "definitions.StatefulSetUpdateStrategy" $__clean | fromYaml }}
  {{- if $__updateStrategy }}
    {{- nindent 0 "" -}}updateStrategy:
      {{- toYaml $__updateStrategy | nindent 2 }}
  {{- end }}

  {{- /*
    参考 service.ServiceSpec 下的 ports 处理
  */ -}}
  {{- $__clean := list }}
  {{- $__volumeClaimTemplatesSrc := pluck "volumeClaimTemplates" .Context .Values }}
  {{- range ($__volumeClaimTemplatesSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- if and .name .accessModes .storageClassName (or .size .storage) }}
        {{- $__clean = mustAppend $__clean (pick . "name" "accessModes" "storageClassName" "size" "storage") }}
      {{- end }}
      {{- range $k, $v := (omit . "name" "accessModes" "storageClassName" "size" "storage") }}
        {{- if kindIs "map" $v }}
          {{- if not .name }}
            {{- $_ := set $v "name" $k }}
          {{- end }}
          {{- if and .name .accessModes .storageClassName (or .size .storage) }}
            {{- $__clean = mustAppend $__clean $v }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- if and .name .accessModes .storageClassName (or .size .storage) }}
            {{- $__clean = mustAppend $__clean (pick . "name" "accessModes" "storageClassName" "size" "storage") }}
          {{- end }}
          {{- range $k, $v := (omit . "name" "accessModes" "storageClassName" "size" "storage") }}
            {{- if kindIs "map" $v }}
              {{- if not .name }}
                {{- $_ := set $v "name" $k }}
              {{- end }}
              {{- if and .name .accessModes .storageClassName (or .size .storage) }}
                {{- $__clean = mustAppend $__clean $v }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- $__val := list }}
  {{- range ($__clean | mustUniq | mustCompact) }}
    {{- $__val = mustAppend $__val (dict .name .) }}
  {{- end }}
  {{- $__volumeClaimTemplates := list }}
  {{- range $k, $v := include "base.map.merge" (dict "s" ($__val | mustUniq | mustCompact) "merge" true) | fromYaml }}
    {{- $__volumeClaimTemplates = mustAppend $__volumeClaimTemplates (include "configStorage.PersistentVolumeClaim.StatefulSet" $v | fromYaml) }}
  {{- end }}
  {{- $__volumeClaimTemplates = $__volumeClaimTemplates | mustUniq | mustCompact }}
  {{- if $__volumeClaimTemplates }}
    {{- nindent 0 "" -}}volumeClaimTemplates:
    {{- toYaml $__volumeClaimTemplates | nindent 0 }}
  {{- end }}
{{- end }}
