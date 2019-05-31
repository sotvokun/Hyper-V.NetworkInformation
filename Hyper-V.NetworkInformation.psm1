<#
 .SYNOPSIS
 Gets the IP and MAC address of running VMs.

 .DESCRIPTION
 Gets and displays Hyper-V VMs' IP and MAC address which they are running.

 .Parameter Name
 The IP and MAC address by the specific name of VM.

 .OUTPUTS
 The list of objects about VMs' network information.

 .EXAMPLE
 Get-VMNetworkInformation

 .EXAMPLE
 Get-VMNetworkInformation -Name "vm1"
#>
function Get-VMNetworkInformation()
{
param(
    [string]$Name = ""
)

    $VM_macs = @{}
    $VM_ips = @()
    
    #Get the VMs' mac addresses
    Get-VM | ForEach-Object {
        $mac_wo_line = ($_.NetworkAdapters | Select -ExpandProperty MacAddress).ToLower()
        $a = $mac_wo_line -Split '(\w{2})' | Where  -Property Length -NE 0
        $VM_macs[$_.name]=($a -join "-")
    }
    
    #Get all IPs in LAN by `arp'
    arp -a | ForEach-Object {
        $line = $_
        foreach($i in $VM_macs.GetEnumerator())
        {
            if($line.Contains($i.Value))
            {
                $result = [pscustomobject]@{
                    Name = $i.Key
                    IP = ((-split $line)[0])
                    MACAddress = $i.Value
                }
                $VM_ips += $result
            }
        }
    }

    if($Name.Length -ne 0)
    {
        return ($VM_ips | Where -Property Name -EQ $Name)
    }
    else
    {
        return $VM_ips
    }
}
Export-ModuleMember -Function Get-VMNetworkInformation