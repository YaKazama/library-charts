{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#secretvolumesource-v1-core
  - https://kubernetes.io/docs/concepts/configuration/secret/
*/ -}}
{{- define "definitions.SecretVolumeSource" -}}
  {{- with . }}
    {{- $__defaultMode := include "base.fmt" (dict "s" (toString .defaultMode) "r" "^(0[0124]{3}|[1-9]?[0-9]|[1-4][0-9]{2}|50[0-9]|51[01])$") }}
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

    {{- $__optional := include "base.bool" .optional }}
    {{- if $__optional }}
      {{- nindent 0 "" -}}optional: {{ $__optional }}
    {{- end }}

    {{- $__secretName := include "base.string" (coalesce .secretName .name) }}
    {{- if $__secretName }}
      {{- nindent 0 "" -}}secretName: {{ $__secretName }}
    {{- else }}
      {{- fail "definitions.SecretVolumeSource: .secretName or .name must be exists" }}
    {{- end }}
  {{- end }}
{{- end }}
