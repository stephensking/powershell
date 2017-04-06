#Add home directories to users that don't have it.

### set environment specific variables here

#LDAP search base DN
$searchbase = "DC=contoso,DC=com"

#UNC path to home drives
$homedrivepath = "\\contoso.local\shares\Home\"

#drive letter for mapping
$homedriveletter = H:

#Short Domain Name
$Domain = 'CONTOSO'

####################################################################################################################################################


$badusers = Get-ADUser -Filter {Enabled -eq $true} -Properties HomeDirectory,HomeDrive -SearchBase $searchbase | Where-Object { $_.homedirectory -eq $null} 

foreach($user in $badusers)
    {
    $path = $homedrivepath + ($user.SamAccountName)
    
    
    Set-ADUser ($user.SamAccountName) -HomeDirectory $path -HomeDrive $homedriveletter

    If (!(Test-Path $path)){

        New-Item -Path $path -ItemType "directory"
        }
    
    # Set parameters for Access rule

    $IdentityReference=$Domain+’\’+$user.SamAccountName 

    $FileSystemAccessRights=[System.Security.AccessControl.FileSystemRights]”FullControl”

    $InheritanceFlags=[System.Security.AccessControl.InheritanceFlags]”ContainerInherit, ObjectInherit”

    $PropagationFlags=[System.Security.AccessControl.PropagationFlags]”None”

    $AccessControl=[System.Security.AccessControl.AccessControlType]”Allow”

 
    # Build Access Rule from parameters

    $AccessRule=NEW-OBJECT System.Security.AccessControl.FileSystemAccessRule($IdentityReference,$FileSystemAccessRights,$InheritanceFlags,$PropagationFlags,$AccessControl)

    # Get current Access Rule from Home Folder for User
    
    $HomeFolderACL=GET-ACL $path 
    $HomeFolderACL.AddAccessRule($AccessRule)

    SET-ACL –path $path -AclObject $HomeFolderACL

    
    }