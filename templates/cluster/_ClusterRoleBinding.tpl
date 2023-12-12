{{- define "cluster.ClusterRoleBinding" -}}
  {{- $_ := set . "_kind" "ClusterRoleBinding" }}

  {{- nindent 0 "" -}}apiVersion: rbac.authorization.k8s.io/v1
  {{- nindent 0 "" -}}kind: ClusterRoleBinding
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- if or ._CTX.roleRef .Values.roleRef }}
    {{- $__roleRef := dict }}

    {{- $_ := set $__roleRef "apiGroup" "rbac.authorization.k8s.io" }}
    {{- $_ := set $__roleRef "kind" "ClusterRole" }}

    {{- if ._CTX.roleRef }}
      {{- if kindIs "string" ._CTX.roleRef }}
        {{- $_ := set $__roleRef "name" ._CTX.roleRef }}
      {{- else if kindIs "map" ._CTX.roleRef }}
        {{- $__roleRef = mustMerge $__roleRef (pick ._CTX.roleRef "name") }}
      {{- else }}
        {{- fail "cluster.ClusterRoleBinding: .roleRef not support" }}
      {{- end }}
    {{- end }}
    {{- if .Values.roleRef }}
      {{- if kindIs "string" .Values.roleRef }}
        {{- $_ := set $__roleRef "name" .Values.roleRef }}
      {{- else if kindIs "map" .Values.roleRef }}
        {{- $__roleRef = mustMerge $__roleRef (pick .Values.roleRef "name") }}
      {{- else }}
        {{- fail "cluster.ClusterRoleBinding: .Values.roleRef not support" }}
      {{- end }}
    {{- end }}

    {{- $__role := include "definitions.RoleRef" $__roleRef | fromYaml }}
    {{- if $__role }}
      {{- nindent 0 "" -}}roleRef:
        {{- toYaml $__role | nindent 2 }}
    {{- end }}
  {{- end }}

  {{- if or ._CTX.subjects .Values.subjects }}
    {{- $__subjectsList := list }}

    {{- if ._CTX.subjects }}
      {{- if kindIs "slice" ._CTX.subjects }}
        {{- $__subjectsList = concat $__subjectsList ._CTX.subjects }}
      {{- else }}
        {{- fail "cluster.ClusterRoleBinding: .subjects not support" }}
      {{- end }}
    {{- end }}
    {{- if .Values.subjects }}
      {{- if kindIs "slice" .Values.subjects }}
        {{- $__subjectsList = concat $__subjectsList .Values.subjects }}
      {{- else }}
        {{- fail "cluster.ClusterRoleBinding: .Values.subjects not support" }}
      {{- end }}
    {{- end }}

    {{- $__subjects := list }}
    {{- range $__subjectsList }}
      {{- $__subjects = mustAppend $__subjects (include "others.Subject.v1" . | fromYaml) }}
    {{- end }}

    {{- $__subjects = mustCompact (mustUniq $__subjects) }}
    {{- if $__subjects }}
      {{- nindent 0 "" -}}subjects:
      {{- toYaml $__subjects | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
