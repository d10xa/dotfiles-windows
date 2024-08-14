# Chocolatey

function Install-Chocolatey {
  Write-Host "Installing Chocolatey:" -ForegroundColor "Green";
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"));
}

function Set-Chocolatey-Configuration {
  Write-Host "Configuring Chocolatey:" -ForegroundColor "Green";
  choco feature enable -n=useRememberedArgumentsForUpgrades;
}

function Enable-Chocolatey-Helpers {
  Write-Host "Loading Chocolatey helpers:" -ForegroundColor "Green";

  $ChocolateyProfile = Join-Path -Path $env:ChocolateyInstall -ChildPath "helpers" | Join-Path -ChildPath "chocolateyProfile.psm1";

  if (Test-Path($ChocolateyProfile)) {
    Import-Module $ChocolateyProfile;
  };
}

if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Install-Chocolatey;
} else {
    Write-Host "Chocolatey is already installed." -ForegroundColor "Yellow";
}
Set-Chocolatey-Configuration;
Enable-Chocolatey-Helpers;

# Choco packages

choco install packages.config;

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

# Git

# Функция для получения значения из git config
function Get-GitConfigValue {
    param (
        [string]$Key
    )
    & git config --global $Key 2>$null
}

function Set-Git-Configuration {
  Write-Host "Configuring Git:" -ForegroundColor "Green";

  $GitUserName = Get-GitConfigValue "user.name"
  $GitUserEmail = Get-GitConfigValue "user.email"
  $GitAutoCrlf = Get-GitConfigValue "core.autocrlf"
  # $AutoCrlfSetting = Read-Host -Prompt "Set core.autocrlf (true, input, or false)"
  $AutoCrlfSetting = "true"

  if (-not $GitUserName) {
      $GitUserName = Read-Host -Prompt "Input your Git user name here"
      git config --global user.name "$GitUserName"
  } else {
      Write-Host "Git user.name is already set to: $GitUserName" -ForegroundColor "Yellow";
  }

  if (-not $GitUserEmail) {
      $GitUserEmail = Read-Host -Prompt "Input your Git user email here"
      git config --global user.email "$GitUserEmail"
  } else {
      Write-Host "Git user.email is already set to: $GitUserEmail" -ForegroundColor "Yellow";
  }

  if (-not $GitAutoCrlf) {
      git config --global core.autocrlf "$AutoCrlfSetting"
      Write-Host "Git core.autocrlf set to: $GitAutoCrlf" -ForegroundColor "Green";
  } else {
      Write-Host "Git core.autocrlf is already set to: $GitAutoCrlf" -ForegroundColor "Yellow";
  }

  Write-Host "Git was successfully configured." -ForegroundColor "Green";
}


$gitInstalled = Get-Command git -ErrorAction SilentlyContinue

if (-not $gitInstalled) {
    Write-Host "Git is not installed. Installing Git..." -ForegroundColor Green
    choco install git -y --params "/NoAutoCrlf /WindowsTerminal /NoShellIntegration /SChannel";
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
} else {
    Write-Host "Git is already installed." -ForegroundColor Yellow
}
Set-Git-Configuration;
