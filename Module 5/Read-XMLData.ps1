# XML is case sensitive!!!
#
# Parsing Powershell XML Elements with Select-Xml
# An element is an XML portion with an opening tag and a closing tag, possibly with some text in-between, such as <Name>SRV-01</Name>

$FileToParse = "E:\Work\ViaMonstra Online Academy - Course - PowerShell Fundamentals\Module 5\XMLFileWithElements.xml"
Select-Xml -Path $FileToParse -XPath '/Computers/Computer/Name' | ForEach-Object { $_.Node.InnerXML }

# Using PowerShell to Parse XML Attributes with Select-Xml
$FileToParse = "E:\Work\ViaMonstra Online Academy - Course - PowerShell Fundamentals\Module 5\XMLFileWithAttributes.xml"
Select-Xml -Path $FileToParse -XPath '/Computers/Computer' | ForEach-Object { $_.Node.name }

# Using PowerShell to Parse XML Attributes with Select-Xml
$Drivers = "C:\DeploymentShare\Control\Drivers.xml"
Select-Xml -Path $Drivers -XPath '/drivers/driver' | ForEach-Object { $_.Node.guid }
(Select-Xml -Path $Drivers -XPath '/drivers/driver' | ForEach-Object { $_.Node.guid }).count

# Using PowerShell to Parse XML Attributes with Select-Xml
$DriverGroups = "C:\DeploymentShare\Control\DriverGroups.xml"
Select-Xml -Path $DriverGroups -XPath '/groups/group/Member' | ForEach-Object { $_.Node.InnerXML }
(Select-Xml -Path $DriverGroups -XPath '/groups/group/Member' | ForEach-Object { $_.Node.InnerXML }).count
(Select-Xml -Path $DriverGroups -XPath '/drivers/driver' | ForEach-Object { $_.Node.guid }).count
