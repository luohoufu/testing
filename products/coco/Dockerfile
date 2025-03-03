FROM infinilabs/baseos:24 AS builder

ARG TARGETARCH

# 切换到工作目录
WORKDIR /app/easysearch

# Coco 与 配置项
ADD entrypoint.sh /sbin

# 安装 Coco
ADD --chown=ezs:ezs coco-$TARGETARCH /app/coco
RUN cd /app/coco && ln -s coco-* coco

# 安装 Easysearch
ADD --chown=ezs:ezs easysearch-$TARGETARCH /app/easysearch
RUN cd /app/easysearch && ln -s /usr/local/jdk .

# 最终阶段
FROM scratch AS prod

LABEL description="INFINI Easysearch, derived from Elasticsearch 7.10 and OpenSearch 2.4."
LABEL maintainer="Medcl、Hardy@INFINILabs <luohf@infinilabs.com>"

# 从构建阶段拷贝文件到最终镜像，权限会丢失
COPY --from=builder / /

# 环境变量
ENV PATH=/sbin:/app/easysearch/jdk/bin:/app/easysearch/bin:$PATH

# 切换到工作目录
WORKDIR /app/easysearch

# 权限处理
RUN chown -R ezs:ezs /app/easysearch

EXPOSE 9200 9300

ENTRYPOINT ["/sbin/tini", "--", "/sbin/entrypoint.sh"]
CMD ["easysearch"]