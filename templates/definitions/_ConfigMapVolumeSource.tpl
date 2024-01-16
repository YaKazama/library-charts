{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#configmapvolumesource-v1-core
  - https://kubernetes.io/docs/concepts/storage/volumes/#configmap
*/ -}}
{{- define "definitions.ConfigMapVolumeSource" -}}
  {{- with . }}
    {{- $__defaultMode := include "base.fmt" (dict "s" .defaultMode "r" "^(0[0-7]{3}|[1-9]?[0-9]|[1-4][0-9]{2}|50[0-9]|51[01])$") }}
    {{- if $__defaultMode }}
      {{- nindent 0 "" -}}defaultMode: {{ coalesce $__defaultMode "0644" }}
    {{- end }}

    {{- $__items := list }}
    {{- $__clean := list }}
    {{- if kindIs "slice" .items }}
      {{- $__clean = concat $__clean .items }}
    {{- else if kindIs "map" .items }}
      {{- $__clean = mustAppend $__clean (pick .items "key" "mode" "path") }}
    {{- end }}
    {{- range ($__clean | mustUniq | mustCompact) }}
      {{- $__items = mustAppend $__items (include "definitions.KeyToPath" . | fromYaml) }}
    {{- end }}
    {{- if $__items }}
      {{- nindent 0 "" -}}items:
      {{- toYaml $__items | nindent 0 }}
    {{- end }}

    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- else }}
      {{- fail "definitions.ConfigMapVolumeSource: name must be exists" }}
    {{- end }}

    {{- $__optional := include "base.bool" .optional }}
    {{- if $__optional }}
      {{- nindent 0 "" -}}optional: {{ $__optional }}
    {{- end }}
  {{- end }}
{{- end }}
