using module PSDesiredStateConfiguration

[DscResource()]
class GitGlobalConf {
    [DscProperty(Key)]
    [string] $Name  # Nom de la configuration globale (uniquement utilisé comme clé)

    [DscProperty(Mandatory)]
    [Hashtable] $Config  # Clé/valeurs des paramètres globaux Git

    [void] Get() {
        $currentConfig = @{}
        foreach ($Key in $this.Config.Keys) {
            $Value = git config --global --get $Key
            if ($Value) {
                $currentConfig[$Key] = $Value
            }
        }
        return @{ Name = $this.Name; Config = $currentConfig }
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
            Write-Host "Appliquer la configuration Git globale : $Key = $($this.Config[$Key])"
            git config --global $Key "$($this.Config[$Key])"
        }
    }
}
