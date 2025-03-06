@{
    ModuleVersion = '1.0.0'
    GUID = '2e6aec3d-65b6-4196-9764-1f19c8ce53ce'
    Author = 'Charles GERARD-LE METAYER'
    Description = "Module DSC permettant la synchronisation d'un dépôt Git avec un répertoire local."
    PowerShellVersion = '5.1'
    RootModule = 'GitDSC.psm1'
    NestedModules = @(
        "DSCClassResources\GitSync\GitSync.psm1"
    )
    RequiredModules = @('PSDesiredStateConfiguration')
    CompatiblePSEditions = @('Desktop', 'Core')
    DscResourcesToExport = @('GitSync', 'GitConf')
}
