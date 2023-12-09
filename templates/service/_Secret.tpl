{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#secret-v1-core
  - https://kubernetes.io/docs/concepts/configuration/secret/
  descr:
  - type = Opaque 或 kubernetes.io/service-account-token 可以创建空 secret
    - type = kubernetes.io/service-account-token 必需要 annotaions 包括 kubernetes.io/service-account.name
      - 若定义了 annotations , 同时又出现了 serviceAccountName , 则 serviceAccountName 的值会覆盖 annotations 中的值
      - 参考："base.annotations"
*/ -}}
{{- define "configStorage.Secret" -}}
  {{- $_ := set . "_kind" "Secret" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: Secret
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- if or (and ._CTX.immutable (kindIs "bool" ._CTX.immutable)) (and .Values.immutable (kindIs "bool" .Values.immutable)) }}
    {{- nindent 0 "" -}}immutable: true
  {{- end }}

  {{- /*
    for type
  */ -}}
  {{- $__typeList := list "Opaque" "kubernetes.io/service-account-token" "kubernetes.io/dockercfg" "kubernetes.io/dockerconfigjson" "kubernetes.io/basic-auth" "kubernetes.io/ssh-auth" "kubernetes.io/tls" "bootstrap.kubernetes.io/token" }}

  {{- $__type := coalesce ._CTX.type .Values.type "Opaque" }}
  {{- if mustHas $__type $__typeList }}
    {{- nindent 0 "" -}}type: {{ coalesce ._CTX.type .Values.type "Opaque" }}
  {{- end }}

  {{- /*
    for data
  */ -}}
  {{- if or ._CTX.data .Values.data ._CTX.dataFiles .Values.dataFiles }}
    {{- $__data := dict }}
    {{- $__dataFiles := dict }}

    {{- if kindIs "map" ._CTX.data }}
      {{- $__data = mustMerge $__data ._CTX.data }}
    {{- end }}
    {{- if kindIs "map" .Values.data }}
      {{- $__data = mustMerge $__data .Values.data }}
    {{- end }}

    {{- if kindIs "slice" ._CTX.dataFiles }}
      {{- range ._CTX.dataFiles }}
        {{- $__dataFiles = mustMerge $__dataFiles (dict (base .) ($.Files.Get .)) }}
      {{- end }}
    {{- else if kindIs "map" ._CTX.dataFiles }}
      {{- range $f, $p := ._CTX.dataFiles }}
        {{- $__dataFiles = mustMerge $__dataFiles (dict (base $f) ($.Files.Get $p)) }}
      {{- end }}
    {{- end }}
    {{- if kindIs "slice" .Values.dataFiles }}
      {{- range .Values.dataFiles }}
        {{- $__dataFiles = mustMerge $__dataFiles (dict (base .) ($.Files.Get .)) }}
      {{- end }}
    {{- else if kindIs "map" .Values.dataFiles }}
      {{- range $f, $p := .Values.dataFiles }}
        {{- $__dataFiles = mustMerge $__dataFiles (dict (base $f) ($.Files.Get $p)) }}
      {{- end }}
    {{- end }}

    {{- if or (eq $__type "kubernetes.io/dockercfg") (eq $__type "kubernetes.io/dockerconfigjson") }}
      {{- $__docker := dict }}
      {{- $__dockerAuth := dict }}
      {{- $__cleanData := dict }}

      {{- /*
        处理 data dataFiles
        descr:
        - data 优先级比 dataFiles 更高
        - 从文件中获取配置时，会遍历所有文件，查找对应的关键字
          - 不保证顺序及准确性
          - 当只有一个文件时不会出现顺序问题
          - 如果有文件名称为 .dockercfg 或 .dockerconfigjson 会被视为可用配置而直接生效且优先级最高
        - ".dockercfg" 或 ".dockerconfigjson" 具有唯一性，其他仓库配置，需要创建新的 Secret 资源
      */ -}}
      {{- $__cleanData = mustMerge $__cleanData (pick $__data "server" "username" "password" "email") }}

      {{- if and (hasKey $__dataFiles ".dockercfg") (eq $__type "kubernetes.io/dockercfg") }}
        {{- $__docker = dict ".dockercfg" (get $__dataFiles ".dockercfg") }}
      {{- else if and (hasKey $__dataFiles ".dockerconfigjson") (eq $__type "kubernetes.io/dockerconfigjson") }}
        {{- $__docker = dict ".dockerconfigjson" (get $__dataFiles ".dockerconfigjson") }}
      {{- else }}
        {{- range $f, $p := $__dataFiles }}
          {{- $__cleanData = mustMerge $__cleanData (pick ($p | fromYaml) "server" "username" "password" "email") }}
        {{- end }}

        {{- if not (hasKey $__cleanData "server") }}
          {{- fail "service.Secret: docker data.server not found" }}
        {{- end }}
        {{- if not (hasKey $__cleanData "username") }}
          {{- fail "service.Secret: docker data.username not found" }}
        {{- end }}
        {{- if not (hasKey $__cleanData "password") }}
          {{- fail "service.Secret: docker data.password not found" }}
        {{- end }}
        {{- $_ := set $__cleanData "auth" ((printf "%s:%s" $__cleanData.username $__cleanData.password) | b64enc) }}
        {{- $_ := set $__dockerAuth $__cleanData.server (pick $__cleanData "username" "password" "email" "auth") }}

        {{- if eq $__type "kubernetes.io/dockercfg" }}
          {{- $__docker = dict ".dockercfg" ($__dockerAuth | mustToJson) }}
        {{- else if eq $__type "kubernetes.io/dockerconfigjson" }}
          {{- $__docker = dict ".dockerconfigjson" (dict "auths" $__dockerAuth | mustToJson) }}
        {{- end }}
      {{- end }}
      {{- $__data = dict }}
      {{- $__dataFiles = $__docker }}

    {{- else if eq $__type "kubernetes.io/basic-auth" }}
      {{- $__cleanData := dict }}

      {{- $__cleanData = mustMerge $__cleanData (pick $__data "username" "password") }}
      {{- range $f, $p := $__dataFiles }}
        {{- $__cleanData = mustMerge $__cleanData (pick ($p | fromYaml) "username" "password") }}
      {{- end }}

      {{- if not (hasKey $__cleanData "username") }}
        {{- fail "service.Secret: basic-auth data.username not found" }}
      {{- end }}
      {{- if not (hasKey $__cleanData "password") }}
        {{- fail "service.Secret: basic-auth data.password not found" }}
      {{- end }}

    {{- else if eq $__type "kubernetes.io/ssh-auth" }}
      {{- $__cleanData := dict }}

      {{- $__cleanData = mustMerge $__cleanData (pick $__data "ssh-privatekey") }}
      {{- if hasKey $__dataFiles "ssh-privatekey" }}
        {{- $__cleanData = pick $__dataFiles "ssh-privatekey" }}
      {{- else }}
        {{- range $f, $p := $__dataFiles }}
          {{- $__cleanData = mustMerge $__cleanData (pick ($p | fromYaml) "ssh-privatekey") }}
        {{- end }}

        {{- if not (hasKey $__cleanData "ssh-privatekey") }}
          {{- fail "service.Secret: ssh-auth data.ssh-privatekey not found" }}
        {{- end }}
      {{- end }}

      {{- $__data = dict }}
      {{- $__dataFiles = $__cleanData }}

    {{- else if eq $__type "kubernetes.io/tls" }}
      {{- $__cleanData := dict }}

      {{- $__cleanData = mustMerge $__cleanData (pick $__data "tls.crt" "tls.key") }}

      {{- if hasKey $__dataFiles "tls.crt" }}
        {{- $__cleanData = pick $__dataFiles "tls.crt" "tls.key" }}
      {{- else }}
        {{- range $f, $p := $__dataFiles }}
          {{- $__cleanData = mustMerge $__cleanData (pick ($p | fromYaml) "tls.crt" "tls.key") }}
        {{- end }}

        {{- if not (hasKey $__cleanData "tls.crt") }}
          {{- fail "service.Secret: tls stringData.tls.crt not found" }}
        {{- end }}
        {{- if not (hasKey $__cleanData "tls.key") }}
          {{- fail "service.Secret: tls stringData.tls.key not found" }}
        {{- end }}
      {{- end }}

      {{- $__data = dict }}
      {{- $__dataFiles = $__cleanData }}

    {{- else if eq $__type "bootstrap.kubernetes.io/token" }}
      {{- $__cleanData := dict }}

      {{- $__cleanData = mustMerge $__cleanData (pick $__data "token-id" "token-secret") }}
      {{- range $f, $p := $__dataFiles }}
        {{- $__cleanData = mustMerge $__cleanData (pick ($p | fromYaml) "token-id" "token-secret") }}
      {{- end }}

      {{- if not (hasKey $__cleanData "token-id") }}
        {{- fail "service.Secret: token stringData.token-id not found" }}
      {{- end }}
      {{- if not (hasKey $__cleanData "token-secret") }}
        {{- fail "service.Secret: token stringData.token-secret not found" }}
      {{- end }}
    {{- end }}

    {{- if or $__data $__dataFiles }}
      {{- nindent 0 "" -}}data:
      {{- range $k, $v := $__data }}
        {{- $k | nindent 2 }}: {{ (toString $v) | b64enc }}
      {{- end }}
      {{- range $k, $v := $__dataFiles }}
        {{- $k | nindent 2 }}: |
          {{- $v | b64enc | nindent 4 }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- /*
    for stringData
  */ -}}
  {{- if or ._CTX.stringData .Values.stringData ._CTX.stringDataFiles .Values.stringDataFiles }}
    {{- $__stringData := dict }}
    {{- $__stringDataFiles := dict }}

    {{- if kindIs "map" ._CTX.stringData }}
      {{- $__stringData = mustMerge $__stringData ._CTX.stringData }}
    {{- end }}
    {{- if kindIs "map" .Values.stringData }}
      {{- $__stringData = mustMerge $__stringData .Values.stringData }}
    {{- end }}

    {{- if kindIs "slice" ._CTX.stringDataFiles }}
      {{- range ._CTX.stringDataFiles }}
        {{- $__stringDataFiles = mustMerge $__stringDataFiles (dict (base .) ($.Files.Get .)) }}
      {{- end }}
    {{- else if kindIs "map" ._CTX.stringDataFiles }}
      {{- range $f, $p := ._CTX.stringDataFiles }}
        {{- $__stringDataFiles = mustMerge $__stringDataFiles (dict (base $f) ($.Files.Get $p)) }}
      {{- end }}
    {{- end }}
    {{- if kindIs "slice" .Values.stringDataFiles }}
      {{- range .Values.stringDataFiles }}
        {{- $__stringDataFiles = mustMerge $__stringDataFiles (dict (base .) ($.Files.Get .)) }}
      {{- end }}
    {{- else if kindIs "map" .Values.stringDataFiles }}
      {{- range $f, $p := .Values.stringDataFiles }}
        {{- $__stringDataFiles = mustMerge $__stringDataFiles (dict (base $f) ($.Files.Get $p)) }}
      {{- end }}
    {{- end }}

    {{- if or (eq $__type "kubernetes.io/dockercfg") (eq $__type "kubernetes.io/dockerconfigjson") }}
      {{- $__docker := dict }}
      {{- $__dockerAuth := dict }}
      {{- $__cleanData := dict }}

      {{- /*
        处理 stringData stringDataFiles
        descr:
        - stringData 优先级比 stringDataFiles 更高
        - 从文件中获取配置时，会遍历所有文件，查找对应的关键字
          - 不保证顺序及准确性
          - 当只有一个文件时不会出现顺序问题
          - 如果有文件名称为 .dockercfg 或 .dockerconfigjson 会被视为可用配置而直接生效且优先级最高
        - ".dockercfg" 或 ".dockerconfigjson" 具有唯一性，其他仓库配置，需要创建新的 Secret 资源
      */ -}}
      {{- $__cleanData = mustMerge $__cleanData (pick $__stringData "server" "username" "password" "email") }}

      {{- if and (hasKey $__stringDataFiles ".dockercfg") (eq $__type "kubernetes.io/dockercfg") }}
        {{- $__docker = dict ".dockercfg" (get $__stringDataFiles ".dockercfg") }}
      {{- else if and (hasKey $__stringDataFiles ".dockerconfigjson") (eq $__type "kubernetes.io/dockerconfigjson") }}
        {{- $__docker = dict ".dockerconfigjson" (get $__stringDataFiles ".dockerconfigjson") }}
      {{- else }}
        {{- range $f, $p := $__stringDataFiles }}
          {{- $__cleanData = mustMerge $__cleanData (pick ($p | fromYaml) "server" "username" "password" "email") }}
        {{- end }}

        {{- if not (hasKey $__cleanData "server") }}
          {{- fail "service.Secret: docker stringData.server not found" }}
        {{- end }}
        {{- if not (hasKey $__cleanData "username") }}
          {{- fail "service.Secret: docker stringData.username not found" }}
        {{- end }}
        {{- if not (hasKey $__cleanData "password") }}
          {{- fail "service.Secret: docker stringData.password not found" }}
        {{- end }}
        {{- $_ := set $__cleanData "auth" ((printf "%s:%s" $__cleanData.username $__cleanData.password) | b64enc) }}
        {{- $_ := set $__dockerAuth $__cleanData.server (pick $__cleanData "username" "password" "email" "auth") }}

        {{- if eq $__type "kubernetes.io/dockercfg" }}
          {{- $__docker = dict ".dockercfg" ($__dockerAuth | mustToJson) }}
        {{- else if eq $__type "kubernetes.io/dockerconfigjson" }}
          {{- $__docker = dict ".dockerconfigjson" (dict "auths" $__dockerAuth | mustToJson) }}
        {{- end }}
      {{- end }}
      {{- $__stringData = dict }}
      {{- $__stringDataFiles = $__docker }}

    {{- else if eq $__type "kubernetes.io/basic-auth" }}
      {{- $__cleanData := dict }}

      {{- $__cleanData = mustMerge $__cleanData (pick $__stringData "username" "password") }}
      {{- range $f, $p := $__stringDataFiles }}
        {{- $__cleanData = mustMerge $__cleanData (pick ($p | fromYaml) "username" "password") }}
      {{- end }}

      {{- if not (hasKey $__cleanData "username") }}
        {{- fail "service.Secret: basic-auth stringData.username not found" }}
      {{- end }}
      {{- if not (hasKey $__cleanData "password") }}
        {{- fail "service.Secret: basic-auth stringData.password not found" }}
      {{- end }}
    {{- else if eq $__type "kubernetes.io/ssh-auth" }}
      {{- $__cleanData := dict }}

      {{- $__cleanData = mustMerge $__cleanData (pick $__stringData "ssh-privatekey") }}
      {{- if hasKey $__stringDataFiles "ssh-privatekey" }}
        {{- $__cleanData = pick $__stringDataFiles "ssh-privatekey" }}
      {{- else }}
        {{- range $f, $p := $__stringDataFiles }}
          {{- $__cleanData = mustMerge $__cleanData (pick ($p | fromYaml) "ssh-privatekey") }}
        {{- end }}

        {{- if not (hasKey $__cleanData "ssh-privatekey") }}
          {{- fail "service.Secret: ssh-auth stringData.ssh-privatekey not found" }}
        {{- end }}
      {{- end }}

      {{- $__stringData = dict }}
      {{- $__stringDataFiles = $__cleanData }}

    {{- else if eq $__type "kubernetes.io/tls" }}
      {{- $__cleanData := dict }}

      {{- $__cleanData = mustMerge $__cleanData (pick $__stringData "tls.crt" "tls.key") }}

      {{- if hasKey $__stringDataFiles "tls.crt" }}
        {{- $__cleanData = pick $__stringDataFiles "tls.crt" "tls.key" }}
      {{- else }}
        {{- range $f, $p := $__stringDataFiles }}
          {{- $__cleanData = mustMerge $__cleanData (pick ($p | fromYaml) "tls.crt" "tls.key") }}
        {{- end }}

        {{- if not (hasKey $__cleanData "tls.crt") }}
          {{- fail "service.Secret: tls stringData.tls.crt not found" }}
        {{- end }}
        {{- if not (hasKey $__cleanData "tls.key") }}
          {{- fail "service.Secret: tls stringData.tls.key not found" }}
        {{- end }}
      {{- end }}

      {{- $__stringData = dict }}
      {{- $__stringDataFiles = $__cleanData }}

    {{- else if eq $__type "bootstrap.kubernetes.io/token" }}
      {{- $__cleanData := dict }}

      {{- $__cleanData = mustMerge $__cleanData (pick $__stringData "token-id" "token-secret") }}
      {{- range $f, $p := $__stringDataFiles }}
        {{- $__cleanData = mustMerge $__cleanData (pick ($p | fromYaml) "token-id" "token-secret") }}
      {{- end }}

      {{- if not (hasKey $__cleanData "token-id") }}
        {{- fail "service.Secret: token stringData.token-id not found" }}
      {{- end }}
      {{- if not (hasKey $__cleanData "token-secret") }}
        {{- fail "service.Secret: token stringData.token-secret not found" }}
      {{- end }}
    {{- end }}

    {{- if or $__stringData $__stringDataFiles }}
      {{- nindent 0 "" -}}stringData:
      {{- range $k, $v := $__stringData }}
        {{- $k | nindent 2 }}: {{ toString $v }}
      {{- end }}
      {{- range $k, $v := $__stringDataFiles }}
        {{- $k | nindent 2 }}: |
          {{- $v | nindent 4 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}


{{- define "definitions.Secret.getTokenID" -}}
  {{- $__data := dict }}

  {{- if or ._CTX.data .Values.data ._CTX.stringData .Values.stringData ._CTX.dataFiles .Values.dataFiles ._CTX.stringDataFiles .Values.stringDataFiles }}
    {{- if kindIs "map" ._CTX.data }}
      {{- $__data = mustMerge $__data ._CTX.data }}
    {{- end }}
    {{- if kindIs "map" .Values.data }}
      {{- $__data = mustMerge $__data .Values.data }}
    {{- end }}

    {{- if kindIs "slice" ._CTX.dataFiles }}
      {{- range ._CTX.dataFiles }}
        {{- $__data = mustMerge $__data (dict (base .) ($.Files.Get .)) }}
      {{- end }}
    {{- else if kindIs "map" ._CTX.dataFiles }}
      {{- range $f, $p := ._CTX.dataFiles }}
        {{- $__data = mustMerge $__data (dict (base $f) ($.Files.Get $p)) }}
      {{- end }}
    {{- end }}
    {{- if kindIs "slice" .Values.dataFiles }}
      {{- range .Values.dataFiles }}
        {{- $__data = mustMerge $__data (dict (base .) ($.Files.Get .)) }}
      {{- end }}
    {{- else if kindIs "map" .Values.dataFiles }}
      {{- range $f, $p := .Values.dataFiles }}
        {{- $__data = mustMerge $__data (dict (base $f) ($.Files.Get $p)) }}
      {{- end }}
    {{- end }}

    {{- if kindIs "map" ._CTX.stringData }}
      {{- $__data = mustMerge $__data ._CTX.stringData }}
    {{- end }}
    {{- if kindIs "map" .Values.stringData }}
      {{- $__data = mustMerge $__data .Values.stringData }}
    {{- end }}

    {{- if kindIs "slice" ._CTX.stringDataFiles }}
      {{- range ._CTX.stringDataFiles }}
        {{- $__data = mustMerge $__data (dict (base .) ($.Files.Get .)) }}
      {{- end }}
    {{- else if kindIs "map" ._CTX.stringDataFiles }}
      {{- range $f, $p := ._CTX.stringDataFiles }}
        {{- $__data = mustMerge $__data (dict (base $f) ($.Files.Get $p)) }}
      {{- end }}
    {{- end }}
    {{- if kindIs "slice" .Values.stringDataFiles }}
      {{- range .Values.stringDataFiles }}
        {{- $__data = mustMerge $__data (dict (base .) ($.Files.Get .)) }}
      {{- end }}
    {{- else if kindIs "map" .Values.stringDataFiles }}
      {{- range $f, $p := .Values.stringDataFiles }}
        {{- $__data = mustMerge $__data (dict (base $f) ($.Files.Get $p)) }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- if not (hasKey $__data "token-id") }}
    {{- fail "definitions.ObjectMeta.Secret.TokenID: Secret[bootstrap.kubernetes.io/token] token-id not found" }}
  {{- end }}

  {{- printf "bootstrap-token-%s" (get $__data "token-id") }}
{{- end }}
