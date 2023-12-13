{{- define "configStorage.PersistentVolumeClaimSpec" -}}
  {{- $__accessModesList := list "ReadWriteOnce" "ReadOnlyMany" "ReadWriteMany" "ReadWriteOncePod" }}

  {{- with . }}
    {{- if .accessModes }}
      {{- $__accessModes := list }}

      {{- if kindIs "slice" .accessModes }}
        {{- range .accessModes }}
          {{- if mustHas . $__accessModesList }}
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
