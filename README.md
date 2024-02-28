# Library Charts (v2)

HELM 库 Chart（第二版）。基于 [Kubernetes API v1.28](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/) 实现，具有良好的可拓展性、通用性，使 Kubernetes YAML 管理更简单、方便。

使用文档，请参考：[How to use HELM library-charts-v2](http://gitea.ycx.com/kazama/docs/Helm/LibraryCharts/README.md)

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

## 添加库 Chart

- 同步仓库到本地
- 进入需要制作 YAML 文件的 Chart（目录）
- 执行 `helm dependency update` 同步依赖包
  - 查看 `Chart.yaml` 中的 `dependencies` 进行确认

    ```bash
    dependencies:
    - name: library-charts
      version: v1.28.0
      repository: https://helm-repository.example.com/
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
