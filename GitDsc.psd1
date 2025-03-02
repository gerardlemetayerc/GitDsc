@{
    # Version du module
    ModuleVersion = '1.0.0'

    # Identifiant unique du module
    GUID = '12345678-1234-5678-1234-567812345678'

    # Auteur du module
    Author = 'Charles GERARD-LE METAYER'

    # Nom de l'entreprise (optionnel)
    CompanyName = ''

    # Description du module
    Description = 'Module DSC pour gérer les configurations Git et la synchronisation des dépôts.'

    # Version de PowerShell requise
    PowerShellVersion = '5.1'

    # Module racine (le fichier principal du module)
    RootModule = 'GitDSC.psm1'

    # Modules requis pour le fonctionnement
    RequiredModules = @('PSDesiredStateConfiguration')

    # Compatibilité avec les éditions PowerShell
    CompatiblePSEditions = @('Desktop', 'Core')

    # Liste des ressources DSC contenues dans le module
    DscResourcesToExport = @(
        'GitGlobalConf',
        'GitRepoConf',
        'GitSync'
    )

    # Commandes exportées (pas nécessaire ici car on utilise DSCResourcesToExport)
    FunctionsToExport   = @()
    CmdletsToExport     = @()
    VariablesToExport   = @()
    AliasesToExport     = @()

    # Licence et copyright
    LicenseUri = ''
    ProjectUri = ''
    Tags = @('DSC', 'Git', 'Configuration', 'Automation')

    # Prise en charge des formats d'aide (commentaires XML, Markdown, etc.)
    HelpInfoURI = ''

    # Dépendances externes (ajouter ici si d'autres modules sont nécessaires)
    ExternalModuleDependencies = @()
}
