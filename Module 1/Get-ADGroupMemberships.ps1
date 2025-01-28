
$GroupName = "Domain Users" 
Get-ADGroupMember -Identity $GroupName

# Recursive
Get-ADGroupMember -Identity $GroupName -Recursive


# Get only the users from a group
Get-ADGroupMember -Identity $GroupName | Where-Object {$_.objectClass -eq "user"} | ft

# Or get only the nested groups
Get-ADGroupMember -Identity $GroupName | Where-Object {$_.objectClass -eq "group"} | ft


Get-ADGroupMember -Identity $GroupName | Get-ADUser -Properties DisplayName,EmailAddress | Select Name,DisplayName,EmailAddress,SAMAccountName