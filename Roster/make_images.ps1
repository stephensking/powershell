#Mobile version of roster.  Annotates pictures with name/title/department
#Uploaded to a Dropbox team folder, this is surprisingly awesome on mobile.


### set environment specific variables here

#needs imagemagick-7.0.4 or greater installed at c:\program files\imagemagick
$env:Path = "c:\program files\imagemagick";

#LDAP search base DN
$searchbase = "DC=contoso,DC=local"

#readable path to photos.  Filenames are email addresses.jpg
$sourcepath = "\\server.contoso.local\Photos\"

####################################################################################################################################################


#Initialize array.
$finaluserlist=@()

#delete existing images in folder.
remove-item E:\mobile_roster\images\*

#Grab all users from AD.  It pulls SOME properties.  Add custom properties as required.
$userlist = get-aduser -filter {company -eq "Contoso" -and emailaddress -like "*" -and enabled -eq $true} -SearchBase $searchbase -Properties name,mail,title,department,physicalDeliveryOfficeName,telephoneNumber,mobile

#Loop through them.
foreach ($user in $userlist)
    {
    #assemble picture filename 
    $filename = $sourcepath + $user.mail + ".jpg" 
    #mangle the crap out of user titles for use in filenames.
    $fixedtitle = (($user.title).replace(' ','.')).replace(',','')
    #test if the filename exists.  If it does, annotate it.  If it doesn't, LOGO!
    if (test-path $filename)
        {
        #copy the file to E:\mobile_roster\images\
        $destfilename = "E:\mobile_roster\images\" + (($user.Name).replace(' ','.')) + "." + $user.physicalDeliveryOfficeName + "." + $fixedtitle + "." + $user.department + ".jpg"
        Copy-Item -Path $filename -Destination $destfilename
        #this one draws grey boxes and works, but some titles are too long.
        #& magick.exe $destfilename -font Arial -pointsize 36 -fill white  -undercolor "#00000080" -gravity South -annotate +0+47 $($user.name) -annotate +0+5 $($user.title) $destfilename
        #this one should label above the picture.
        #& magick.exe "$destfilename" -font Arial -pointsize 24 -background White label:"$($user.name)" +swap label:"$($user.Title)" +swap label:"$($user.Department)" +swap -gravity Center -append $destfilename         
        #this one should label below the picture.
        #& magick.exe "$destfilename" -font Arial -pointsize 24 -background White label:"$($user.name)" label:"$($user.Title)" label:"$($user.Department)" -gravity Center -append $destfilename 
        #annotate the image
        & magick.exe "$destfilename" -kerning 1 -font Neue-Haas-Grotesk-Display-Pro-75-Bold -pointsize 48 -background White label:"$($user.name)" -font Neue-Haas-Grotesk-Display-Pro-55-Roman -pointsize 24 label:"$($user.Title)" -pointsize 32 label:"$($user.Department)" -gravity Center -append $destfilename
        #. .\business_dropbox_upload.ps1 -SourceFilePath $destfilename -TargetFilePath ("ns:1415400306/" +  (($user.Name).replace(' ','.')) + "." + $user.physicalDeliveryOfficeName + "." + $fixedtitle + "." + $user.department + ".jpg")

        }
    else 
        {
        #copy over the logo.png and add names.
        $destfilename = "E:\mobile_roster\images\" + (($user.Name).replace(' ','.')) + "." + $fixedtitle + "." + $user.department + ".jpg"
        & magick.exe "E:\mobile_roster\logo.png" -kerning 1 -font Neue-Haas-Grotesk-Display-Pro-75-Bold -pointsize 48 -background White label:"$($user.name)" -font Neue-Haas-Grotesk-Display-Pro-55-Roman -pointsize 24 label:"$($user.Title)" -pointsize 32 label:"$($user.Department)" -gravity Center -append $destfilename
        #. .\business_dropbox_upload.ps1 -SourceFilePath $destfilename -TargetFilePath ("ns:1415400306/" +  (($user.Name).replace(' ','.')) + "." + $user.physicalDeliveryOfficeName + "." + $fixedtitle + "." + $user.department + ".jpg")

        }
    }

