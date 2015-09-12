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
			Position=0, 
			Mandatory=$true, 
			ValueFromPipeline=$true)]
		[string]$Server,
		[switch]$Fullscreen,
		[switch]$PromptCred
	)

	begin{
		$arguments = "";
        $cred = null;

		if($Fullscreen){
			$arguments += " /f";
		}
        if($PromptCred){
           $cred = Get-Credential 
        }
	}

	process{
        if($cred)
        {
            LinkServerCred $Server,$cred;
        }
        InvokeMstsc $Server, $arguments;
	}

	end{

	}
}

Function LinkServerCred
{
    param([string]$server, [PSCredential]$cred)
    $username = $cred.UserName;
    $password = $cred.GetNetworkCredential().Password;
    $commandLine = "cmdkey /generic:$server /user:$username /pass:$password";
    Write-Verbose "Adding $username to credential store for $server";
    Write-Verbose "Executing $commandLine"
    #Invoke-Expression $commandLine;
}
Function InvokeMstsc
{   param([string]$server, [string]$args)
	$commandLine = "mstsc.exe /v:$server $args";
	Write-Verbose "Executing $commandLine"
	#Invoke-Expression $commandLine;
}

Export-ModuleMember -function Start-RDP