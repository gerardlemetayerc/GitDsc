[DscResource()]
class GitRepoConf {
    [DscProperty(Key)]
    [string] $RepoPath  # Chemin du dépôt Git

    [DscProperty(Mandatory)]
    [Hashtable] $Config  # Clé/valeurs des paramètres Git locaux

    [GitRepoConf] Get() {
        return $this
    }

    [bool] Test() {
        if (-Not (Test-Path "$this.RepoPath\.git")) {
            Write-Host "Le dépôt Git à $this.RepoPath n'existe pas."
            return $false
        }

        foreach ($Key in $this.Config.Keys) {
            $CurrentValue = git -C $this.RepoPath config --get $Key
            if ($CurrentValue -ne $this.Config[$Key]) {
                Write-Host "Le paramètre Git local $Key est différent. Attendu: $($this.Config[$Key]), Actuel: $CurrentValue"
                return $false
            }
        }
        return $true
    }

    [void] Set() {
        if (-Not (Test-Path "$this.RepoPath\.git")) {
            Write-Host "Initialisation d'un dépôt Git dans $this.RepoPath..."
            git -C $this.RepoPath init
        }

        foreach ($Key in $this.Config.Keys) {
            Write-Host "Application de la configuration Git locale pour $this.RepoPath : $Key = $($this.Config[$Key])"
            git -C $this.RepoPath config $Key "$($this.Config[$Key])"
        }
    }
}
