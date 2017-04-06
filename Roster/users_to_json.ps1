#Crunch AD users and output as JSON file.  Copy files from central repository to a web server.
#this is used for a web based roster specific to $company.
#note: store hiredate in extensionattribute14 and an employee bio in extensionattribute15.


### set environment specific variables here

#readable path to photos.  Filenames are email addresses.jpg
$sourcepath = "\\server.contoso.local\photos\"

#writeable path to web server running roster app
$destpath = "\\server2.contoso.local\wwwroot\"

#LDAP search base DN
$searchbase = "DC=contoso,DC=local"

####################################################################################################################################################

#Initialize array.
$finaluserlist=@()

#Grab all users from AD.  It pulls SOME properties.  Add custom properties as required.
$userlist = get-aduser -filter {company -eq "Contoso" -and emailaddress -like "*" -and enabled -eq $true} -SearchBase $searchbase -Properties name,mail,title,department,physicalDeliveryOfficeName,telephoneNumber,mobile,ExtensionAttribute14,ExtensionAttribute15

#Loop through them.
foreach ($user in $userlist)
    {
    $tempuserobject = "" | Select "name","mail","title","department","office","telephoneNumber","mobile","picurl","hiredate","bio"
    #write the properties we need for all users to the output object
    $tempuserobject.name = $user.name
    $tempuserobject.mail = $user.mail
    $tempuserobject.title = $user.title
    $tempuserobject.department = $user.department
    $tempuserobject.office = $user.physicalDeliveryOfficeName
    $tempuserobject.telephoneNumber = $user.telephoneNumber
    $tempuserobject.mobile = $user.mobile
    #assemble picture filename and test if it exists.  If it does, add it on.  If it doesn't, point the pic URL for that user at a generic company logo.
    $filename = $sourcepath + $user.mail + ".jpg"
    if (test-path $filename)
        {
        $tempuserobject.picurl = $user.mail + ".jpg"
        #copy the file to wwwroot of sacweb02
        Copy-Item -Path $filename -Destination $destpath
        }
    else 
        {
        $tempuserobject.picurl = "logo.png"
        }
    $tempuserobject.hiredate = $user.ExtensionAttribute14
    $tempuserobject.bio = $user.ExtensionAttribute15
    #output the object to the array
    $finaluserlist += $tempuserobject
    }

#output the completed array to CSV.  Replace Null values with double quotes.
$finaluserlist | ConvertTo-Json | % {$_ -replace 'null','""'}| out-file ansi.json
Get-Content .\ansi.json | Set-Content -Encoding utf8 outfile.json
Copy-Item -Path outfile.json -Destination $destpath