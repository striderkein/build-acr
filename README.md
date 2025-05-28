# build-acr

Azure Container Registry (ACR) でコンテナイメージをビルドするためのスクリプトです。

## 直接ダウンロード

以下のリンクをクリックすると、スクリプトを直接ダウンロードできます：

- [build-acr.ps1 をダウンロード](https://raw.githubusercontent.com/striderkein/build-acr/main/build-acr.ps1)
- [build-acr.sh をダウンロード](https://raw.githubusercontent.com/striderkein/build-acr/main/build-acr.sh)

## 使い方

### ps

setting up `.env` as below
```
REGISTRY_PREFIX=<YOUR_REGISTRY_PREFIX>
RESOURCE_GROUP_PREFIX=<YOUR_RESOURCE_GROUP_PREFIX>
RESOURCE_GROUP_SUFFIX=<YOUR_RESOURCE_GROUP_SUFFIX>
REGISTRY_HOST_SUFFIX=<REGISTRY_HOST_SUFFIX>
REPOSITORY=<REPOSITORY>
TAG=<YOUR_TAG>
WAR=<YOUR_ARTIFACT_NAME>
ENV=<YOUR_ENV>
```

```ps
.\build-acr.ps1
```

### sh

```bash
./build-acr.sh --tag myacr.azurecr.io/app:1.0.0 --war app-1.0.0.war --resource-group myResourceGroup --registry myAcrName
```

### オプション

- `-t, --tag`: イメージタグ（例：myacr.azurecr.io/app:1.0.0）
- `-w, --war`: WARファイル名（例：app-1.0.0.war）
- `-g, --resource-group`: Azureリソースグループ名
- `-r, --registry`: Azure Container Registry名
- `-h, --help`: ヘルプメッセージを表示
