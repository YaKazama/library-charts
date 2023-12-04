{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#containerresizepolicy-v1-core
  - https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/
  descr:
  - 当 resourceName 不存在时, 视为无效
*/ -}}
{{- define "definitions.ContainerResizePolicy" -}}
  {{- $__resourceNameList := list "cpu" "memory" }}
  {{- $__restartPolicyList := list "NotRequired" "RestartContainer" }}

  {{- with . }}
    {{- if or .resourceName .name }}
      {{- nindent 0 "" -}}- resourceName: {{ coalesce .resourceName .name }}

      {{- if or .restartPolicy .policy }}
        {{- nindent 2 "" -}}  restartPolicy: {{ coalesce .restartPolicy .policy "NotRequired" }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
