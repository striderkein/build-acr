﻿function Load-DotEnv {
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
        [string]$repository = $env:REPOSITORY,
        [string]$tag = $env:TAG,
        [string]$envName = $env:ENV,
        [string]$war
    )

    # Load .env
    Load-DotEnv

    # console output required variables
    Write-Host "Using the following parameters from .env:"
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

    # Validate values
    if (-not $tag) {
        Write-Error "Required argument is missing. -tag must be specified or defined in .env."
        exit 1
    }
    if (-not $registryPrefix) {
        Write-Error "REGISTRY_PREFIX is not defined in .env."
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
    $resourceGroup = "${resourceGroupPrefix}${envName}${resourceGroupSuffix}"
    $registry = "${registryPrefix}${envName}"
    $image = "${registry}${registryHostSuffix}/${repository}:${tag}"

    # Run ACR build
    az acr build -g $resourceGroup --registry $registry `
      -t $image `
      --build-arg WAR_FILE_NAME=$war `
      ./

    Read-Host "Press enter to continue..."
}

main
