Function Get-Uptime {
    <#
    .SYNOPSIS
        Get's uptime for a server
    .DESCRIPTION
        Retrieve uptime information for a server or servers.  Input can come from text files, input or
        cmdlet.
    .PARAMETER Name
        Name of the computer you want to get the uptime information from
    .INPUTS
        Name property
    .OUTPUTS
        PSCustomObject
            Name                [string]
            LastBootTime        [datetime]
            RebootSince         [timespan]
        
    .EXAMPLE
        .\Get-Uptime.ps1 -Name corpdc101
    
        Retrieve the uptime informatoin for corpdc101
    
    .EXAMPLE
        .\Get-Uptime.ps1 -Name (Get-Content .\servers.txt)
        Get-Content .\servers.txt | .\Get-Uptime.ps1
    
        Get uptime information for all the servers listed in servers.txt
    
    .EXAMPLE
        Get-ADComputer -Filter {name -like *DC*} | .\Get-Uptime.ps1
    
        Get uptime information for all computers in the domain that have DC in them somewhere.
    
    .NOTES
        Author:             Martin Pugh
        Date:               9/19/2014
      
        Changelog:
            9/19/14         MLP - Initial Release
            7/17/15         MLP - Added default to local computer
            4/17/16         MLP - Changed to using Get-CimInstance, changed to PSCustomObject and updated LastBootUpTime which is now a 
                                  date/time object instead of FileTime
    .LINK
        https://github.com/martin9700/Surly.PowerShell.Tools
    #>
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [Alias("ComputerName")]
	    [string[]]$Name = $env:COMPUTERNAME
    )
    Process {
        ForEach ($Computer in $Name)
        {   Write-Verbose "Checking Host: $Computer"
            Try {
                #LastBootUpTime
                $LastBoot = Get-WQLQuery -ComputerName $Computer -Query "SELECT LastBootUpTime FROM Win32_OperatingSystem" -ErrorAction Stop
            }
            Catch {
                Write-Error "Unable to get LastBootTime from $Computer because ""$($_)"""
                Continue
            }
            
            [PSCustomObject]@{
                Name = $Computer
                LastBootTime = $Lastboot.LastBootUpTime
                RebootSince = New-TimeSpan -Start $Lastboot.LastBootUpTime -End (Get-Date)
            }
        }
    }
}
