{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#container-v1-core
*/ -}}
{{- define "workloads.Container" -}}
  {{- $__containers := ._CTX.containers }}
  {{- if .__isInitContainer }}
    {{- $__containers = ._CTX.initContainers }}
  {{- end }}

  {{- range $__containers }}
    {{- with . }}
      {{- nindent 0 "" -}}- name: {{ coalesce .name (printf "%s-%s" (include "base.fullname" $) (randAlphaNum 5)) }}

      {{- if and .command .args }}
        {{- nindent 2 "" -}}command:
        {{- toYaml .command | nindent 2 }}
        {{- nindent 2 "" -}}args:
        {{- toYaml .args | nindent 2 }}
      {{- end }}

      {{- /*
        for env

        variables (priority):
        - $.Values.envFiles
        - $._CTX.envFiles
        - .envFiles
        - $.Values.env
        - $._CTX.env
        - .env
        variables (bool):
        - .envInitEnabled: initContainers 是否允许加载 $.Values.envFiles $.Values.env $._CTX.envFiles $.Values.env
        descr:
        - 变量允许出现同名，但根据 Kubernetes API 中定义的规则，后出现的会覆盖之前出现的同名变量的值
        - 所有内容会原样输出
      */ -}}
      {{- if or .env $.Values.env .envFiles $.Values.envFiles }}
        {{- $__regexEnv := "^[a-zA-Z_]+\\w*[:\\-\\|]+.*" }}
        {{- $__regexEnvSplit := "[:\\-\\|]+" }}

        {{- nindent 2 "" -}}env:
        {{- if $.Values.envFiles }}
          {{- if or (not $.__isInitContainer) .envInitEnabled }}
            {{- range $f, $p := $.Values.envFiles }}
              {{- include "base.map.getValue" (dict "m" ($.Files.Get $f | fromYaml) "k" $p) | indent 2 }}
            {{- end }}
          {{- end }}
        {{- end }}

        {{- if $._CTX.envFiles }}
          {{- if or (not $.__isInitContainer) .envInitEnabled }}
            {{- range $f, $p := $._CTX.envFiles }}
              {{- include "base.map.getValue" (dict "m" ($.Files.Get $f | fromYaml) "k" $p) | indent 2 }}
            {{- end }}
          {{- end }}
        {{- end }}

        {{- if .envFiles }}
          {{- range $f, $p := .envFiles }}
            {{- include "base.map.getValue" (dict "m" ($.Files.Get $f | fromYaml) "k" $p) | indent 2 }}
          {{- end }}
        {{- end }}

        {{- if $.Values.env }}
          {{- if or (not $.__isInitContainer) .envInitEnabled }}
            {{- toYaml $.Values.env | nindent 2 }}
          {{- end }}
        {{- end }}

        {{- if $._CTX.env }}
          {{- if or (not $.__isInitContainer) .envInitEnabled }}
            {{- toYaml $._CTX.env | nindent 2 }}
          {{- end }}
        {{- end }}

        {{- if .env }}
          {{- toYaml .env | nindent 2 }}
        {{- end }}
      {{- end }}

      {{- /*
        for envFrom

        variables (priority):
        - $.Values.envFromFiles
        - .envFromFiles
        - $.Values.envFrom
        - .envFrom
        descr:
        - 所有内容会原样输出
      */ -}}
      {{- if or .envFrom $.Values.envFrom .envFromFiles $.Values.envFromFiles }}
        {{- $__regexEnvFrom := "^[a-zA-Z_]+\\w*[:\\-\\|]+.*" }}
        {{- $__regexEnvFromSplit := "[:\\-\\|]+" }}

        {{- nindent 2 "" -}}envFrom:
        {{- if $.Values.envFromFiles }}
          {{- range $f, $p := $.Values.envFromFiles }}
            {{- include "base.map.getValue" (dict "m" ($.Files.Get $f | fromYaml) "k" $p) | indent 2 }}
          {{- end }}
        {{- end }}

        {{- if .envFromFiles }}
          {{- range $f, $p := .envFromFiles }}
            {{- include "base.map.getValue" (dict "m" ($.Files.Get $f | fromYaml) "k" $p) | indent 2 }}
          {{- end }}
        {{- end }}

        {{- if $.Values.envFrom }}
          {{- toYaml $.Values.envFrom | nindent 2 }}
        {{- end }}

        {{- if .envFrom }}
          {{- toYaml .envFrom | nindent 2 }}
        {{- end }}
      {{- end }}

      {{- /*
        for image
      */ -}}
      {{- if or .image $._CTX.image $.Values.image .imageFiles $._CTX.imageFiles $.Values.imageFiles }}
        {{- /*
          传入 workloads.Container.containers.image 的 Map, Key 为 "image" 与 "imageFiles", 值为 Slice.
          - Slice 中的值, 越靠前则优先级越低
        */ -}}
        {{- nindent 2 "" -}}image: {{ include "workloads.Container.containers.image" (dict "f" $.Files "image" (list $.Values.image $._CTX.image .image) "imageFiles" (list $.Values.imageFiles $._CTX.imageFiles .imageFiles)) | trim }}
      {{- end }}

      {{- /*
        for imagePullPolicy

        variables (priority):
        - .imagePullPolicy
        - $._CTX.imagePullPolicy
        - $.Values.imagePullPolicy
      */ -}}
      {{- $__imagePullPolicyList := list "Always" "Never" "IfNotPresent" }}
      {{- if or (mustHas .imagePullPolicy $__imagePullPolicyList) (mustHas $._CTX.imagePullPolicy $__imagePullPolicyList) (mustHas $.Values.imagePullPolicy $__imagePullPolicyList) }}
        {{- nindent 2 "" -}}imagePullPolicy: {{ coalesce .imagePullPolicy $._CTX.imagePullPolicy $.Values.imagePullPolicy "Always" }}
      {{- end }}

      {{- /*
        for lifecycle

        variables (priority):
        - .lifecycle
        - $._CTX.lifecycle
        - $.Values.lifecycle
        reference:
        - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#lifecycle-v1-core
        - https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/
        - https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks
        descr:
        - 同时出现时, 按照优先级覆盖
      */ -}}
      {{- if or .lifecycle $._CTX.lifecycle $.Values.lifecycle }}
        {{- $__lifecycle := "" }}

        {{- if $.Values.lifecycle }}
          {{- $__lifecycle = toYaml $.Values.lifecycle }}
        {{- end }}
        {{- if $._CTX.lifecycle }}
          {{- $__lifecycle = toYaml $._CTX.lifecycle }}
        {{- end }}
        {{- if .lifecycle }}
          {{- $__lifecycle = toYaml .lifecycle }}
        {{- end }}

        {{- nindent 2 "" -}}lifecycle:
        {{- $__lifecycle | nindent 4 }}
      {{- end }}

      {{- /*
        for livenessProbe

        variables (priority):
        - .livenessProbe
        - $._CTX.livenessProbe
        - $.Values.livenessProbe
        reference:
        - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#probe-v1-core
        - https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
        descr:
        - 同时出现时, 按照优先级覆盖
      */ -}}
      {{- if or .livenessProbe $._CTX.livenessProbe $.Values.livenessProbe }}
        {{- $__livenessProbe := "" }}

        {{- if $.Values.livenessProbe }}
          {{- $__livenessProbe = toYaml $.Values.livenessProbe }}
        {{- end }}
        {{- if $._CTX.livenessProbe }}
          {{- $__livenessProbe = toYaml $._CTX.livenessProbe }}
        {{- end }}
        {{- if .livenessProbe }}
          {{- $__livenessProbe = toYaml .livenessProbe }}
        {{- end }}

        {{- nindent 2 "" -}}livenessProbe:
        {{- $__livenessProbe | nindent 4 }}
      {{- end }}

      {{- /*
        for ports
      */ -}}
      {{- if .ports }}
        {{- nindent 2 "" -}}ports:
        {{- include "definitions.ContainerPort" .ports | indent 2 }}
      {{- end }}

      {{- /*
        for readinessProbe

        variables (priority):
        - .readinessProbe
        - $._CTX.readinessProbe
        - $.Values.readinessProbe
        reference:
        - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#probe-v1-core
        descr:
        - 同时出现时, 按照优先级覆盖
      */ -}}
      {{- if or .readinessProbe $._CTX.readinessProbe $.Values.readinessProbe }}
        {{- $__readinessProbe := "" }}

        {{- if $.Values.readinessProbe }}
          {{- $__readinessProbe = toYaml $.Values.readinessProbe }}
        {{- end }}
        {{- if $._CTX.readinessProbe }}
          {{- $__readinessProbe = toYaml $._CTX.readinessProbe }}
        {{- end }}
        {{- if .readinessProbe }}
          {{- $__readinessProbe = toYaml .readinessProbe }}
        {{- end }}

        {{- nindent 2 "" -}}readinessProbe:
        {{- $__readinessProbe | nindent 4 }}
      {{- end }}

      {{- /*
        for resizePolicy

        variables (priority):
        - .resizePolicy
        - $._CTX.resizePolicy
        - $.Values.resizePolicy
        descr:
        - 按序追加
      */ -}}
      {{- if or .resizePolicy $._CTX.resizePolicy $.Values.resizePolicy }}
        {{- nindent 2 "" -}}resizePolicy:
        {{- range .resizePolicy }}
          {{- include "definitions.ContainerResizePolicy" . | indent 2 }}
        {{- end }}
        {{- range $._CTX.resizePolicy }}
          {{- include "definitions.ContainerResizePolicy" . | indent 2 }}
        {{- end }}
        {{- range $.Values.resizePolicy }}
          {{- include "definitions.ContainerResizePolicy" . | indent 2 }}
        {{- end }}
      {{- end }}

      {{- /*
        for resources
        variables (priority):
        - .resources
        - .resourcesFiles
        descr:
        - .resources 和 .resourcesFiles 互斥
      */ -}}
      {{- if or .resources .resourcesFiles }}
        {{- nindent 2 "" -}}resources:
        {{- if .resources }}
          {{- toYaml .resources | nindent 4 }}
        {{- else if .resourcesFiles }}
          {{- range $f, $v := .resourcesFiles }}
            {{- include "base.map.getValue" (dict "m" ($.Files.Get $f | fromYaml) "k" $v) | indent 4 }}
          {{- end }}
        {{- end }}
      {{- end }}

      {{- /*
        for securityContext
        reference:
        - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#securitycontext-v1-core
      */ -}}
      {{- if .securityContext }}
        {{- nindent 2 "" -}}securityContext:
        {{- include "definitions.SecurityContext" .securityContext | indent 4 }}
      {{- end }}

      {{- /*
        for startupProbe

        variables (priority):
        - .startupProbe
        - $._CTX.startupProbe
        - $.Values.startupProbe
        reference:
        - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#probe-v1-core
        descr:
        - 同时出现时, 按照优先级覆盖
      */ -}}
      {{- if or .startupProbe $._CTX.startupProbe $.Values.startupProbe }}
        {{- $__startupProbe := "" }}

        {{- if $.Values.startupProbe }}
          {{- $__startupProbe = toYaml $.Values.startupProbe }}
        {{- end }}
        {{- if $._CTX.startupProbe }}
          {{- $__startupProbe = toYaml $._CTX.startupProbe }}
        {{- end }}
        {{- if .startupProbe }}
          {{- $__startupProbe = toYaml .startupProbe }}
        {{- end }}

        {{- nindent 2 "" -}}startupProbe:
        {{- $__startupProbe | nindent 4 }}
      {{- end }}

      {{- /*
        for stdin
      */ -}}
      {{- if or (and .stdin (kindIs "bool" .stdin)) (and $._CTX.stdin (kindIs "bool" $._CTX.stdin)) (and $.Values.stdin (kindIs "bool" $.Values.stdin)) }}
        {{- nindent 2 "" -}}stdin: true
      {{- end }}

      {{- /*
        for stdinOnce
      */ -}}
      {{- if or (and .stdinOnce (kindIs "bool" .stdinOnce)) (and $._CTX.stdinOnce (kindIs "bool" $._CTX.stdinOnce)) (and $.Values.stdinOnce (kindIs "bool" $.Values.stdinOnce)) }}
        {{- nindent 2 "" -}}stdinOnce: true
      {{- end }}

      {{- /*
        for terminationMessagePath
      */ -}}
      {{- if or .terminationMessagePath $._CTX.terminationMessagePath $.Values.terminationMessagePath }}
        {{- nindent 2 "" -}}terminationMessagePath: {{ coalesce .terminationMessagePath $._CTX.terminationMessagePath $.Values.terminationMessagePath }}
      {{- end }}

      {{- /*
        for terminationMessagePolicy
      */ -}}
      {{- if or .terminationMessagePolicy $._CTX.terminationMessagePolicy $.Values.terminationMessagePolicy }}
        {{- nindent 2 "" -}}terminationMessagePolicy: {{ coalesce .terminationMessagePolicy $._CTX.terminationMessagePolicy $.Values.terminationMessagePolicy }}
      {{- end }}

      {{- /*
        for tty
      */ -}}
      {{- if or (and .tty (kindIs "bool" .tty)) (and $._CTX.tty (kindIs "bool" $._CTX.tty)) (and $.Values.tty (kindIs "bool" $.Values.tty)) }}
        {{- nindent 2 "" -}}tty: true
      {{- end }}

      {{- /*
        for volumeDevices
        variables (priority):
        - .volumeDevices
        - $._CTX.volumeDevices
        - $.Values.volumeDevices
      */ -}}
      {{- if or .volumeDevices $._CTX.volumeDevices $.Values.volumeDevices }}
        {{- $__volumeDevicesList := list }}

        {{- nindent 2 "" -}}volumeDevices:
        {{- range .volumeDevices }}
          {{- $__volumeDevicesList = mustAppend $__volumeDevicesList (include "definitions.VolumeDevices" . | fromYaml) }}
        {{- end }}
        {{- range $._CTX.volumeDevices }}
          {{- $__volumeDevicesList = mustAppend $__volumeDevicesList (include "definitions.VolumeDevices" . | fromYaml) }}
        {{- end }}
        {{- range $.Values.volumeDevices }}
          {{- $__volumeDevicesList = mustAppend $__volumeDevicesList (include "definitions.VolumeDevices" . | fromYaml) }}
        {{- end }}

        {{- toYaml $__volumeDevicesList | nindent 2 }}
      {{- end }}

      {{- /*
        for volumeMounts
      */ -}}
      {{- if or .volumeMounts $._CTX.volumeMounts $.Values.volumeMounts }}
        {{- $__volumeMountsList := list }}

        {{- nindent 2 "" -}}volumeMounts:
        {{- range .volumeMounts }}
          {{- $__volumeMountsList = mustAppend $__volumeMountsList (include "definitions.VolumeMount" . | fromYaml) }}
        {{- end }}
        {{- range $._CTX.volumeMounts }}
          {{- $__volumeMountsList = mustAppend $__volumeMountsList (include "definitions.VolumeMount" . | fromYaml) }}
        {{- end }}
        {{- range $.Values.volumeMounts }}
          {{- $__volumeMountsList = mustAppend $__volumeMountsList (include "definitions.VolumeMount" . | fromYaml) }}
        {{- end }}

        {{- toYaml $__volumeMountsList | nindent 2 }}
      {{- end }}

      {{- /*
        for workingDir
      */ -}}
      {{- if or .workingDir $._CTX.workingDir $.Values.workingDir }}
        {{- nindent 2 "" -}}workingDir: {{ coalesce .workingDir $._CTX.workingDir $.Values.workingDir "/" }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  variables (priority): 逻辑处理时会进行反序处理, 以适配优先级
  - .image
  - $._CTX.image
  - $.Values.image
  - .imageFiles
  - $._CTX.imageFiles
  - $.Values.imageFiles
  variables (image):
  - repository:
    - url: 域名 + 端口号
    - namespace: 存放路径
    - name: 名称
  - tag (以下变量可以替换 tag): 默认值 latest
    - project: 工程代码 / 工程分支代码
    - buildId: Jenkins 出档编号
    - commit: 提交 ID
    - data_commit: 数据档提交 ID
  descr:
  - 当 image 为 string 时, 被视为完整的镜像名称
  - 当 image 为 map 时, 会根据不同的变量名进行拼接
    - repository 和 tag 使用 ":" 号拼接为完整的镜像名称
      - 当 repository 为 map 时, 使用 url、namespace、name 拼接镜像名称
      - 当 repository 为 slice 时, 会将列表中的所有元素依次拼接为镜像名称
      - repository 使用斜杠 "/" 进行拼接
      - 当 tag 为 map 时, 使用 project、commit、data_commit 拼接 tag 名称
      - 当 tag 为 slice 时, 会将列表中的所有元素依次拼接为 tag 名称
      - tag 使用连字符 "-" 进行拼接
  - 相同变量的数据类型不可混用
*/ -}}
{{- define "workloads.Container.containers.image" -}}
  {{- $__image := dict }}
  {{- $__imagetList := list }}

  {{- /*
    设置 $__image.image $__imagetList
  */ -}}
  {{- range .imageFiles }}
    {{- range $p, $k := . }}
      {{- $__imageVal := include "base.map.getValue" (dict "m" ($.f.Get $p | fromYaml) "k" $k) | fromYaml }}
      {{- /*
        报错时, 视为 string, 此时不使用 fromYaml 函数转换
      */ -}}
      {{- if hasKey $__imageVal "Error" }}
        {{- $__imageVal = include "base.map.getValue" (dict "m" ($.f.Get $p | fromYaml) "k" $k) | trim }}
      {{- end }}
      {{- $__imagetList = mustAppend $__imagetList $__imageVal }}
    {{- end }}
  {{- end }}

  {{- $__imagetList = concat $__imagetList .image }}

  {{- /*
    解析 $__imagetList
  */ -}}
  {{- range $__imagetList }}
    {{- if . }}
      {{- if not $__image.image }}
        {{- $_ := set $__image "image" . }}
      {{- else }}
        {{- if not (eq (kindOf .) (kindOf $__image.image)) }}
          {{- $_ := set $__image "image" . }}
        {{- end }}
        {{- if kindIs "map" . }}
          {{- if not $__image.image.repository }}
            {{- $_ := set $__image.image "repository" .repository }}
          {{- else }}
            {{- if kindIs "map" .repository }}
              {{- range $k, $v := .repository }}
                {{- $_ := set $__image.image.repository $k $v }}
              {{- end }}
            {{- else if kindIs "slice" .repository }}
              {{- $_ := set $__image.image "repository" (concat $__image.image.repository .repository) }}
            {{- else if kindIs "string" .repository }}
              {{- $_ := set $__image.image "repository" .repository }}
            {{- else if or (kindIs "int" .repository) (kindIs "float64" .repository) }}
              {{- $_ := set $__image.image "repository" (int .repository | toString) }}
            {{- end }}
          {{- end }}

          {{- if not $__image.image.tag }}
            {{- $_ := set $__image.image "tag" .tag }}
          {{- else }}
            {{- if kindIs "map" .tag }}
              {{- range $k, $v := .tag }}
                {{- $_ := set $__image.image.tag $k $v }}
              {{- end }}
            {{- else if kindIs "slice" .tag }}
              {{- $_ := set $__image.image "tag" (concat .tag $__image.image.tag) }}
            {{- else if kindIs "string" .tag }}
              {{- $_ := set $__image.image "tag" .tag }}
            {{- else if or (kindIs "int" .tag) (kindIs "float64" .tag) }}
              {{- $_ := set $__image.image "tag" (int .tag | toString) }}
            {{- end }}
          {{- end }}
        {{- else }}
          {{- $_ := set $__image "image" . }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- /*
    解析 $__image.image
  */ -}}
  {{- if kindIs "string" $__image.image }}
    {{- $__image.image | trim }}
  {{- else if kindIs "map" $__image.image }}
    {{- $__repository := "" }}
    {{- $__tag := "latest" }}

    {{- with $__image.image }}
      {{- /*
        - .repository 移除 url namespace name 后, 如果还有其他值, 则使用 values 函数生成的列表中的值作为 namespace 的补充拼接到 namespace 和 name 之间
        - .tag 移除 project buildId commit dataCommit 后, 如果还有其他值, 则使用 values 函数生成的列表中的值作为后缀拼接到 tag 上
        - values 函数取出的列表, 使用 sortAlpha 进行排序
      */ -}}
      {{- $__repository = include "workloads.Container.containers.image.parser" (dict "m" .repository "k" (list "url" "namespace" "name") "default" "" "separators" "/" "keyToLast" false) | trim }}
      {{- $__tag = include "workloads.Container.containers.image.parser" (dict "m" .tag "k" (list "buildId" "project" "commit" "dataCommit") "default" "latest" "separators" "-" "keyToLast" true) | trim }}
    {{- end }}

    {{- if and $__repository $__tag }}
      {{- printf "%s:%s" $__repository $__tag }}
    {{- else }}
      {{- fail "image.repository not found" }}
    {{- end }}
  {{- else }}
    {{- fail "image not support" }}
  {{- end }}
{{- end }}


