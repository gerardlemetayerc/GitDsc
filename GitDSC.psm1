# Importation des ressources DSC contenues dans le module
Import-Module -Name "$PSScriptRoot\DSCResources\GitGlobalConf\GitGlobalConf.psm1" -Force
Import-Module -Name "$PSScriptRoot\DSCResources\GitRepoConf\GitRepoConf.psm1" -Force
Import-Module -Name "$PSScriptRoot\DSCResources\GitSync\GitSync.psm1" -Force

# Exportation des ressources DSC
Export-ModuleMember -Function * -Alias * -Cmdlet * -Variable *
