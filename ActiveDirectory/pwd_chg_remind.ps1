#sends password change reminder emails daily prior to password expiration.

### set environment specific variables here

#LDAP search base DN
$searchbase = "dc=contoso,dc=local"

#Number of days before expiration to begin warning emaisl
$warningdays = 10 

#password expiration time.  This should match your AD policy.  This script does not set that policy.
#Recommend a number divisible by 7 -- ensures that passwords always expire on weekdays if they're reset on weekdays.
$expiration = 105

#DNS address of an smtp server.
$SendingServer = smtp.contoso.local

#email address emails are sent from.  You may get out of office messages to here.
$FromAddress = "Displayname<return@contoso.com>"


####################################################################################################################################################



$days = (Get-Date).adddays($warningdays - $expiration)

$bad_users = Get-ADuser -Filter {enabled -eq $true -AND passwordlastset -le $days} -Properties passwordlastset,mail,passwordexpired -SearchBase $searchbase 

#example of filtering the above.  Pipe to filter OUs.
#Where-Object -FilterScript {$_.DistinguishedName -notlike 'CN=*,OU=External*' -AND $_.DistinguishedName -notlike 'CN=*,OU=*Indirect*' }


#loop all bad users and send them email
foreach($user in $bad_users)
{
    $enddate = Get-Date -Date $user.PasswordLastSet
    $pls = Get-Date -Date $user.PasswordLastSet -Format d
    $dayssince = New-TimeSpan -Start $pls -End (Get-Date)

    $output_mail = "Hi " + $user.GivenName +",

" + 
"You have not changed your password since " + $pls +".
If you do not reset your password by: " + $enddate.AddDays($expiration) +", your account will be locked out." +"

There are two methods to change your password:
    1.	From a company computer, press CTR + ALT + DEL and choose the 'change password' option.
    2.	From any device, visit url redacted" +"
              You can access this site with your email and computer password." +"

If you need assistance with this, please contact xxxxxx."


    $ToAddress = $user.mail
    $MessageSubject = "Your password has not been changed in " +$dayssince.Days +" days. Please change your password before " + $enddate.AddDays($expiration) + " or you will be locked out."
    $SMTPMessage = New-Object System.Net.Mail.MailMessage ($FromAddress,$ToAddress,$MessageSubject,$output_mail)
    $SMTPClient = New-Object System.Net.Mail.SMTPClient $SendingServer
    $SMTPClient.Send($SMTPMessage)

}