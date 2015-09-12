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
		[string]$ComputerName,
        [int]$Width = 0,
        [int]$Height = 0,
		[switch]$Fullscreen,
        [switch]$Console,
        [switch]$Public,
        [switch]$Admin,
        [switch]$Span,
		[switch]$PromptCred
	)

	begin{
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
        if($cred)
        {
           LinkServerCred
        }
        InvokeMstsc;
	}

	end{

	}
}

Function LinkServerCred
{
    $commandLine = "cmdkey.exe /generic:$ComputerName /user:$username /pass:$password";
    Write-Verbose "Adding $username to credential store for $ComputerName";
    #Write-Verbose "Executing $commandLine"
    #Invoke-Expression $commandLine;
}
Function InvokeMstsc
{
	$commandLine = "mstsc.exe /v:$ComputerName $arguments";
	Write-Verbose "Executing $commandLine"
	#Invoke-Expression $commandLine;
}

New-Alias -Name "rdp" -Value "Start-RDP"

Export-ModuleMember -function Start-RDP -Alias rdp