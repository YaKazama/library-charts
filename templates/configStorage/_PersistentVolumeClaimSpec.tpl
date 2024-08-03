{{- define "configStorage.PersistentVolumeClaimSpec" -}}
  {{- with . }}
    {{- $__accessModesAllowed := list "ReadWriteOnce" "ReadOnlyMany" "ReadWriteMany" "ReadWriteOncePod" }}
    {{- $__regexCheck := "(ReadWriteOnce|ReadOnlyMany|ReadWriteMany|ReadWriteOncePod)" }}
    {{- $__accessModes := include "base.fmt.slice" (dict "s" (list .accessModes) "c" $__regexCheck) }}
    {{- if $__accessModes }}
      {{- nindent 0 "" -}}accessModes:
      {{- $__accessModes | nindent 0 }}
    {{- end }}

    {{- $__dataSource := include "definitions.TypedLocalObjectReference" .dataSource | fromYaml }}
    {{- if $__dataSource }}
      {{- nindent 0 "" -}}dataSource:
        {{- toYaml $__dataSource | nindent 2 }}
    {{- end }}

    {{- $__dataSourceRef := include "definitions.TypedObjectReference" .dataSourceRef | fromYaml }}
    {{- if $__dataSourceRef }}
      {{- nindent 0 "" -}}dataSourceRef:
        {{- toYaml $__dataSourceRef | nindent 2 }}
    {{- end }}

    {{- $__resources := include "definitions.ResourceRequirements" .resources | fromYaml }}
    {{- if $__resources }}
      {{- nindent 0 "" -}}resources:
        {{- toYaml $__resources | nindent 2 }}
    {{- end }}

    {{- $__selector := include "definitions.LabelSelector" .selector | fromYaml }}
    {{- if $__selector }}
      {{- nindent 0 "" -}}selector:
        {{- toYaml $__selector | nindent 2 }}
    {{- end }}

    {{- $__storageClassName := include "base.string.empty" (dict "s" .storageClassName "empty" true) }}
    {{- if $__storageClassName }}
      {{- nindent 0 "" -}}storageClassName: {{ $__storageClassName }}
    {{- end }}

    {{- $__volumeModeAllowed := list "Filesystem" "Block" }}
    {{- $__volumeMode := include "base.string" .volumeMode }}
    {{- if mustHas $__volumeMode $__volumeModeAllowed }}
      {{- nindent 0 "" -}}volumeMode: {{ $__volumeMode }}
    {{- end }}

    {{- $__volumeName := include "base.string" .volumeName }}
    {{- if $__volumeName }}
      {{- nindent 0 "" -}}volumeName: {{ $__volumeName }}
    {{- end }}
  {{- end }}
{{- end }}


{{- define "configStorage.PersistentVolumeClaimSpec.old" -}}
  {{- $__accessModesAllowed := list "ReadWriteOnce" "ReadOnlyMany" "ReadWriteMany" "ReadWriteOncePod" }}

  {{- with . }}
    {{- if .accessModes }}
      {{- $__accessModes := list }}

      {{- if kindIs "slice" .accessModes }}
        {{- range .accessModes }}
          {{- if mustHas . $__accessModesAllowed }}
            {{- $__accessModes = mustAppend $__accessModes . }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "string" .accessModes }}
        {{- if mustRegexMatch "(ReadWriteOnce|ReadOnlyMany|ReadWriteMany|ReadWriteOncePod)((,)?\\s*)*" .accessModes }}
          {{- range (mustRegexSplit "(,)?\\s*" .accessModes -1) }}
            {{- $__accessModes = mustAppend $__accessModes . }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "configStorage.PersistentVolumeClaim.StatefulSet: .accessModes not support" }}
      {{- end }}

      {{- if $__accessModes }}
        {{- nindent 0 "" -}}accessModes:
        {{- toYaml (mustUniq $__accessModes) | nindent 0 }}
      {{- end }}
    {{- end }}

    {{- if .dataSource }}
      {{- nindent 0 "" -}}dataSource:
        {{- include "definitions.TypedLocalObjectReference" .dataSource | nindent 2 }}
    {{- end }}

    {{- if .dataSourceRef }}
      {{- nindent 0 "" -}}dataSourceRef:
        {{- include "definitions.TypedObjectReference" .dataSourceRef | nindent 2 }}
    {{- end }}

    {{- if or .resources .resourcesFiles }}
      {{- nindent 0 "" -}}resources:
      {{- if .resources }}
        {{- toYaml .resources | nindent 4 }}
      {{- else if .resourcesFiles }}
        {{- range $f, $v := .resourcesFiles }}
          {{- include "base.map.getValue" (dict "m" ($.Files.Get $f | fromYaml) "k" $v) | indent 4 }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- nindent 0 "" -}}selector:
      {{- include "definitions.LabelSelector" . | indent 2 }}

    {{- if .storageClassName }}
      {{- nindent 0 "" -}}storageClassName: {{ .storageClassName }}
    {{- end }}

    {{- if .volumeMode }}
      {{- nindent 0 "" -}}volumeMode: {{ .volumeMode }}
    {{- end }}

    {{- if .volumeName }}
      {{- nindent 0 "" -}}volumeName: {{ .volumeName }}
    {{- end }}
  {{- end }}
{{- end }}
