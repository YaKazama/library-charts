# Library Charts (v2)

HELM 库 Chart（第二版）。基于 [Kubernetes API v1.28](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/) 实现，具有良好的可拓展性、通用性，使 Kubernetes YAML 管理更简单、方便。

使用文档，请参考：[How to use HELM library-charts-v2](http://gitea.ycx.com/kazama/docs/Helm/LibraryCharts/README.md)

请注意：

- 并没有实现所有的资源及字段，只实现了一部分常用的。有需要时再进行增改。参考：[已实现的资源模板](#已实现的资源模板)
- `templates/base` 目录下存放的应该是一些通用的、可复用的模板内容。
- 因为某些原因，缺少文档，具体使用请查看 `examples` 目录下的示例。

## 添加库 Chart

- 同步仓库到本地
- 进入需要制作 YAML 文件的 Chart（目录）
- 执行 `helm dependency update` 同步依赖包
  - 查看 `Chart.yaml` 中的 `dependencies` 进行确认

    ```bash
    dependencies:
    - name: library-charts
      version: v1.28.0
      repository: https://helm.12321.asia/
    ```

  - 若遇到以下报错，可忽略。

    ```txt
    Could not verify charts/.gitkeep for deletion: file 'charts/.gitkeep' does not appear to be a gzipped archive; got 'application/octet-stream' (Skipping)
    ```

示例：

```bash
git clone https://git.example.com/helm-charts/example.git
cd path/to/example
helm dependency update
```

## 发布

- 进入目录并检查目录结构
- 打包 `tgz` 文件
  - 检查 `Chart.yaml` 中的 `version`
- 制作 `index.yaml` 文件
  - 注意 **合并** 文件操作
- 上传打包后的 `tgz` 文件及 `index.yaml`
- 清理本地文件

示例：

```bash
cd path/to/example
export VERSION="0.1.0"

helm package .
helm repo index . --url https://helm-repository.example.com
curl -XPUT https://helm-repository.example.com/upload/<example>-${VERSION}.tgz --data-binary @<example>-${VERSION}.tgz
curl -XPUT https://helm-repository.example.com/upload/index.yaml --data-binary @index.yaml
rm -rf <example>-${VERSION}.tgz index.yaml
```

## 已实现的资源模板

- crds
  - crds.gcp.BackendConfig.BackendConfigSpec
  - crds.gcp.BackendConfig.HealthCheck
  - crds.gcp.BackendConfig.ConnectionDraining
  - crds.gcp.BackendConfig.Logging
  - crds.gcp.ManagedCertificate.ManagedCertificateSpec
  - crds.gcp.BackendConfig
  - crds.gcp.ManagedCertificate
  - crds.tencent.TkeServiceConfig
  - crds.tencent.TkeServiceConfig.TkeServiceConfigSpec
  - crds.tencent.TkeServiceConfig.Domain
  - crds.tencent.TkeServiceConfig.Session
  - crds.tencent.TkeServiceConfig.LoadBalancer
  - crds.tencent.TkeServiceConfig.HealthCheck
  - crds.tencent.TkeServiceConfig.Listeners.L4
  - crds.tencent.TkeServiceConfig.Listeners.L7
  - crds.tencent.TkeServiceConfig.Rules

- base
  - base.annotations
  - base.map.getVal
  - base.toa
  - base.map
  - base.map.merge.single
  - base.map.merge
  - base.bool
  - base.bool.false
  - base.int
  - base.int.zero
  - base.int.scope
  - base.float
  - base.float.zero
  - base.float.scope
  - base.string
  - base.string.empty
  - base.octal
  - base.nil
  - base.slice
  - base.fmt
  - base.fmt.slice
  - base.apiVersion
  - base.kind
  - base.name
  - base.fullname
  - base.namespace
  - base.chart
  - base.labels

- workloads
  - workloads.Job
  - workloads.StatefulSet
  - workloads.StatefulSetSpec
  - workloads.DeploymentSpec
  - workloads.RollingUpdateDaemonSet
  - workloads.PodSpec
  - workloads.Container
  - workloads.Container.env
  - workloads.Container.envFrom
  - workloads.Container.image
  - workloads.Container.image.parser
  - workloads.Pod
  - workloads.CronJobSpec
  - workloads.RollingUpdateDeployment
  - workloads.JobSpec
  - workloads.DaemonSet
  - workloads.ReplicaSet
  - workloads.CronJob
  - workloads.DaemonSetSpec
  - workloads.DeploymentStrategy
  - workloads.ReplicationController
  - workloads.ReplicaSetSpec
  - workloads.Deployment
  - workloads.ReplicationControllerSpec

- service
  - service.IngressClassSpec
  - service.ServiceSpec
  - service.Service
  - service.IngressClass
  - service.Ingress
  - service.IngressSpec

- config & storage
  - configStorage.Volume
  - configStorage.Volume.VolumeSource
  - configStorage.PersistentVolumeClaimSpec
  - configStorage.PersistentVolumeClaimSpec.old
  - configStorage.PersistentVolumeClaim
  - configStorage.PersistentVolumeClaim.StatefulSet
  - configStorage.ConfigMap
  - configStorage.ConfigMap.data.parser
  - configStorage.Secret
  - configStorage.Secret.data.parser
  - configStorage.Secret.getTokenID
  - configStorage.StorageClass

- metadata
  - metadata.PodTemplate
  - metadata.PodTemplateSpec

- cluster
  - cluster.PersistentVolume
  - cluster.Role
  - cluster.ClusterRole
  - cluster.ClusterRoleBinding
  - cluster.RoleBinding
  - cluster.PersistentVolumeSpec
  - cluster.Namespace
  - cluster.NetworkPolicy
  - cluster.NetworkPolicySpec
  - cluster.ServiceAccount
  - cluster.Binding

- definitions
  - definitions.LabelSelectorRequirement
  - definitions.DaemonSetUpdateStrategy
  - definitions.SecretEnvSource
  - definitions.EnvVar
  - definitions.VolumeDevice
  - definitions.ObjectMeta
  - definitions.HTTPIngressRuleValue
  - definitions.IngressServiceBackend
  - definitions.SecretReference
  - definitions.TypedLocalObjectReference
  - definitions.AggregationRule
  - definitions.LabelSelector
  - definitions.LocalObjectReference
  - definitions.Sysctl
  - definitions.SELinuxOptions
  - definitions.Toleration
  - definitions.TCPSocketAction
  - definitions.VolumeNodeAffinity
  - definitions.HostPathVolumeSource
  - definitions.HTTPHeader
  - definitions.HTTPIngressPath
  - definitions.FCVolumeSource
  - definitions.EnvFromSource
  - definitions.SessionAffinityConfig
  - definitions.Probe
  - definitions.IngressClassParametersReference
  - definitions.RBDVolumeSource
  - definitions.NodeAffinity
  - definitions.NetworkPolicyEgressRule
  - definitions.NetworkPolicyIngressRule
  - definitions.NetworkPolicyPeer
  - definitions.NetworkPolicyPort
  - definitions.TopologySelectorTerm
  - definitions.ConfigMapEnvSource
  - definitions.PersistentVolumeClaimVolumeSource
  - definitions.IngressBackend
  - definitions.IPBlock
  - definitions.Quantity
  - definitions.HostAlias
  - definitions.SecurityContext
  - definitions.NodeSelector
  - definitions.VolumeMount
  - definitions.ServicePort
  - definitions.ServiceBackendPort
  - definitions.Affinity
  - definitions.CephFSVolumeSource
  - definitions.SecretVolumeSource
  - definitions.StatefulSetUpdateStrategy
  - definitions.PodSecurityContext
  - definitions.WindowsSecurityContextOptions
  - definitions.ResourceClaim
  - definitions.PolicyRule
  - definitions.ContainerPort
  - definitions.SecretKeySelector
  - definitions.Capabilities
  - definitions.IngressRule
  - definitions.WeightedPodAffinityTerm
  - definitions.StatefulSetOrdinals
  - definitions.LifecycleHandler
  - definitions.TopologySelectorLabelRequirement
  - definitions.NodeSelectorTerm
  - definitions.ObjectReference
  - definitions.RBDPersistentVolumeSource
  - definitions.RollingUpdateStatefulSetStrategy
  - definitions.ResourceRequirements
  - definitions.ResourceFieldSelector
  - definitions.ExecAction
  - definitions.SeccompProfile
  - definitions.ConfigMapVolumeSource
  - definitions.JobTemplateSpec
  - definitions.Lifecycle
  - definitions.EnvVarSource
  - definitions.KeyToPath
  - definitions.PodAntiAffinity
  - definitions.PodAntiAffinity1
  - definitions.PodAffinity
  - definitions.CephFSPersistentVolumeSource
  - definitions.NodeSelectorRequirement
  - definitions.EmptyDirVolumeSource
  - definitions.ContainerResizePolicy
  - definitions.PreferredSchedulingTerm
  - definitions.NFSVolumeSource
  - definitions.HTTPGetAction
  - definitions.ObjectFieldSelector
  - definitions.ConfigMapKeySelector
  - definitions.ClientIPConfig
  - definitions.PodAffinityTerm
  - definitions.RoleRef
  - definitions.TypedObjectReference
  - definitions.IngressTLS
  - definitions.GRPCAction

- others（old api versions）
  - others.Subject.v1

## 重大改动

- `values.yaml` 尽量遵循 [最佳实践](https://helm.sh/zh/docs/chart_best_practices/values/)
  - 移除 `values.yaml` 中 `.Values.global` 支持
    - `.Values.global` 在一定程度上与 `.Values.X` 冲突且使用较少
  - 对于不同类型的资源，建议使用 Map 进行分组放置
- 内置变量调整
  - 移除 `._objectMetaAnnotationsType`
  - `._kind`
  - `._Pod` 变更为 `.Context`

    > `values.yaml` 映射原则：
    > - 在使用 `.Values` 的值时，建议统一映射到 `.Context` 变量中
    > - 模板内自定义变量，建议统一使用 `$__<ENV>` 格式且使用驼峰样式
    > - `$.Values` 等变量引用视具体情况而定
    > - 适用于 HELM 相关的变量，统一添加 `helm` 前缀，如：`helmLabels`

- `templates/examples` 示例重构
- 云平台 CRDs 有限支持
  - gcp
  - tencent cloud
- 文档补充
  - 使用手册
  - 代码注释
