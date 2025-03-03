configuration SyncGitRepo_NoAuth
{
    param (
        [string] $GitRepositoryUrl = "https://github.com/example/repo.git",
        [string] $LocalPath = "C:\Users\myuser\test-dsc",
        [string] $Branch = "main",
        [bool] $ForceSync
    )

    Import-DscResource -ModuleName GitDSC

    Node localhost
    {
        GitSync RepoSync
        {
            GitRepositoryUrl = $GitRepositoryUrl
            LocalPath = $LocalPath
            Branch = $Branch
            AuthType = "none"  # Pas d'authentification
            ForceSync = $ForceSync
        }
    }
}