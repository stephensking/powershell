#Just some useful code blocks for the Dropbox business API.


### set environment specific variables here

#dropbox API token.  Better to set this as an environment variable to secure it. $env:Token = xxxxx and change instances below. 
$token = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

####################################################################################################################################################



#retrieves list of all dropbox users and dumps to results_members.json.  Useful for getting team member IDs for other API functions.

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", ("Bearer " + $token))
$headers.Add("Content-Type", 'application/json')

$body = '{"limit": 100,"include_removed": false}'

Invoke-RestMethod -Uri "https://api.dropboxapi.com/2/team/members/list" -Method Post -Headers $headers -Body $body -OutFile results_members.json



#gets folder IDs for all team folders

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", ("Bearer " + $token))
$headers.Add("Content-Type", 'application/json')
$body = '{"limit": 100}'

Invoke-RestMethod -Uri "https://api.dropboxapi.com/2/team/team_folder/list" -Method Post -Headers $headers -Body $body -OutFile results_teamfolders.json



#get metadata for a specific team folder ID.

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", ("Bearer " + $token))
$headers.Add("Content-Type", 'application/json')
$body = '{"team_folder_ids": ["11111111111"]}'

Invoke-RestMethod -Uri "https://api.dropboxapi.com/2/team/team_folder/get_info" -Method Post -Headers $headers -Body $body -OutFile results_folderinfo.json