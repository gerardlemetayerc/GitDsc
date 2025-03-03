using module PSDesiredStateConfiguration

[DscResource()]
class GitSync {
    [DscProperty(Key)]
    [string] $GitRepositoryUrl  # URL du dépôt Git distant

    [DscProperty(Mandatory)]
    [string] $LocalPath  # Chemin local où synchroniser le dépôt

    [DscProperty()]
    [string] $Branch = "main"  # Branche à synchroniser

    [DscProperty(Mandatory)]
    [PSCredential] $Credential  # Identifiants (Basic Auth ou Token)

    [DscProperty()]
    [string] $AuthType = "token"  # "token" ou "basic"

    [DscProperty()]
    [bool] $ForceSync = $true  # Forcer la réinitialisation locale avant pull

    [void] Get() {
        return @{
            GitRepositoryUrl = $this.GitRepositoryUrl
            LocalPath = $this.LocalPath
            Branch = $this.Branch
            AuthType = $this.AuthType
            ForceSync = $this.ForceSync
        }
    }

    [bool] Test() {
        if (-Not (Test-Path $this.LocalPath)) { return $false }

        $CurrentBranch = (git -C $this.LocalPath rev-parse --abbrev-ref HEAD) -eq $this.Branch
        if (-Not $CurrentBranch) { return $false }

        $LocalHash = git -C $this.LocalPath rev-parse HEAD
        $RemoteHash = git -C $this.LocalPath ls-remote origin $this.Branch | ForEach-Object { $_ -split "`t" } | Select-Object -First 1

        return $LocalHash -eq $RemoteHash
    }

    [void] Set() {
        $Username = $this.Credential.UserName
        $Password = $this.Credential.GetNetworkCredential().Password

        # Construction de l'URL d'authentification
        $AuthRepoUrl = if ($this.AuthType -eq "token") {
            $this.GitRepositoryUrl -replace "https://", "https://$Password@"
        } else {
            "https://$Username:$Password@$($this.GitRepositoryUrl -replace '^https://')"
        }

        if (-Not (Test-Path $this.LocalPath)) {
            Write-Host "Clonage du dépôt Git dans $this.LocalPath..."
            Remove-Item -Recurse -Force -Path $this.LocalPath -ErrorAction SilentlyContinue
            git clone --branch $this.Branch "$AuthRepoUrl" "$this.LocalPath"
        }
        else {
            if ($this.ForceSync) {
                Write-Host "Réinitialisation du dépôt local..."
                git -C $this.LocalPath reset --hard
                git -C $this.LocalPath clean -fd
            }
            Write-Host "Mise à jour du dépôt local..."
            git -C $this.LocalPath pull origin $this.Branch
        }
    }
}
