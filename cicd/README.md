# 🚀 本地云原生 CI/CD 实战指南 (Self-Hosted Runner 版)

**适用环境**：macOS (Apple Silicon), OrbStack, GitHub Actions
**核心目标**：利用本地高性能 Mac 作为构建服务器，实现代码提交后自动构建 Docker 镜像并部署到本地 Kubernetes 集群。

---

## 🛠️ 第一阶段：基础设施准备

### 1. 启动本地镜像仓库 (Registry)
我们需要一个本地的 Docker Hub 来存储镜像，并配置 Web UI 方便管理。

创建 `docker-compose.yml`：
```yaml
version: '3'
services:
  registry:
    image: registry:2
    container_name: registry
    ports:
      - "5000:5000"
    restart: always
    environment:
      - REGISTRY_STORAGE_DELETE_ENABLED=true
    volumes:
      - ./registry-data:/var/lib/registry

  ui:
    image: joxit/docker-registry-ui:main
    container_name: registry-ui
    ports:
      - "8080:80"
    environment:
      - REGISTRY_TITLE=Local Registry
      - REGISTRY_URL=http://registry:5000
      - DELETE_IMAGES=true
```

启动服务：
```bash
docker-compose up -d
```
> **访问地址**：
> *   Registry API: `http://localhost:5000`
> *   管理界面: `http://localhost:8080`

### 2. 缓存基础镜像 (解决网络问题)
为了避免构建时拉取 Docker Hub 超时，我们手动下载基础镜像并推送到本地 Registry。

```bash
# 1. 拉取官方镜像 (需确保网络通畅或配置了 OrbStack 镜像加速)
docker pull node:18-alpine
docker pull nginx:stable-alpine

# 2. 重新打标签指向本地 Registry
docker tag node:18-alpine localhost:5000/base/node:18
docker tag nginx:stable-alpine localhost:5000/base/nginx:stable

# 3. 推送入库
docker push localhost:5000/base/node:18
docker push localhost:5000/base/nginx:stable
```

---

## 💻 第二阶段：配置 GitHub Runner

### 1. 注册 Runner
1.  进入 GitHub 仓库 -> **Settings** -> **Actions** -> **Runners** -> **New self-hosted runner**。
2.  选择 **macOS**，按页面提示下载并解压 Runner 程序。
3.  执行配置命令：
    ```bash
    ./config.sh --url https://github.com/你的用户名/你的仓库 --token XXXXXX
    ```
    *(一路回车默认即可)*

### 2. 启动 Runner
```bash
./run.sh
```
*(保持终端窗口开启，或者使用 `./svc.sh install` 安装为后台服务)*

### ⚠️ 关键配置：解决路径与权限问题
为了防止 Runner 找不到 `docker` 或 `kubectl` 命令，请检查 Runner 目录下的 `.path` 文件：

1.  编辑 `.path` 文件：
    ```bash
    vim .path
    ```
2.  确保文件末尾包含 OrbStack 和 Homebrew 的路径：
    ```text
    /usr/local/bin
    /opt/orbstack/bin
    ```
3.  重启 Runner 生效。

---

## 📂 第三阶段：项目配置

在你的 Vue 项目根目录添加以下文件。

### 1. `Dockerfile` (使用本地缓存)
```dockerfile
# 使用本地 Registry 的基础镜像，构建速度飞快
FROM localhost:5000/base/node:18 AS build-stage
WORKDIR /app
COPY package*.json ./
# 如果 npm install 慢，可配置 npm 镜像源
RUN npm install --registry=https://registry.npmmirror.com
COPY . .
RUN npm run build

FROM localhost:5000/base/nginx:stable AS production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 2. `k8s-deploy.yaml` (K8s 部署清单)
---

## 🔄 第四阶段：CI/CD 流水线

创建 `.github/workflows/deploy.yml`：


---

## ✅ 第五阶段：验证与排查

1.  **提交代码**：`git push origin main`。
2.  **观察日志**：
    *   **GitHub Actions 页面**：查看流程是否全绿。
    *   **本地 Runner 终端**：查看实时执行日志。
3.  **访问应用**：打开浏览器访问 `http://localhost:8888`。

### 常见问题排查 (Troubleshooting)

| 现象 | 可能原因 | 解决方案 |
| :--- | :--- | :--- |
| **Step `docker push` 失败** | Registry 容器挂了 | 检查 `docker ps`，确保 registry 在运行。 |
| **`failed to resolve source metadata`** | 基础镜像不存在 | 检查 `Dockerfile` 里的 `FROM` 路径是否正确，Registry UI 里是否有该镜像。 |
| **`npm install` 超时** | 网络不通 | 配置 OrbStack 使用系统代理，或在 Dockerfile 使用 npm 淘宝源。 |
| **K8s `ImagePullBackOff`** | K8s 拉不到镜像 | 确保 `deployment.yaml` 里的 image 地址是 `localhost:5000/...`。 |
| **`kubectl: command not found`** | Runner 环境变量缺失 | 修改 Runner 目录下的 `.path` 文件，添加 `/opt/orbstack/bin`。 |

---

**🎉 恭喜！你现在拥有了一套完全私有化、高性能且免费的 CI/CD 流水线。**