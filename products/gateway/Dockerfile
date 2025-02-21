FROM alpine AS builder

ARG TARGETARCH

# 指定工作目录
WORKDIR /

# 复制文件
COPY ["gateway-linux-${TARGETARCH}", "gateway.yml", "LICENSE", "NOTICE", "/"]

# 建立软链接
RUN ln -s gateway-* gateway

# 最终阶段
FROM scratch AS prod

LABEL description="A light-weight, powerful and high-performance search gateway."
LABEL maintainer="Medcl、Hardy@INFINILabs <luohf@infinilabs.com>" architecture="amd64/arm64"

# 从构建阶段拷贝文件到最终镜像
COPY --from=builder / /

# 设置工作目录
WORKDIR /

CMD ["/gateway"]