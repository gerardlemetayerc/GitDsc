configuration CloneGitRepo
{
    param (
        [PSCredential] $GitCredential = $null,  # Le credential est maintenant optionnel
        [string] $GitRepositoryUrl = "https://github.com/example/repo.git",
        [string] $LocalPath = "C:\Users\elrey\test-dsc",
        [string] $Branch = "main",
        [bool] $ForceSync = $true,
        [string] $AuthType = "none"  # "token", "basic" ou "none" (sans authentification)
    )

    Import-DscResource -ModuleName GitDSC

    Node localhost
    {
        GitSync RepoClone
        {
            GitRepositoryUrl = $GitRepositoryUrl
            LocalPath = $LocalPath
            Branch = $Branch
            AuthType = $AuthType
            ForceSync = $ForceSync

            # Ajoute le credential uniquement si l'authentification est requise
            if ($AuthType -ne "none") {
                Credential = $GitCredential
            }
        }
    }
}

# 1️⃣ Définition des paramètres
$GitRepositoryUrl = "https://github.com/example/repo.git"  # Remplace par ton dépôt Git
$LocalPath = "C:\Users\elrey\test-dsc"
$Branch = "main"
$ForceSync = $true
$AuthType = "none"  # Options: "none", "token", "basic"

# 2️⃣ Création du credential si nécessaire
if ($AuthType -eq "token") {
    $Token = ConvertTo-SecureString "ghp_tonTokenIci" -AsPlainText -Force
    $GitCredential = New-Object System.Management.Automation.PSCredential ("token", $Token)
} elseif ($AuthType -eq "basic") {
    $Username = "monIdentifiant"
    $Password = ConvertTo-SecureString "monMotDePasse" -AsPlainText -Force
    $GitCredential = New-Object System.Management.Automation.PSCredential ($Username, $Password)
} else {
    $GitCredential = $null
}

# 3️⃣ Compilation de la configuration
CloneGitRepo -GitCredential $GitCredential -GitRepositoryUrl $GitRepositoryUrl -LocalPath $LocalPath -Branch $Branch -ForceSync $ForceSync -AuthType $AuthType

# 4️⃣ Application de la configuration DSC
Start-DscConfiguration -Path .\CloneGitRepo -Wait -Verbose -Force
