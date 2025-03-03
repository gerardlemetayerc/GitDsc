@{
    ModuleVersion = '1.0.0'
    GUID = '991a2593-01ed-4c9a-b250-77bd801a4e4e'
    Author = 'Charles GERARD-LE METAYER'
    Description = 'Ressource DSC permettant de configurer les paramètres Git locaux pour un dépôt spécifique.'
    PowerShellVersion = '5.1'
    RequiredModules = @('PSDesiredStateConfiguration')
    CompatiblePSEditions = @('Desktop', 'Core')
    DscResourcesToExport = @('GitRepoConf')
    LicenseUri = ''
    ProjectUri = 'https://github.com/gerardlemetayerc/GitDsc'
    Tags = @('DSC', 'Git', 'Configuration')
    HelpInfoURI = ''
}
