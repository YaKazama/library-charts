{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#containerresizepolicy-v1-core
  - https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/
  descr:
  - 当 resourceName 或 name 不存在时, 视为无效
  - 已知问题
    - []map{ map{cpu:xx, memory:xx} } 最终只会出现 memory (即最后一个可用值)
    - resourceName restartPolicy 必需成对出现
    - name policy 必需成对出现
*/ -}}
{{- define "definitions.ContainerResizePolicy" -}}
  {{- with . }}
    {{- $__name := "" }}
    {{- $__policy := "" }}
    {{- $__resourceNameAllowed := list "cpu" "memory" }}
    {{- $__restartPolicyAllowed := list "NotRequired" "RestartContainer" }}

    {{- if kindIs "string" . }}
      {{- $__regexStr := "(cpu|memory):(NotRequired|RestartContainer)" }}
      {{- $__regexSplit := ":" }}

      {{- if mustRegexMatch $__regexStr . }}
        {{- $__val := mustRegexSplit $__regexSplit . -1 }}
        {{- if eq (len $__val) 2 }}
          {{- $__name = mustFirst $__val }}
          {{- $__policy = mustLast $__val }}
        {{- end }}
      {{- else }}
        {{- fail "definitions.ContainerResizePolicy: string invalid." }}
      {{- end }}
    {{- else if kindIs "map" . }}
      {{- $__val := dict }}
      {{- if and .resourceName .restartPolicy }}
        {{- if and (mustHas .resourceName $__resourceNameAllowed) (mustHas .restartPolicy $__restartPolicyAllowed) }}
          {{- $__val = mustMerge $__val (dict .resourceName .restartPolicy) }}
        {{- end }}
      {{- end }}
      {{- if and .name .policy }}
        {{- if and (mustHas .name $__resourceNameAllowed) (mustHas .policy $__restartPolicyAllowed) }}
          {{- $__val = mustMerge $__val (dict .name .policy) }}
        {{- end }}
      {{- end }}
      {{- range $k, $v := . }}
        {{- if and (mustHas $k $__resourceNameAllowed) (mustHas $v $__restartPolicyAllowed) }}
          {{- $__val = mustMerge $__val (dict $k $v) }}
        {{- end }}
      {{- end }}

      {{- range $k, $v := $__val }}
        {{- $__name = $k }}
        {{- $__policy = $v }}
      {{- end }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "string" . }}
          {{- $__regexStr := "(cpu|memory):(NotRequired|RestartContainer)" }}
          {{- $__regexSplit := ":" }}

          {{- if mustRegexMatch $__regexStr . }}
            {{- $__val := mustRegexSplit $__regexSplit . -1 }}
            {{- if eq (len $__val) 2 }}
              {{- $__name = mustFirst $__val }}
              {{- $__policy = mustLast $__val }}
            {{- end }}
          {{- else }}
            {{- fail "definitions.ContainerResizePolicy: string invalid." }}
          {{- end }}
        {{- else if kindIs "map" . }}
          {{- $__val := dict }}
          {{- if and .resourceName .restartPolicy }}
            {{- if and (mustHas .resourceName $__resourceNameAllowed) (mustHas .restartPolicy $__restartPolicyAllowed) }}
              {{- $__val = mustMerge $__val (dict .resourceName .restartPolicy) }}
            {{- end }}
          {{- end }}
          {{- if and .name .policy }}
            {{- if and (mustHas .name $__resourceNameAllowed) (mustHas .policy $__restartPolicyAllowed) }}
              {{- $__val = mustMerge $__val (dict .name .policy) }}
            {{- end }}
          {{- end }}
          {{- range $k, $v := . }}
            {{- if and (mustHas $k $__resourceNameAllowed) (mustHas $v $__restartPolicyAllowed) }}
              {{- $__val = mustMerge $__val (dict $k $v) }}
            {{- end }}
          {{- end }}

          {{- range $k, $v := $__val }}
            {{- $__name = $k }}
            {{- $__policy = $v }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- if and $__name $__policy }}
      {{- nindent 0 "" -}}resourceName: {{ $__name }}
      {{- nindent 0 "" -}}restartPolicy: {{ $__policy }}
    {{- end }}
  {{- end }}
{{- end }}
