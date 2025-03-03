@{
    ModuleVersion = '1.0.0'
    GUID = '01184755-edba-48de-b1f3-00d88a9dedcd'
    Author = 'Charles GERARD-LE METAYER'
    Description = 'Ressource DSC permettant de configurer les paramètres Git globaux.'
    PowerShellVersion = '5.1'
    RequiredModules = @('PSDesiredStateConfiguration')
    CompatiblePSEditions = @('Desktop', 'Core')
    DscResourcesToExport = @('GitGlobalConf')
    LicenseUri = ''
    ProjectUri = 'https://github.com/gerardlemetayerc/GitDsc'
    Tags = @('DSC', 'Git', 'Configuration')
    HelpInfoURI = ''
}
