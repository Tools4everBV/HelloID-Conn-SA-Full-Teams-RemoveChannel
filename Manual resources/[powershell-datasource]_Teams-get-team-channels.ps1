$groupId = $datasource.selectedValue.GroupId
Write-Information $groupId
try {
    Write-Information -Message "Generating Microsoft Graph API Access Token user.."

    $baseUri = "https://login.microsoftonline.com/"
    $authUri = $baseUri + "$AADTenantID/oauth2/token"

    $body = @{
        grant_type      = "client_credentials"
        client_id       = "$AADAppId"
        client_secret   = "$AADAppSecret"
        resource        = "https://graph.microsoft.com"
    }

    $Response = Invoke-RestMethod -Method POST -Uri $authUri -Body $body -ContentType 'application/x-www-form-urlencoded'
    $accessToken = $Response.access_token;

    #Add the authorization header to the request
    $authorization = @{
        Authorization = "Bearer $accesstoken";
        'Content-Type' = "application/json";
        Accept = "application/json";
    }

    $baseSearchUri = "https://graph.microsoft.com/"
    
    $channelUri = $baseSearchUri + "v1.0/teams" + "/$groupId/channels"
    Write-Information $channelUri

    $channels = Invoke-RestMethod -Uri $channelUri -Method Get -Headers $authorization -Verbose:$false
    
    foreach($channel in $channels.value)
    {
        $returnObject = @{Channel=$channel.DisplayName; Id=$channel.Id }
        Write-Output $returnObject        
    }
    
}
catch
{
    Write-Error "Error getting Team Details. Error: $($_.Exception.Message)"
    Write-Warning -Message "Error getting Team Details"
    return
}

