enum Ensure {
    Absent
    Present
}

enum ConfScope {
    local
    global
}

[DscResource()]
class GitGlobalConf {
    [DscProperty(Key)]
    [string] $Name

    [DscProperty(Mandatory)]
    [string] $Value

    [DscProperty(Mandatory)]
    [Hashtable] $Config

    [DscProperty(Mandatory)]
    [Ensure]
    $Ensure

    [DscProperty]
    $RepoPath    

    [DscProperty(Mandatory)]
    [ConfScope]
    $ConfScope

    [GitGlobalConf] Get() {
        return $this
    }

    [bool] Test() {
        $scope = ''
        if($this.ConfScope -match "Global"){$scope = '--global'}
        else{
            if(Test-Path $this.RepoPath){
                Set-Location $this.RepoPath
            }else{
                Write-Error "Target repository $($this.RepoPath) not found"
            }
        }
        $CurrentValue = git config $scope --get $this.Name
        if($null -ne $CurrentValue -and $this.Ensure -match "Absent"){
            Write-Verbose "Parameter should be absent but found in configuration."
            return $false
        }
        if ($CurrentValue -ne $this.Value) {
            Write-Verbose "Paramater $($this.ConfScope) $($this.Name) not as expected. Expected: $($this.Value), Current: $CurrentValue"
            return $false
        }
        return $true
    }

    [void] Set() {
        $scope = ''
        if($this.ConfScope -match "Global"){$scope = '--global'}
        Write-Verbose "Setting Git $($this.ConfScope) : $($this.Name) = $($this.Value)"
        if($this.Ensure -like "Present"){
            git config $scope $this.Name $this.Value
        }else{
            git config --unset $scope $this.Name
        }
    }
}
