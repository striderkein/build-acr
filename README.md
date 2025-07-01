# build-acr

Azure Container Registry (ACR) でコンテナイメージをビルドするためのスクリプトです。

## How to start

**HTTP**
```sh
git clone https://github.com/striderkein/build-acr.git
```
**SSH**
```sh
git clone git@github.com:striderkein/build-acr.git
```

シェルスクリプト版を使いたい場合は `b` オプションを使用して下記のように:
```sh
# HTTP
git clone -b bash https://github.com/striderkein/build-acr.git
# SSH
git clone -b bash git@github.com:striderkein/build-acr.git
```

## 直接ダウンロード

以下のリンクをクリックすると、スクリプトを直接ダウンロードできます：

- [build-acr.ps1 をダウンロード](https://raw.githubusercontent.com/striderkein/build-acr/main/build-acr.ps1)

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
# カレントディレクトリのWARファイルを指定
.\build-acr.ps1 -war "awesome-app-0.0.1-SNAPSHOT_STG.war"

# 相対パスでサブディレクトリのWARファイルを指定
.\build-acr.ps1 -war "target/awesome-app-0.0.4-SNAPSHOT_STG.war"

# 相対パスで親ディレクトリのWARファイルを指定
.\build-acr.ps1 -war "../build/awesome-app-0.0.4-SNAPSHOT_STG.war"

# 引数 war を渡さずに実行した場合はカレントディレクトリの WAR をターゲットにする
.\build-acr.ps1
```

**実行時にエラーが出るときは**
「スクリプトの実行が無効になっているため…」というエラーが出るときは下記コマンドを実行してから再実行する必要あり。
```ps
＞ Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### オプション

- `-t, --tag`: イメージタグ（例：myacr.azurecr.io/app:1.0.0）
- `-r, --repository`: リポジトリ（例: `my-app`）
- `-w, --war`: WARファイル名（例：app-1.0.0.war）
- `-g, --resource-group`: Azureリソースグループ名
- `-c, --container-registry`: Azure Container Registry名
- `-h, --help`: ヘルプメッセージを表示
