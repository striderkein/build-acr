# build-acr

Azure Container Registry (ACR) でコンテナイメージをビルドするためのスクリプトです。

## 直接ダウンロード

以下のリンクをクリックすると、スクリプトを直接ダウンロードできます：

- [build-acr.sh をダウンロード](https://raw.githubusercontent.com/striderkein/build-acr/main/build-acr.sh)

## 使い方

### bash

```bash
./build-acr.sh --tag myacr.azurecr.io/app:1.0.0 --war app-1.0.0.war --resource-group myResourceGroup --registry myAcrName
```

### オプション

- `-t, --tag`: イメージタグ（例：myacr.azurecr.io/app:1.0.0）
- `-w, --war`: WARファイル名（例：app-1.0.0.war）
- `-g, --resource-group`: Azureリソースグループ名
- `-r, --registry`: Azure Container Registry名
- `-h, --help`: ヘルプメッセージを表示
