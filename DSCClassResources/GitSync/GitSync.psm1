[DscResource()]
class GitSync {
    [DscProperty(Key)]
    [string] $GitRepositoryUrl

    [DscProperty(Mandatory)]
    [string] $LocalPath

    [DscProperty()]
    [string] $Branch = "main"

    [DscProperty()]
    [PSCredential] $Credential

    [DscProperty(Mandatory)]
    [string] $AuthType  # "token", "basic", "none"

    [DscProperty()]
    [bool] $ForceSync = $true

    [GitSync] Get() {
        return $this
    }

    [bool] Test() {
        Write-Verbose "Vérification du répertoire $($this.LocalPath)"
        if (-Not (Test-Path $this.LocalPath)) { 
            Write-Verbose "Le répertoire $($this.LocalPath) n'existe pas."
            return $false 
        }

        if(-Not (Test-Path "$($this.LocalPath)\.git")){
            Write-Verbose "$($this.LocalPath) is not a valid git repository." 
            return $false   
        }

        $CurrentBranch = git -C $this.LocalPath rev-parse --abbrev-ref HEAD
        if ($CurrentBranch -ne $this.Branch) {
            Write-Verbose "La branche actuelle ($CurrentBranch) ne correspond pas à $($this.Branch)."
            return $false
        }

        $LocalHash = git -C $this.LocalPath rev-parse HEAD
        $RemoteHash = git -C $this.LocalPath ls-remote origin $this.Branch | ForEach-Object { $_ -split "`t" } | Select-Object -First 1

        if ($LocalHash -ne $RemoteHash) {
            Write-Verbose "Le dépôt local n'est pas à jour avec le dépôt distant."
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
            $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($this.Credential.Password)
            )
            $AuthRepoUrl = $this.GitRepositoryUrl -replace "https://", "https://$Password@"
        }
        elseif ($this.AuthType -eq "basic") {
            if ($null -eq $this.Credential) {
                throw "Erreur : Un identifiant et un mot de passe sont requis pour l'authentification Basic."
            }
            $Username = $this.Credential.UserName
            $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($this.Credential.Password)
            )
            $AuthRepoUrl = "https://{0}:{1}@{2}" -f $Username, $Password, $($($this.GitRepositoryUrl -replace '^https://'))
        }

        if (-Not (Test-Path "$($this.LocalPath)\.git")) {
            
            New-Item -ItemType Directory -Path $this.LocalPath -Force 
            Write-Verbose "Clonage du dépôt Git dans $($this.LocalPath)..."
            Remove-Item -Recurse -Force -Path $this.LocalPath -ErrorAction SilentlyContinue
            $cloneResult = git clone --branch $this.Branch "$AuthRepoUrl" $this.LocalPath 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-Error "Échec du clonage du dépôt : $cloneResult"
                return
            }
        }
        else {
            if ($this.ForceSync) {
                Write-Verbose "Réinitialisation du dépôt local..."
                git -C $this.LocalPath reset --hard
                git -C $this.LocalPath clean -fd
            }

            Write-Verbose "Mise à jour du dépôt local..."
            $pullResult = git -C $this.LocalPath pull origin $this.Branch 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-Error "Échec de la mise à jour du dépôt : $pullResult"
            }
        }
    }
}
