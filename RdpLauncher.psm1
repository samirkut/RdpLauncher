<#
.Synopsis
Launch RDP sessions from powershell

.Description
Launch RDP session from powershell. This module supports launching sessions to multiple computers, using stored credentials as well as provide an autocomplete for server addresses and aliases from an xml config file

.Parameter Server
The server address or alias to connect to


#>

Function Start-RDP {
	[cmdletbinding()]
	param(
        [Parameter(
			Position=1, 
			Mandatory=$false, 
			ValueFromPipeline=$true)]
        [string]$ComputerName,
        [int]$Width = 0,
        [int]$Height = 0,
		[switch]$Fullscreen,
        [switch]$Console,
        [switch]$Public,
        [switch]$Admin,
        [switch]$Span,
        [switch]$MultiMon,
		[switch]$PromptCred
	)

    dynamicparam{
        # Set the dynamic parameters' name
        $ParameterName = 'Search';
            
        # Create the dictionary 
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary;

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute];
            
        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute;
        $ParameterAttribute.Mandatory = $false;
        $ParameterAttribute.Position = 0;
        $ParameterAttribute.ValueFromPipeline = $false;

        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute);

        # Generate and set the ValidateSet 
        $serverAliases = GetServerAliases
        $arrSet = @();
        foreach($serverName in $serverAliases.Keys){
            $arrSet += $serverName;
            foreach($alias in $serverAliases[$serverName]){
                $arrSet += $alias;
            }
        }
        $arrSet = $arrSet | Select-Object -Unique
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet);

        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute);

        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection);
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter);
        return $RuntimeParameterDictionary;
    }

	begin{
        $SearchComputerName = $PsBoundParameters[$ParameterName];
		$arguments = "";
        $username = "";
        $password = "";

        if($Width -ne 0 -and $Height -ne 0){
            $arguments += " /w:$Width /h:$Height";
        }
		if($Fullscreen){
			$arguments += " /f";
		}
        if($Console){
            $arguments += " /console";
        }
        if($Admin){
            $arguments += " /admin";
        }
        if($Span){
            $arguments += " /span";
        }
        if($MultiMon){
            $arguments += " /multimon";
        }
        if($Public){
            $arguments += " /public";
        }
        if($PromptCred){
           $cred = Get-Credential 
           $netCred = $cred.GetNetworkCredential();
           $username = $cred.UserName;
           $password = $netCred.Password;
        }
	}

	process{        
        if(-not [string]::IsNullOrWhiteSpace($ComputerName))
        {
            LaunchRdp $ComputerName;
        }
	}

	end{
        if(-not [string]::IsNullOrWhiteSpace($SearchComputerName)){
            #convert this to computername and run
            $serverAliases = GetServerAliases
            foreach($serverName in $serverAliases.Keys){
                if($serverName -eq $SearchComputerName){
                    LaunchRdp $serverName;
                }
                foreach($alias in $serverAliases[$serverName]){
                    if($alias -eq $SearchComputerName){
                        LaunchRdp $serverName
                    }
                 }
            }                
        }
	}
}

Function LaunchRdp([string]$server)
{
    if($cred)
    {
        LinkServerCred $server
    }
    InvokeMstsc $server;
}

Function LinkServerCred([string]$server)
{
    if ($server.Contains(':')) {
        $ComputerCmdkey = ($server -split ':')[0];
    } else {
        $ComputerCmdkey = $server;
    }

    $commandLine = "cmdkey.exe /generic:$ComputerCmdkey /user:$username /pass:$password";
    Write-Verbose "Adding $username to credential store for $ComputerCmdkey";
    Write-Verbose "Executing $commandLine"
    #Invoke-Expression $commandLine;
}
Function InvokeMstsc([string]$server)
{
	$commandLine = "mstsc.exe /v:$server $arguments";
	Write-Verbose "Executing $commandLine"
	#Invoke-Expression $commandLine;
}
Function GetServerAliases
{
    $fileName = "$env:HOMEPATH\rdplist.xml";
    if(-not (Test-Path $fileName)){
        #create an empty file
        $defaultXml = 
@"
<servers>
    <server name='localhost'>
        <alias>local</alias>
        <alias>ThisPC</alias>
    </server>
</servers>
"@;
        Set-Content $fileName -Value $defaultXml;
        Write-Verbose "Created $fileName with default content."
    }
    $ret = @{};
    [xml]$xmlDoc = Get-Content $fileName;
    foreach($server in $xml.servers.server)
    {
        if([string]::IsNullOrWhiteSpace($server.Name)){
            continue;
        }
        $aliases = @();
        foreach($alias in $server.ChildNodes){
            $aliases += $alias.InnerText;
        }
        $ret.Add($server.Name, $aliases);
    }
    return $ret;
}

#New-Alias -Name "rdp" -Value "Start-RDP"

#Export-ModuleMember -function Start-RDP -Alias rdp