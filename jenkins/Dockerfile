FROM jenkins/jenkins:lts

# 切换到 root 用户以安装软件
USER root

# 1. 安装 Docker CLI (客户端)
# 使用官方脚本安装，它会自动检测架构 (无论是 M1/M2/M3 芯片还是 Intel 都能用)
RUN curl -fsSL https://get.docker.com | sh

# 2. (可选) 将 jenkins 用户加入 docker 组
# OrbStack 的权限处理比较宽松，通常不需要这一步，但为了保险建议加上
# RUN groupadd -f docker && usermod -aG docker jenkins

# 切换回 root 运行 (在 OrbStack/Docker Desktop 环境下，用 root 运行容器能避免绝大多数 socket 权限问题)
# 如果你非常介意安全性，可以切换回 USER jenkins，但可能需要手动处理 socket 的 GID 问题
USER root