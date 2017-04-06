#This is a Powershell script to upload a file to DropBox using their business REST API.  
#Adapted from Laurent Kempe's script: http://laurentkempe.com/2016/04/07/Upload-files-to-DropBox-from-PowerShell/ which used the personal API.
#This API is annoying.  You still have to point it at the dropbox user ID of an admin, which means you need an admin service account or it will break when your impersonated admin leaves.

Param(
    [Parameter(Mandatory=$true)]
    [string]$SourceFilePath,
    [Parameter(Mandatory=$true)]
    [string]$TargetFilePath
)

### set environment specific variables here

#readable path to photos.  Filenames are email addresses.jpg
$sourcepath = "\\server.contoso.local\photos\"

#dropbox API token.  Better to set this as an environment variable.
$token = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

#Dropbox Admin impersonation.  This is the dropbox member ID of a team admin.  Ugh. 
$dbmid = 'dbmid:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'

####################################################################################################################################################


#can set these options. Documented in API.  What I'm using is somewhat dangerous.  Overwrite files, don't notify users.

$arg = '{ "path": "' + $TargetFilePath + '", "mode": "overwrite", "autorename": true, "mute": true }'

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", ("Bearer " + $token))
$headers.Add("Dropbox-API-Arg", $arg)
$headers.Add("Content-Type", 'application/octet-stream')
$headers.Add("Dropbox-API-Select-Admin", $dbmid)

Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
 
