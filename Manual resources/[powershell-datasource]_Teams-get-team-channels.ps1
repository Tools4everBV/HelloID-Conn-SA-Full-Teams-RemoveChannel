#Input: TeamsAdminUser
#Input: TeamsAdminPWD

# Set TLS to accept TLS, TLS 1.1 and TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

$VerbosePreference = "SilentlyContinue"
$InformationPreference = "Continue"
$WarningPreference = "Continue"

# variables configured in form
$GroupId = $datasource.selectedTeam.groupId

$connected = $false
try {
	$module = Import-Module MicrosoftTeams
	$pwd = ConvertTo-SecureString -string $TeamsAdminPWD -AsPlainText -Force
	$cred = New-Object System.Management.Automation.PSCredential $TeamsAdminUser, $pwd
	$teamsConnection = Connect-MicrosoftTeams -Credential $cred
    Write-Information "Connected to Microsoft Teams"
    $connected = $true
}
catch
{	
    Write-Error "Could not connect to Microsoft Teams. Error: $($_.Exception.Message)"
}

if ($connected)
{
	try {
		$teamChannels = Get-TeamChannel -GroupId $GroupId

		if(@($teamChannels).Count -gt 0){
		 foreach($teamChannel in $teamChannels)
			{
				$resultObject = @{DisplayName=$teamChannel.DisplayName; Description=$teamChannel.Description; Id=$teamChannel.Id;}
				Write-Output $resultObject
			}
		}
	}
	catch
	{
		Write-Error "Error getting Team Channels. Error: $($_.Exception.Message)"
	}
}
