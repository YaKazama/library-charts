{{- define "definitions.GRPCAction" -}}
  {{- with . }}
    {{- $__service := "" }}
    {{- $__port := "" }}

    {{- if kindIs "map" . }}
      {{- if and .service .port }}
        {{- $__service = include "base.string" .service }}
        {{- $__port = include "base.int" (int .port) }}
      {{- else }}
        {{- range $k, $v := . }}
          {{- $__service = include "base.string" $k }}
          {{- $__port = include "base.int" (int $v) }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- if and .service .port }}
            {{- $__service = include "base.string" .service }}
            {{- $__port = include "base.int" (int .port) }}
          {{- else }}
            {{- range $k, $v := . }}
              {{- $__service = include "base.string" $k }}
              {{- $__port = include "base.int" (int $v) }}
            {{- end }}
          {{- end }}
        {{- else if kindIs "string" . }}
          {{- $__regexSplit := ":" }}
          {{- $__val := mustRegexSplit $__regexSplit . -1 }}
          {{- if eq (len $__val) 2 }}
            {{- $__service = mustFirst $__val }}
            {{- $__port = mustLast $__val }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "string" . }}
      {{- $__regexSplit := ":" }}
      {{- $__val := mustRegexSplit $__regexSplit . -1 }}
      {{- if eq (len $__val) 2 }}
        {{- $__service = mustFirst $__val }}
        {{- $__port = mustLast $__val }}
      {{- end }}
    {{- else }}
      {{- fail "definitions.TCPSocketAction: not support, please use string (service:port), slice or map" }}
    {{- end }}

    {{- $__port = include "base.int.scope" (list $__port 1 65535) }}
    {{- if $__port }}
      {{- nindent 0 "" -}}port: {{ $__port }}
    {{- end }}

    {{- if $__service }}
      {{- nindent 0 "" -}}service: {{ $__service }}
    {{- end }}
  {{- end }}
{{- end }}
