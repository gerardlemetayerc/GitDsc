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
        Write-Verbose "Checking directory $($this.LocalPath)"
        if (-Not (Test-Path $this.LocalPath)) { 
            Write-Verbose "Directory $($this.LocalPath) does not exist."
            return $false 
        }

        if(-Not (Test-Path "$($this.LocalPath)\.git")){
            Write-Verbose "$($this.LocalPath) is not a valid git repository." 
            return $false   
        }

        $CurrentBranch = git -C $this.LocalPath rev-parse --abbrev-ref HEAD
        if ($CurrentBranch -ne $this.Branch) {
            Write-Verbose "Current branch ($CurrentBranch) is not target branch $($this.Branch)."
            return $false
        }

        $LocalHash = git -C $this.LocalPath rev-parse HEAD
        $RemoteHash = git -C $this.LocalPath ls-remote origin $this.Branch | ForEach-Object { $_ -split "`t" } | Select-Object -First 1

        if ($LocalHash -ne $RemoteHash) {
            Write-Verbose "Repository is not up to date."
            return $false
        }

        return $true
    }

    [void] Set() {
        $AuthRepoUrl = $this.GitRepositoryUrl

        if ($this.AuthType -eq "token") {
            if ($null -eq $this.Credential) {
                throw "Erreur : Token is needed when 'token' authentication is set."
            }
            $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($this.Credential.Password)
            )
            $AuthRepoUrl = $this.GitRepositoryUrl -replace "https://", "https://$Password@"
        }
        elseif ($this.AuthType -eq "basic") {
            if ($null -eq $this.Credential) {
                throw "Error : Credentials are needed when basic authentication is set."
            }
            $Username = $this.Credential.UserName
            $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($this.Credential.Password)
            )
            $AuthRepoUrl = "https://{0}:{1}@{2}" -f $Username, $Password, $($($this.GitRepositoryUrl -replace '^https://'))
        }

        if (-Not (Test-Path "$($this.LocalPath)\.git")) {
            
            New-Item -ItemType Directory -Path $this.LocalPath -Force 
            Write-Verbose "Cloning repository into $($this.LocalPath)..."
            Remove-Item -Recurse -Force -Path $this.LocalPath -ErrorAction SilentlyContinue
            $cloneResult = git clone --branch $this.Branch "$AuthRepoUrl" $this.LocalPath 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to clone repository : $cloneResult"
                return
            }
        }
        else {
            if ($this.ForceSync) {
                Write-Verbose "Reset of local repository..."
                git -C $this.LocalPath reset --hard
                git -C $this.LocalPath clean -fd
            }

            Write-Verbose "Updating local repository..."
            $pullResult = git -C $this.LocalPath pull origin $this.Branch 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-Error "Repository update failure : $pullResult"
            }
        }
    }
}
