using module PSDesiredStateConfiguration

[DscResource()]
class GitSync {
    [DscProperty(Key)]
    [string] $GitRepositoryUrl  # URL du dépôt Git distant

    [DscProperty(Mandatory)]
    [string] $LocalPath  # Chemin local où synchroniser le dépôt

    [DscProperty()]
    [string] $Branch = "main"  # Branche à synchroniser

    [DscProperty()]
    [PSCredential] $Credential  # Identifiants (Basic Auth ou Token) - Optionnel si AuthType="none"

    [DscProperty(Mandatory)]
    [string] $AuthType  # "token", "basic" ou "none"

    [DscProperty()]
    [bool] $ForceSync = $true  # Forcer la réinitialisation locale avant pull

    [GitSync] Get() {
        return $this
    }

    [bool] Test() {
        if (-Not (Test-Path $this.LocalPath)) { 
            Write-Host "Le répertoire $this.LocalPath n'existe pas."
            return $false 
        }

        $CurrentBranch = git -C $this.LocalPath rev-parse --abbrev-ref HEAD
        if ($CurrentBranch -ne $this.Branch) {
            Write-Host "La branche actuelle ($CurrentBranch) ne correspond pas à $this.Branch."
            return $false
        }

        $LocalHash = git -C $this.LocalPath rev-parse HEAD
        $RemoteHash = git -C $this.LocalPath ls-remote origin $this.Branch | ForEach-Object { $_ -split "`t" } | Select-Object -First 1

        if ($LocalHash -ne $RemoteHash) {
            Write-Host "Le dépôt local n'est pas à jour avec le dépôt distant."
            return $false
        }

        return $true
    }

    [void] Set() {
        $AuthRepoUrl = $this.GitRepositoryUrl

        if ($this.AuthType -eq "token") {
            if ($null -eq $this.Credential) {
                throw "Erreur : Un token est requis pour l'authentification de type 'token'."
            }
            $Password = $this.Credential.GetNetworkCredential().Password
            $AuthRepoUrl = $this.GitRepositoryUrl -replace "https://", "https://$Password@"
        }
        elseif ($this.AuthType -eq "basic") {
            if ($null -eq $this.Credential) {
                throw "Erreur : Un identifiant et un mot de passe sont requis pour l'authentification Basic."
            }
            $Username = $this.Credential.UserName
            $Password = $this.Credential.GetNetworkCredential().Password
            $AuthRepoUrl = "https://{0}:{1}@{2}" -f $Username, $Password, $($($this.GitRepositoryUrl -replace '^https://'))
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
