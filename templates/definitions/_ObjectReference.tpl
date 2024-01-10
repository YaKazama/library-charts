{{- define "definitions.ObjectReference" -}}
  {{- with . }}
    {{- $__apiVersion := include "base.string" .apiVersion }}
    {{- if $__apiVersion }}
      {{- nindent 0 "" -}}apiVersion: {{ $__apiVersion }}
    {{- end }}

    {{- $__fieldPath := include "base.string" .fieldPath }}
    {{- if $__fieldPath }}
      {{- nindent 0 "" -}}fieldPath: {{ $__fieldPath }}
    {{- end }}

    {{- $__kind := include "base.string" .kind }}
    {{- if $__kind }}
      {{- nindent 0 "" -}}kind: {{ $__kind }}
    {{- end }}

    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- end }}

    {{- $__namespace := include "base.string" .namespace }}
    {{- if $__namespace }}
      {{- nindent 0 "" -}}namespace: {{ $__namespace }}
    {{- end }}

    {{- $__resourceVersion := include "base.string" .resourceVersion }}
    {{- if $__resourceVersion }}
      {{- nindent 0 "" -}}resourceVersion: {{ $__resourceVersion }}
    {{- end }}

    {{- $__uid := include "base.string" .uid }}
    {{- if $__uid }}
      {{- nindent 0 "" -}}uid: {{ $__uid }}
    {{- end }}
  {{- end }}
{{- end }}
