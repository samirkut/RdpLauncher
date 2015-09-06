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
		[switch]$Credential
	)

	begin{
		$arguments = "";
		if($Fullscreen){
			$arguments += " /f";
		}
	}

	process{

	}

	end{

	}
}

Function InvokeMstsc([string]$server, [string]$args){
	$commandLine = "mstsc.exe /v:$server $args";
	Write-Verbose "Executing $commandLine"
	Invoke-Expression $commandLine;
}

Export-ModuleMember -function Start-RDP