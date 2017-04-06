#In lieu of a working HRIS, checks for AD users with invalid managers.  
#Invalid means either empty or someone who's been disabled.

### set environment specific variables here

#LDAP search base DN
$searchbase = "DC=contoso,DC=local"

#DNS address of an smtp server.
$SendingServer = smtp.contoso.local

#email address emails are sent from.  You may get out of office messages to here.
$FromAddress = "Displayname<return@contoso.com>"


####################################################################################################################################################

#make empty objects
$dead_managers = @()
$dead_users = @()
$no_manager = @()

#Get all enabled users users
$users = Get-ADuser -Filter {enabled -eq $true} -Properties samaccountname,manager -SearchBase $searchbase

#example of filtering the above.  Pipe to filter OUs.
#Where-Object -FilterScript {$_.DistinguishedName -notlike 'CN=*,OU=External*' -AND $_.DistinguishedName -notlike 'CN=*,OU=*Indirect*' }



foreach($user in $users)
{
#get all users with empty managers
if($user.Manager -eq $null)
    {
    $no_manager += $user
    }


else{
     #else get all users with disabled managers
     $manager = Get-ADUser $user.Manager
     if($manager.Enabled -eq $false)
        {
        $dead_managers += $manager
        $dead_users += $user
        }
    }
}

#get unique value of disabled managers
$disman = $dead_managers.SamAccountName | Select-Object -Unique
#create array with list of users with invalid mangers
$stale_users = @()
$stale_users += "No Manager"
#send user notification to update their manager 
if($no_manager.Count -gt 0){
foreach($no_manager in $no_manager){

$stale_users += "--"+ "$($no_manager.Name)"

$bodynm = "Hi " + $no_manager.Name+ "," + "

You do not currently have a manager specified in our system." +"
This information is used to ensure accurate reports and organization." +"
Please take the time to fill out the Update Your Information form at: URL redacted" +"
You can access this site with your email and computer password."+"

If you need assistance with this, please contact itsupport@contoso.com."


Send-MailMessage -Body $bodynm -Subject "You currently have no manager. Please complete the necessary information." -To $finaluser.mail -From $FromAddress -SmtpServer $SendingServer

}}

#send user notification to update their manager 
if($disman.Count -gt 0){

foreach($disman in $disman){
$manman = Get-ADUser $disman -Properties directreports
$dirrep = $manman.directreports
$stale_users += $manman.name

foreach($dirrep in $dirrep){
$finaluser = Get-ADuser $dirrep -Properties mail
if($finaluser.Enabled -eq $true){
$stale_users += "--"+ "$((get-aduser $dirrep).Name)" 

$bodybm = "Hi " + $finaluser.Name +"," + "

Our system shows that your manager is currently set to: " + $manman.Name + "

However, this person is no longer with the company." +"
This information is used to ensure accurate reports and organization." +"
Please take the time to fill out the Update Your Information form at: URL redacted" +"
You can access this site with your email and computer password."+"

If you need assistance with this, please contact itsupport@contoso.com."

Send-MailMessage -Body $bodybm -Subject "Your current specified manager is invalid. Please update the necessary information." -To $finaluser.mail -From $FromAddress -SmtpServer $SendingServer

}

}}}

#send to it for record keeping, probably better to just make a logfile??
if($stale_users.Count -gt 1)
{
$bodyit = "Hi IT Team, 
The following users have incorrect managers in AD. They have been notified to update their information using the self service form."+"
This is just for record keeping, no action is needed on your part." +"

Users With Invalid Managers: 

" + ($stale_users | Out-String)

Send-MailMessage -Body $bodyit -Subject "Bad Direct Report Report" -To itsupport@contoso.com -From $FromAddress -SmtpServer $SendingServer
}