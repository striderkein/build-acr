function Load-DotEnv {
    param (
        [string]$Path = ".env"
    )

    if (-Not (Test-Path $Path)) {
        Write-Warning "$Path が見つかりません。"
        return
    }

    Get-Content $Path | ForEach-Object {
        $_ = $_.Trim()
        if ($_ -and -not $_.StartsWith("#") -and ($_ -match '^\s*([^=]+?)\s*=\s*(.*)$')) {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim(' "', "'")
            $env:$key = $val
        }
    }
}

# .env 読み込み
Load-DotEnv

param (
    [string]$registryPrefix = $env:REGISTRY_PREFIX,
    [string]$resourceGroupPrefix = $env:RESOURCE_GROUP_PREFIX,
    [string]$resourceGroupSuffix = $env:RESOURCE_GROUP_SUFFIX,
    [string]$registryHostSuffix = $env:REGISTRY_HOST_SUFFIX,
    [string]$repository = $env:REPOSITORY,
    [string]$tag = $env:TAG,
    [string]$env = $env:ENV
)

# カレントディレクトリからWARファイルを検索
# 正規表現を使用してファイルを特定する
$warFiles = Get-ChildItem -Path . -Filter "$repository-$tag-$(SNAPSHOT|RELEASE)_$envName.war" | Select-Object -ExpandProperty Name
if (-not $warFiles) {
    Write-Error "カレントディレクトリにWARファイルが見つかりません。"
    exit 1
} elseif ($warFiles.Count -gt 1) {
    Write-Warning "複数のWARファイルが見つかりました。最初のファイルを使用します: $($warFiles[0])"
    $war = $warFiles[0]
} else {
    $war = $warFiles[0]
    Write-Host "WARファイルを検出しました: $war"
}

if (-not $tag) {
    Write-Error "必須の引数が不足しています。-tag は指定するか、.env に定義してください。"
    exit 1
}

if (-not $registryPrefix) {
    Write-Error "REGISTRY_PREFIX が .env に定義されていません。"
    exit 1
}

# 環境変数に基づいて処理
$envName = if ($env) { $env } else { "stg" }
$resourceGroup = "$resourceGroupPrefix$envName$resourceGroupSuffix"
$registry = "$registryPrefix$envName"
$image = "$registry$registryHostSuffix/$repository:$tag"

# ACR build 実行
az acr build -g $resourceGroup --registry $registry `
  -t $image `
  # カレントにある前提なのでこの指定は不要
  # -f './Dockerfile' `
  --build-arg WAR_FILE_NAME=$war `
  ./

Read-Host "Press enter to continue..."
