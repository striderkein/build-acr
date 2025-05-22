#!/bin/bash

# 初期化
TAG=""
WAR_FILE=""
RESOURCE_GROUP=""
REGISTRY=""

# 引数パース
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag|-t)
      TAG="$2"
      shift 2
      ;;
    --war|-w)
      WAR_FILE="$2"
      shift 2
      ;;
    --resource-group|-g)
      RESOURCE_GROUP="$2"
      shift 2
      ;;
    --registry|-r)
      REGISTRY="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -t, --tag             Image tag (e.g. myacr.azurecr.io/app:1.0.0)"
      echo "  -w, --war             WAR file name (e.g. app-1.0.0.war)"
      echo "  -g, --resource-group  Azure resource group name"
      echo "  -r, --registry        Azure Container Registry name"
      echo "  -h, --help            Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information."
      exit 1
      ;;
  esac
done

# 必須チェック
if [[ -z "$TAG" || -z "$WAR_FILE" || -z "$RESOURCE_GROUP" || -z "$REGISTRY" ]]; then
  echo "Missing required arguments."
  echo "Use --help for usage information."
  exit 1
fi

# 実行
echo "Building ACR image with:"
echo "  Tag: $TAG"
echo "  WAR File: $WAR_FILE"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Registry: $REGISTRY"

az acr build -g "$RESOURCE_GROUP" --registry "$REGISTRY" \
  -t "$TAG" \
  --build-arg "WAR_FILE_NAME=$WAR_FILE" \
  ./

