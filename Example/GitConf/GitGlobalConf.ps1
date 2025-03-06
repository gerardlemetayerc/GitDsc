configuration GitGlobalConf
{
    Import-DscResource -ModuleName GitDSC

    Node localhost
    {
        GitConf userName
        {
            Name = 'user.name'
            Value = 'gerardlemetayer'
            ConfScope = 'local'
            Ensure = 'Present'  # Pas d'authentification
        }
    }
} 