{{- /*
  .m: map 需要解析的数据
  .k: slice 需要从数据中单独取值并移除的 key (按照传入列表的顺序依次取值). 当 .m 为 Map 时有效
  .default: string 默认值, 默认为空字符串
  .separators: string 分隔符, 默主为连字符 "-"
  .keyToLast: bool 是否将按 .k 列表取的值放到 $__fields 列表的最后 (为 false 时会将值插入到列表的倒数第 2 个位置), 当 .m 为 Map 时有效. 默认 false
*/ -}}
{{- define "workloads.Container.containers.image.parser" -}}
  {{- if not .default }}
    {{- $_ := set . "default" "" }}
  {{- end }}
  {{- if not .separators }}
    {{- $_ := set . "separators" "-" }}
  {{- end }}

  {{- if kindIs "map" .m }}
    {{- $__fields := list }}

    {{- range .k }}
      {{- if get $.m . }}
        {{- $__fields = mustAppend $__fields (get $.m .) }}
      {{- end }}
      {{- $_ := unset $.m . }}
    {{- end }}

    {{- /*
      - .repository 移除 url namespace name 后, 如果还有其他值, 则使用 values 函数生成的列表中的值作为 namespace 的补充拼接到 namespace 和 name 之间
      - .tag 移除 project buildId commit dataCommit 后, 如果还有其他值, 则使用 values 函数生成的列表中的值作为后缀拼接到 tag 上
      - values 函数取出的列表, 使用 sortAlpha 进行排序
    */ -}}
    {{- if .m }}
      {{- if kindIs "bool" .keyToLast }}
        {{- if .keyToLast }}
          {{- $__fields = concat $__fields (values .m | sortAlpha) }}
        {{- else }}
          {{- $__fields = mustAppend (concat (mustInitial $__fields) (values .m | sortAlpha)) (mustLast $__fields) }}
        {{- end }}
      {{- else }}
        {{- fail ".suffix must be true or false" }}
      {{- end }}
    {{- end }}
    {{- join .separators $__fields | nindent 0 }}

  {{- else if kindIs "slice" .m }}
    {{- join .separators .m | nindent 0 }}
  {{- else if kindIs "string" .m }}
    {{- .m | nindent 0 }}
  {{- else if or (kindIs "int" .m) (kindIs "float64" .m) }}
    {{- int .m | toString | nindent 0 }}
  {{- else }}
    {{- .default | nindent 0 }}
  {{- end }}
{{- end }}
