using module PSDesiredStateConfiguration

[DscResource()]
class GitGlobalConf {
    [DscProperty(Key)]
    [string] $Name  # Nom de la configuration globale (clé d’identification)

    [DscProperty(Mandatory)]
    [Hashtable] $Config  # Clé/valeurs des paramètres Git globaux

    [GitGlobalConf] Get() {
        return $this
    }

    [bool] Test() {
        foreach ($Key in $this.Config.Keys) {
            $CurrentValue = git config --global --get $Key
            if ($CurrentValue -ne $this.Config[$Key]) {
                Write-Host "Le paramètre Git global $Key est différent. Attendu: $($this.Config[$Key]), Actuel: $CurrentValue"
                return $false
            }
        }
        return $true
    }

    [void] Set() {
        foreach ($Key in $this.Config.Keys) {
            Write-Host "Application de la configuration Git globale : $Key = $($this.Config[$Key])"
            git config --global $Key "$($this.Config[$Key])"
        }
    }
}
