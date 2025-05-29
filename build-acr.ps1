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
            [Environment]::SetEnvironmentVariable($key, $val, "Process")
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
    [string]$envName = $env:ENV
)

# 値の確認と補正
if (-not $tag) {
    Write-Error "必須の引数が不足しています。-tag は指定するか、.env に定義してください。"
    exit 1
}
if (-not $registryPrefix) {
    Write-Error "REGISTRY_PREFIX が .env に定義されていません。"
    exit 1
}
if (-not $envName) {
    $envName = "stg"
}

# カレントディレクトリから WAR ファイルを検索
$warPattern = "$repository-$tag-.*_$envName\.war"
$matchedFiles = Get-ChildItem -Path . -File | Where-Object { $_.Name -match $warPattern }

if (-not $matchedFiles) {
    Write-Error "カレントディレクトリに WAR ファイルが見つかりません。"
    exit 1
}

$war = $matchedFiles[0].Name

if ($matchedFiles.Count -gt 1) {
    Write-Warning "複数の WAR ファイルが見つかりました。最初のファイルを使用します: $war"
} else {
    Write-Host "WAR ファイルを検出しました: $war"
}

# ACR イメージ構築情報
$resourceGroup = "${resourceGroupPrefix}${envName}${resourceGroupSuffix}"
$registry = "${registryPrefix}${envName}"
$image = "${registry}${registryHostSuffix}/${repository}:${tag}"

# ACR build 実行
az acr build -g $resourceGroup --registry $registry `
  -t $image `
  --build-arg WAR_FILE_NAME=$war `
  ./

Read-Host "Press enter to continue..."
