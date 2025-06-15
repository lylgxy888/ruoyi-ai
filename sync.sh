#!/bin/bash
set -eux

TARGET_REGISTRY=registry.cn-hangzhou.aliyuncs.com
TARGET_NAMESPACE=lyonglu
IMAGES="mysql:8.0.33 redis:6.2 semitechnologies/weaviate:1.30.0 ruoyi-ai-backend:v2.0.5 ruoyi-ai-admin:v2.0.5 ruoyi-ai-web:v2.0.5"

for image in ${IMAGES};do
    # 拉取镜像
    docker pull $image
    
    # 处理镜像名称和标签
    if [[ $image == *"/"* ]]; then
        # 处理带有命名空间的镜像，如 semitechnologies/weaviate:1.30.0
        namespace=$(echo ${image} | cut -d '/' -f1)
        remainder=$(echo ${image} | cut -d '/' -f2-)
        name=$(echo ${remainder} | cut -d ':' -f1)
        tag=$(echo ${remainder} | cut -d ':' -f2)
        targetFullName=${TARGET_REGISTRY}/${TARGET_NAMESPACE}/${namespace}-${name}:${tag}
    else
        # 处理不带命名空间的镜像，如 mysql:8.0.33
        name=$(echo ${image} | cut -d ':' -f1)
        tag=$(echo ${image} | cut -d ':' -f2)
        targetFullName=${TARGET_REGISTRY}/${TARGET_NAMESPACE}/${name}:${tag}
    fi
    
    # 打阿里云的tag
    docker tag ${image} ${targetFullName}
    
    # 推送到阿里云
    docker push ${targetFullName}
    
    echo "成功同步镜像: ${image} -> ${targetFullName}"
done
