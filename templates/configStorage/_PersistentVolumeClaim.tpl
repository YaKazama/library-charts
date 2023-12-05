{{- define "configStorage.PersistentVolumeClaim" -}}
  {{- $_ := set . "_kind" "PersistentVolumeClaim" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: PersistentVolumeClaim
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__spec := include "configStorage.PersistentVolumeClaimSpec" . | trim }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- $__spec | nindent 2 }}
  {{- end }}
{{- end }}


{{- define "configStorage.PersistentVolumeClaim.StatefulSet" -}}
  {{- $__accessModesList := list "ReadWriteOnce" "ReadOnlyMany" "ReadWriteMany" "ReadWriteOncePod" }}

  {{- with . }}
    {{- if .name }}
      {{- nindent 0 "" -}}metadata:
        {{- nindent 2 "" -}}name: {{ .name }}
    {{- else }}
      {{- fail "configStorage.PersistentVolumeClaim.StatefulSet: .name must be exists" }}
    {{- end }}

    {{- if and .accessModes .storageClassName (or .size .storage) }}
      {{- nindent 0 "" -}}spec:
        {{- $__accessModes := list }}

        {{- if kindIs "slice" .accessModes }}
          {{- range .accessModes }}
            {{- if mustHas . $__accessModesList }}
              {{- $__accessModes = mustAppend $__accessModes . }}
            {{- end }}
          {{- end }}
        {{- else if kindIs "string" .accessModes }}
          {{- if mustRegexMatch "(ReadWriteOnce|ReadOnlyMany|ReadWriteMany|ReadWriteOncePod)(,\\s*)*" .accessModes }}
            {{- range (mustRegexSplit ",\\s*" .accessModes -1) }}
              {{- $__accessModes = mustAppend $__accessModes . }}
            {{- end }}
          {{- end }}
        {{- else }}
          {{- fail "configStorage.PersistentVolumeClaim.StatefulSet: .accessModes not support" }}
        {{- end }}

        {{- if $__accessModes }}
          {{- nindent 2 "" -}}accessModes:
          {{- toYaml (mustUniq $__accessModes) | nindent 2 }}
        {{- end }}

        {{- if .storageClassName }}
          {{- nindent 2 "" -}}storageClassName: {{ .storageClassName }}
        {{- end }}

        {{- if or .size .storage }}
          {{- nindent 2 "" -}}resources:
            {{- nindent 4 "" -}}requests:
              {{- nindent 6 "" -}}storage: {{ coalesce .size .storage "1Gi" }}
        {{- end }}
    {{- else }}
      {{- fail "configStorage.PersistentVolumeClaim.StatefulSet: .accessModes .storageClassName .storage must be exists" }}
    {{- end }}
  {{- end }}
{{- end }}
