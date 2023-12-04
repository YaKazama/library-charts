{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#toleration-v1-core
  - https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
*/ -}}
{{- define "definitions.Toleration" -}}
  {{- $__effectList := list "NoSchedule" "PreferNoSchedule" "NoExecute" }}
  {{- $__operatorList := list "Exists" "Equal" }}

  {{- with . }}
    {{- range . }}
      {{- if .key }}
        {{- nindent 0 "" -}}- key: {{ .key }}

        {{- if mustHas .operator $__operatorList }}
          {{- nindent 2 "" -}}  operator: {{ .operator }}
        {{- else }}
          {{- fail "tolerations.operator not support" }}
        {{- end }}
      {{- else }}
        {{- if mustHas .operator $__operatorList }}
          {{- if eq .operator "Exists" }}
            {{- nindent 0 "" -}}- operator: {{ .operator }}
          {{- end }}
        {{- else }}
          {{- fail "tolerations.operator not support" }}
        {{- end }}
      {{- end }}

      {{- if and .value (mustHas .operator $__operatorList) (ne .operator "Exists") }}
        {{- nindent 2 "" -}}  value: {{ .value }}
      {{- end }}

      {{- if mustHas .effect $__effectList }}
        {{- nindent 2 "" -}}  effect: {{ .effect }}
      {{- end }}

      {{- if and .tolerationSeconds (ge (int .tolerationSeconds) 0) (eq .effect "NoExecute") }}
        {{- nindent 2 "" -}}  tolerationSeconds: {{ int .tolerationSeconds }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
