# build-acr

Azure Container Registry (ACR) でコンテナイメージをビルドするためのスクリプトです。

## 直接ダウンロード

以下のリンクをクリックすると、スクリプトを直接ダウンロードできます：

- [build-acr.ps1 をダウンロード](https://raw.githubusercontent.com/striderkein/build-acr/main/build-acr.ps1)
- [build-acr.sh をダウンロード](https://raw.githubusercontent.com/striderkein/build-acr/main/build-acr.sh)

## 使い方

### ps

**1. .env.example をコピーする**
```ps
cp .env.examle .env
```

**2. `.env` を設定する**

```ps
REGISTRY_PREFIX=<YOUR_REGISTRY_PREFIX>
RESOURCE_GROUP_PREFIX=<YOUR_RESOURCE_GROUP_PREFIX>
RESOURCE_GROUP_SUFFIX=<YOUR_RESOURCE_GROUP_SUFFIX>
REGISTRY_HOST_SUFFIX=<REGISTRY_HOST_SUFFIX>
REPOSITORY=<REPOSITORY>
TAG=<YOUR_TAG>
ENV=<YOUR_ENV>
```

**3. Dockerfile, init.sh を配置する**
`build-acr.ps1` と同じディレクトリに下記を配置する
- Dockerfile
- init.sh

**4. 実行**

```ps
.\build-acr.ps1
```

「スクリプトの実行が無効になっているため…」というエラーが出るときは下記コマンドを実行してから再実行する必要あり。
```ps
＞ Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
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
