{{- define "cluster.RoleBinding" -}}
  {{- $_ := set . "_kind" "RoleBinding" }}

  {{- nindent 0 "" -}}apiVersion: rbac.authorization.k8s.io/v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__clean := dict "apiGroup" "rbac.authorization.k8s.io" "kind" "ClusterRole" }}
  {{- $__roleRefSrc := pluck "roleRef" .Context .Values }}
  {{- range ($__roleRefSrc | mustUniq | mustCompact) }}
    {{- if kindIs "string" . }}
      {{- $_ := set $__clean "name" . }}
    {{- else if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean (pick . "name") }}
    {{- else }}
      {{- fail "cluster.ClusterRoleBinding: roleRef not support, please use string or map." }}
    {{- end }}
  {{- end }}
  {{- $__role := include "definitions.RoleRef" $__clean | fromYaml }}
  {{- if $__role }}
    {{- nindent 0 "" -}}roleRef:
      {{- toYaml $__role | nindent 2 }}
  {{- end }}

  {{- $__clean := list }}
  {{- $__subjectsSrc := pluck "subjects" .Context .Values }}
  {{- range ($__subjectsSrc | mustUniq | mustCompact) }}
    {{- if kindIs "string" . }}
      {{- $__regexStr := "^(User|Group)\\s*\\|.*" }}
      {{- $__regexSplit := "\\s*\\|\\s*" }}
      {{- $__val := mustRegexSplit $__regexSplit . -1 }}
      {{- if eq (len $__val) 2 }}
        {{- $__clean = mustAppend $__clean (dict "kind" (mustFirst $__val) "name" (mustLast $__val)) }}
      {{- end }}
    {{- else if kindIs "slice" . }}
      {{- $__clean = concat $__clean . }}
    {{- else if kindIs "map" . }}
      {{- $__clean = mustAppend $__clean . }}
    {{- else }}
      {{- fail "cluster.ClusterRoleBinding: subjects not support, please use slice or map." }}
    {{- end }}
  {{- end }}
  {{- $__subjects := list }}
  {{- range $__clean | mustUniq | mustCompact }}
    {{- $__subjects = mustAppend $__subjects (include "others.Subject.v1" . | fromYaml) }}
  {{- end }}
  {{- $__subjects = $__subjects | mustUniq | mustCompact }}
  {{- if $__subjects }}
    {{- nindent 0 "" -}}subjects:
    {{- toYaml $__subjects | nindent 0 }}
  {{- end }}
{{- end }}
