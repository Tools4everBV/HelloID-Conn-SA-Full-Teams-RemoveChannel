$connected = $false
try {
	Import-Module MicrosoftTeams
	$pwd = ConvertTo-SecureString -string $TeamsAdminPWD -AsPlainText –Force
	$cred = New-Object System.Management.Automation.PSCredential $TeamsAdminUser, $pwd
	Connect-MicrosoftTeams -Credential $cred
    HID-Write-Status -Message "Connected to Microsoft Teams" -Event Information
    HID-Write-Summary -Message "Connected to Microsoft Teams" -Event Information
	$connected = $true
}
catch
{	
    HID-Write-Status -Message "Could not connect to Microsoft Teams. Error: $($_.Exception.Message)" -Event Error
    HID-Write-Summary -Message "Failed to connect to Microsoft Teams" -Event Failed
}

if ($connected)
{
	try {
		Remove-TeamChannel -groupId $groupId -displayName $displayName
		HID-Write-Status -Message "Removed Channel [$displayName] from Team [$groupId]" -Event Success
		HID-Write-Summary -Message "Successfully removed Channel [$displayName] from Team [$groupId]" -Event Success
	}
	catch
	{
		HID-Write-Status -Message "Could not remove Channel [$displayName] from Team [$groupId]. Error: $($_.Exception.Message)" -Event Error
		HID-Write-Summary -Message "Failed to remove Channel [$displayName] from Team [$groupId]" -Event Failed
	}
}