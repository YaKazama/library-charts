{{- define "definitions.TCPSocketAction" -}}
  {{- with . }}
    {{- $__host := "" }}
    {{- $__port := "" }}

    {{- if kindIs "map" . }}
      {{- if and .host .port }}
        {{- $__host = include "base.string" .host }}
        {{- $__port = include "base.int" (int .port) }}
      {{- else }}
        {{- range $k, $v := . }}
          {{- $__host = include "base.string" $k }}
          {{- $__port = include "base.int" (int $v) }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- if and .host .port }}
            {{- $__host = include "base.string" .host }}
            {{- $__port = include "base.int" (int .port) }}
          {{- else }}
            {{- range $k, $v := . }}
              {{- $__host = include "base.string" $k }}
              {{- $__port = include "base.int" (int $v) }}
            {{- end }}
          {{- end }}
        {{- else if kindIs "string" . }}
          {{- $__regexSplit := ":" }}
          {{- $__val := mustRegexSplit $__regexSplit . -1 }}
          {{- if eq (len $__val) 2 }}
            {{- $__host = mustFirst $__val }}
            {{- $__port = mustLast $__val }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "string" . }}
      {{- $__regexSplit := ":" }}
      {{- $__val := mustRegexSplit $__regexSplit . -1 }}
      {{- if eq (len $__val) 2 }}
        {{- $__host = mustFirst $__val }}
        {{- $__port = mustLast $__val }}
      {{- end }}
    {{- else }}
      {{- fail "definitions.TCPSocketAction: not support, please use string (host:port), slice or map" }}
    {{- end }}

    {{- if $__host }}
      {{- nindent 0 "" -}}host: {{ $__host }}
    {{- end }}

    {{- $__port = include "base.int.scope" (list $__port 1 65535) }}
    {{- if $__port }}
      {{- nindent 0 "" -}}port: {{ $__port }}
    {{- end }}
  {{- end }}
{{- end }}
