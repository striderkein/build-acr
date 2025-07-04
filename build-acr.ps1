param(
    [Alias("t", "tag")]
    [string]$ImageTag,
    
    [Alias("r", "repo")]
    [string]$Repository,
    
    [Alias("w", "war")]
    [string]$WarFile,
    
    [Alias("g", "resource-group")]
    [string]$ResourceGroup,
    
    [Alias("c", "container-registry")]
    [string]$ContainerRegistry,
    
    [Alias("h")]
    [switch]$Help
)

# ヘルプメッセージを表示する関数
function Show-Help {
    Write-Host @"
Azure Container Registry (ACR) でコンテナイメージをビルドするためのスクリプト

使用方法:
    .\build-acr.ps1 [オプション]

オプション:
    -t, --tag               イメージタグ（例：myacr.azurecr.io/app:1.0.0）
    -r, --repo              リポジトリ（例: my-app）
    -w, --war               WARファイル名（例：app-1.0.0.war）
    -g, --resource-group    Azureリソースグループ名
    -c, --container-registry Azure Container Registry名
    -h                      ヘルプメッセージを表示

例:
    .\build-acr.ps1 -w "app-1.0.0.war" -t "myacr.azurecr.io/app:1.0.0"
    .\build-acr.ps1 --war "target/app.war" --tag "1.0.0"
    .\build-acr.ps1 -h
"@
}

# ヘルプが要求された場合は表示して終了
if ($Help) {
    Show-Help
    exit 0
}

function Load-DotEnv {
    param (
        [string]$Path = ".env"
    )

    if (-Not (Test-Path $Path)) {
        Write-Warning "$Path not found."
        return
    }

    Get-Content $Path | ForEach-Object {
        $_ = $_.Trim()
        if ($_ -and -not $_.StartsWith("#") -and ($_ -match '^\s*([^=]+?)\s*=\s*(.*)$')) {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim(@([char]32, '"', "'"))
            [Environment]::SetEnvironmentVariable($key, $val, "Process")
        }
    }
}

function main {
    param (
        [string]$registryPrefix = $env:REGISTRY_PREFIX,
        [string]$resourceGroupPrefix = $env:RESOURCE_GROUP_PREFIX,
        [string]$resourceGroupSuffix = $env:RESOURCE_GROUP_SUFFIX,
        [string]$registryHostSuffix = $env:REGISTRY_HOST_SUFFIX,
        [string]$repository,
        [string]$tag,
        [string]$envName = $env:ENV,
        [string]$war,
        [string]$resourceGroup,
        [string]$registry
    )

    # Load .env
    Load-DotEnv

    # コマンドライン引数で渡された値を優先して設定
    if (-not $repository) {
        $repository = $env:REPOSITORY
    }
    if (-not $tag) {
        $tag = $env:TAG
    }

    # console output required variables
    Write-Host "Using the following parameters:"
    Write-Host "tag: $tag"
    Write-Host "registryPrefix: $registryPrefix"
    Write-Host "resourceGroupPrefix: $resourceGroupPrefix"
    Write-Host "resourceGroupSuffix: $resourceGroupSuffix"
    Write-Host "registryHostSuffix: $registryHostSuffix"
    Write-Host "repository: $repository"
    Write-Host "envName: $envName"
    if ($war) {
        Write-Host "war: $war (specified as argument)"
    }
    if ($resourceGroup) {
        Write-Host "resourceGroup: $resourceGroup (specified as argument)"
    }
    if ($registry) {
        Write-Host "registry: $registry (specified as argument)"
    }

    # Validate values
    if (-not $tag) {
        Write-Error "Required argument is missing. -tag must be specified or defined in .env."
        exit 1
    }
    if (-not $repository) {
        Write-Error "Required argument is missing. -r (--repo) must be specified or defined in .env."
        exit 1
    }
    if (-not $registryPrefix -and -not $registry) {
        Write-Error "REGISTRY_PREFIX is not defined in .env or -c (--container-registry) is not specified."
        exit 1
    }
    if (-not $envName) {
        $envName = "stg"
    }

    # WAR file handling
    if ($war) {
        # Use specified WAR file (relative path allowed)
        if (-not (Test-Path $war)) {
            Write-Error "Specified WAR file not found: $war"
            exit 1
        }
        $war = Split-Path -Leaf $war  # Get just the filename for build arg
        Write-Host "Using specified WAR file: $war"
    } else {
        # Search for WAR file in current directory
        $warPattern = "$repository-.*_$envName\.war"
        $matchedFiles = Get-ChildItem -Path . -File | Where-Object { $_.Name -imatch $warPattern }

        if (-not $matchedFiles) {
            Write-Error "WAR file not found in the current directory."
            exit 1
        }

        $war = $matchedFiles[0].Name

        if ($matchedFiles.Count -gt 1) {
            Write-Warning "Multiple WAR files found. Using the first one: $war"
        } else {
            Write-Host "WAR file detected: $war"
        }
    }

    # ACR image build info
    if (-not $resourceGroup) {
        $resourceGroup = "${resourceGroupPrefix}${envName}${resourceGroupSuffix}"
    }
    if (-not $registry) {
        $registry = "${registryPrefix}${envName}"
    }
    
    # イメージタグの処理：完全なタグが指定されている場合はそのまま使用、そうでなければ構築
    if ($tag -like "*azurecr.io*" -or $tag -like "*/*") {
        $image = $tag
    } else {
        $image = "${registry}${registryHostSuffix}/${repository}:${tag}"
    }

    Write-Host "Building image: $image"
    Write-Host "Resource Group: $resourceGroup"
    Write-Host "Registry: $registry"

    # Run ACR build
    az acr build -g $resourceGroup --registry $registry `
      -t $image `
      --build-arg WAR_FILE_NAME=$war `
      ./

    Read-Host "Press enter to continue..."
}

# メイン処理の実行
main -repository $Repository -tag $ImageTag -war $WarFile -resourceGroup $ResourceGroup -registry $ContainerRegistry
