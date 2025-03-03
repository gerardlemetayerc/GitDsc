@{
    ModuleVersion = '1.0.0'
    GUID = '2e6aec3d-65b6-4196-9764-1f19c8ce53ce'
    Author = 'Charles GERARD-LE METAYER'
    Description = "Ressource DSC permettant la synchronisation d'un dépôt Git avec un répertoire local."
    PowerShellVersion = '5.1'
    RequiredModules = @('PSDesiredStateConfiguration')
    CompatiblePSEditions = @('Desktop', 'Core')
    DscResourcesToExport = @('GitSync')
    LicenseUri = ''
    ProjectUri = 'https://github.com/gerardlemetayerc/GitDsc'
    Tags = @('DSC', 'Git', 'Automation')
    HelpInfoURI = ''
}
