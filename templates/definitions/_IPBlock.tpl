{{- /*
  reference:

*/ -}}
{{- define "definitions.IPBlock" -}}
  {{- with . }}
    {{- $__cidr := include "base.string" .cidr }}
    {{- if $__cidr }}
      {{- nindent 0 "" -}}cidr: {{ $__cidr }}
    {{- end }}

    {{- $__except := include "base.fmt.slice" (dict "s" (list .except)) }}
    {{- if $__except }}
      {{- nindent 0 "" -}}except:
      {{- $__except | nindent 0 }}
    {{- end }}

  {{- end }}
{{- end }}
