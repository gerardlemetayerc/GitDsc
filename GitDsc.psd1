@{
    ModuleVersion = '1.0.0'
    GUID = '1f7f9386-cb25-49f5-98e2-43b9629e0eef'
    Author = 'Charles GERARD-LE METAYER'
    Description = 'Module DSC pour gérer les configurations Git et la synchronisation des dépôts.'
    PowerShellVersion = '5.1'
    RootModule = 'GitDSC.psm1'
    RequiredModules = @('PSDesiredStateConfiguration')
    CompatiblePSEditions = @('Desktop', 'Core')
    DscResourcesToExport = @('GitGlobalConf', 'GitRepoConf', 'GitSync')
    HelpInfoURI = ''
}
