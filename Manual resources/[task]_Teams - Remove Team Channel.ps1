# Set TLS to accept TLS, TLS 1.1 and TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

$baseGraphUri = "https://graph.microsoft.com/"

$VerbosePreference = "SilentlyContinue"
$InformationPreference = "Continue"
$WarningPreference = "Continue"

# variables configured in form
$groupid = $form.teams.GroupId
$channelname = $form.channels.Channel
$team = $form.teams.DisplayName
$channelid = $form.channels.Id


# Create authorization token and add to headers
try{
    Write-Information "Generating Microsoft Graph API Access Token"

    $baseUri = "https://login.microsoftonline.com/"
    $authUri = $baseUri + "$AADTenantID/oauth2/token"

    $body = @{
        grant_type    = "client_credentials"
        client_id     = "$AADAppId"
        client_secret = "$AADAppSecret"
        resource      = "https://graph.microsoft.com"
    }

    $Response = Invoke-RestMethod -Method POST -Uri $authUri -Body $body -ContentType 'application/x-www-form-urlencoded'
    $accessToken = $Response.access_token;

    #Add the authorization header to the request
    $authorization = @{
        Authorization  = "Bearer $accesstoken";
        'Content-Type' = "application/json";
        Accept         = "application/json";
    }
}
catch{
    throw "Could not generate Microsoft Graph API Access Token. Error: $($_.Exception.Message)"    
}

try {
    Write-Information "Deleting Channel [$channelname] from team [$team]."

    $deleteChannelUri = $baseGraphUri + "v1.0/teams/$groupid/channels/$channelid"

    $deleteChannel = Invoke-RestMethod -Method DELETE -Uri $deleteChannelUri -Headers $authorization -Verbose:$false
    
    Write-Information "Successfully deleted channel [$channelname] from team [$team]."
    $Log = @{
        Action            = "DeleteResource" # optional. ENUM (undefined = default) 
        System            = "MicrosoftTeams" # optional (free format text) 
        Message           = "Successfully deleted channel [$channelname] from team [$team]." # required (free format text) 
        IsError           = $false # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
        TargetDisplayName = $channelname # optional (free format text)
        TargetIdentifier  = $channelid # optional (free format text)
    }
    #send result back  
    Write-Information -Tags "Audit" -MessageData $log
}
catch
{
    Write-Error "Failed to delete channel [$channelname] from team [$team]. Error: $($_.Exception.Message)"
    $Log = @{
        Action            = "DeleteResource" # optional. ENUM (undefined = default) 
        System            = "MicrosoftTeams" # optional (free format text) 
        Message           = "Failed to delete channel [$channelname] from team [$team]." # required (free format text) 
        IsError           = $true # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
        TargetDisplayName = $channelname # optional (free format text)
        TargetIdentifier  = $channelid # optional (free format text)
    }
    #send result back  
    Write-Information -Tags "Audit" -MessageData $log
}

