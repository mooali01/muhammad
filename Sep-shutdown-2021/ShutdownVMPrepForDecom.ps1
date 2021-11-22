################################################################################
#                                                                              #
# PostXX_ShutdownVMPrepForDecom.ps1                                            #
# v0.2 - 2019/08/26                                                            #
# Required Field in CSV:  vCenter                                              #
# Required Field in CSV:  ShutdownVMName (no extra spaces in name)             #
# Required Field in CSV:  RFC                                                  #
# Script must connect to a vCenter server - use corp\username format           #
#                                                                              #
################################################################################
#  Example Syntax:
#    Connect-VIServer p01napv-fvctr01.lplfinancial.com
#    Connect-VIServer txvcenterdev01.corp.lpl.com
#    F:\Powershell\DeployVMScripts\P00NSVW-DSTFS01.csv
#    Invoke-Command -Computer "P00NSVW-DSTFS01" -ScriptBlock {Add-LocalGroupMember -Group Administrators -Member  "CORP\LPLSQLPD_30" "CORP\SQLAdmin" "CORP\TFSAdministrators" "CORP\tfssystem" "NCPROD\CYB_SYS_ALPHA" "NCPROD\Domain Admins" "NCPROD\SQLAdmin" "NCPROD\WinAdmin_Service_Accounts"}
#    \\Client\F$\Powershell\DeployVMScripts\Q00NSVW-DESIG01.csv
#    \\Client\F$\Powershell\DeployVMScripts\P00NSVW-DESIG01rw.csv
#    F:\Powershell\DeployVMScripts\VMNoteAndShutdownTest.csv
#    F:\Powershell\DeployVMScripts\VMNoteAndShutdownProdC1900002566.csv
#    F:\Powershell\DeployVMScripts\VMNoteAndShutdownShutdownSept202019.csv
#    F:\Powershell\DeployVMScripts\VMNoteAndShutdownShutdownSept202019Prod.csv
#    F:\Powershell\DeployVMScripts\QA4ShutdownVMs.csv
#    $ServerList = $null
#

# Clear the vCenter credentials
$Username = $null
$password = $null

# Get Credentials for vCenter - use corp\username format
    If ($Username -eq $null){$Username = Read-Host -Prompt "vCenter Username Format - corp\username"}
    If ($Password -eq $null){$Password = Read-Host -Prompt "Please enter your Password:" –AsSecureString}

# Populate the list of servers to build from the CSV file and prompt if the variable is empty
If ($ServerList -eq $null){
    $Global:ServerList = Read-Host -Prompt 'Please input the full path to the .csv file'
    $oldVMs = import-csv $ServerList
}
Else{
    $oldVMs = import-csv $ServerList
}


# Convert vCenter code from the .csv to a real vCenter name
foreach ($vm in $oldVMs)
{
    If ($vm.vCenter -like "vc01"){
        $vc = "p01napv-fvctr01.lplfinancial.com"
    }
    ElseIf ($vm.vCenter -like "vc02"){
        $vc = "p02napv-fvctr01.lplfinancial.com"
    }
    ElseIf ($vm.vCenter -like "txprd"){
        $vc = "txvcenterprd01.corp.lpl.com"
    }
    ElseIf ($vm.vCenter -like "txdev"){
        $vc = "txvcenterdev01.corp.lpl.com"
    }
    ElseIf ($vm.vCenter -like "qpf"){
        $vc = "p01napv-fvctr03.corp.lpl.com"
    }
    Else{
        $vc = "Undefined"
    }


# Get Credentials for vCenter - use corp\username format
    If ($Username -eq $null){$Username = Read-Host -Prompt "vCenter Username Format - corp\username"}
    If ($Password -eq $null){$Password = Read-Host -Prompt "Please enter your Password:" –AsSecureString}

    
# Check for correct vCenter listed in the .CSV file
        Connect-VIServer $vc -User $Username -Password ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))) > null
                $Exists = get-vm -name $vm.ShutdownVMName -ErrorAction SilentlyContinue  
                If ($Exists){  
                    Write-host $vm.ShutdownVMName " VM is on vCenter "  $vc
                    $toolsStatus = (Get-VM $vm.ShutdownVMName | Get-View).Guest.ToolsStatus
                    if ($toolsStatus -like "toolsNotInstalled"){Write-Host "VMware" $toolsStatus "on host.  Power Off required for host" $vm.ShutdownVMName -ForegroundColor Yellow}
                    <#Get-View -ViewType VirtualMachine -Filter @{'Name'=$vm.ShutdownVMName} |
                    Select Name,
                        @{N="HW Version";E={$_.Config.version}},
                        @{N='VMware Toos Status';E={$_.Guest.ToolsStatus}},
                        @{N="VMware Tools version";E={$_.Config.Tools.ToolsVersion}}
                        #>
                            }  
                Else{  
                    Write-Host -ForegroundColor Blue; Write-Host "VM " -ForegroundColor Green -NoNewLine; Write-Host $vm.ShutdownVMName -ForegroundColor Yellow -NoNewLine; Write-Host " not found on vCenter " -ForegroundColor Green -NoNewLine; Write-Host $vc -ForegroundColor Yellow -NoNewLine; Write-Host " using vCenter code " -ForegroundColor Green -NoNewLine; Write-Host $vm.vCenter -ForegroundColor Yellow -NoNewLine; Write-Host "." -ForegroundColor Green  
                    Write-Host "Attempting to locate the VM"
                    Connect-VIServer txvcenterprd01.corp.lpl.com -User $Username -Password ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))
                    $Exists2 = get-vm -name $vm.ShutdownVMName -ErrorAction SilentlyContinue 
                    If ($Exists2){Write-Host " Found on vCenter " -ForegroundColor Green -NoNewLine; Write-Host $vc -ForegroundColor Yellow -NoNewLine; Write-Host " vCenter code - txprd"}  
                        Else{  
                            Connect-VIServer p01napv-fvctr01.lplfinancial.com -User $Username -Password ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))
                            $Exists3 = get-vm -name $vm.ShutdownVMName -ErrorAction SilentlyContinue
                            If ($Exists3){Write-Host " Found on vCenter " -ForegroundColor Green -NoNewLine; Write-Host $vc -ForegroundColor Yellow -NoNewLine; Write-Host " vCenter code - vc01"}  
                            Else{  
                                Connect-VIServer p02napv-fvctr01.lplfinancial.com -User $Username -Password ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))
                                $Exists4 = get-vm -name $vm.ShutdownVMName -ErrorAction SilentlyContinue
                                If ($Exists4){Write-Host " Found on vCenter " -ForegroundColor Green -NoNewLine; Write-Host $vc -ForegroundColor Yellow -NoNewLine; Write-Host " vCenter code - vc02"}  
                                Else{  
                                    Connect-VIServer txvcenterdev01.corp.lpl.com -User $Username -Password ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))
                                    $Exists5 = get-vm -name $vm.ShutdownVMName -ErrorAction SilentlyContinue
                                    If ($Exists5){Write-Host " Found on vCenter " -ForegroundColor Green -NoNewLine; Write-Host $vc -ForegroundColor Yellow -NoNewLine; Write-Host " vCenter code - txdev"}  
                                    Else{  
                                        Connect-VIServer p01napv-fvctr03.corp.lpl.com -User $Username -Password ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))
                                        $Exists6 = get-vm -name $vm.ShutdownVMName -ErrorAction SilentlyContinue
                                        If ($Exists6){Write-Host " Found on vCenter " -ForegroundColor Green -NoNewLine; Write-Host $vc -ForegroundColor Yellow -NoNewLine; Write-Host " vCenter code - qpf"}  
                                        Else{ 
                                            } 
                                        }    
                                    }
                                }         
                            } 
                        }
                   } 
#>


# Poweroff VMs on specific vCenter per the CSV file
Write-Host "Press Cntl-C to stop or Enter to continue and power off the VMs"
pause
  foreach ($vm in $oldVMs)
    {
    If ($vm.vCenter -like "vc01"){
            $vc = "p01napv-fvctr01.lplfinancial.com"
    }
    ElseIf ($vm.vCenter -like "vc02"){
        $vc = "p02napv-fvctr01.lplfinancial.com"
    }
    ElseIf ($vm.vCenter -like "txprd"){
        $vc = "txvcenterprd01.corp.lpl.com"
    }
    ElseIf ($vm.vCenter -like "txdev"){
        $vc = "txvcenterdev01.corp.lpl.com"
    }
    ElseIf ($vm.vCenter -like "qpf"){
        $vc = "p01napv-fvctr03.corp.lpl.com"
    }
    Else{
        $vc = "Undefined"
    }
 

     # Connect to vCenter     
       Connect-VIServer $vc -User $Username -Password ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))) > null
        $ShutdownDate = Get-Date
        $RFCCode = $vm.RFC
        $note = "VM has been Shutdown by IA team on $ShutdownDate - Reference RFC $RFCCode"
        #Write-Host -ForegroundColor Blue; Write-Host "Notating and powering off VM " -ForegroundColor Green -NoNewLine; Write-Host $vm.ShutdownVMName -ForegroundColor Yellow -NoNewLine; Write-Host " on vCenter " -ForegroundColor Green -NoNewLine; Write-Host $vc -ForegroundColor Yellow -NoNewLine; Write-Host " from vCenter code " -ForegroundColor Green -NoNewLine; Write-Host $vm.vCenter -ForegroundColor Yellow -NoNewLine; Write-Host "." -ForegroundColor Green
                
    # Update the VMware Notes
        Set-VM -VM $vm.ShutdownVMName -Description $note -Confirm:$false;

    # Shutdown the VMware Server
       $toolsStatus = (Get-VM $vm.ShutdownVMName | Get-View).Guest.ToolsStatus
       if ($toolsStatus -like "toolsNotInstalled"){Stop-VM -VM $vm.ShutdownVMName -Confirm:$false}
       Else {Get-VM $vm.ShutdownVMName | Shutdown-VMGuest -confirm:$false | Out-Null}
 }
 #>




Write-Host "****************************************************************"
Write-Host "Waiting for power off - VM power state checks will begin shortly"
Write-Host "****************************************************************"
Sleep 60
#Check power state after script run
foreach ($vm in $oldVMs)
{
    If ($vm.vCenter -like "vc01"){
            $vc = "p01napv-fvctr01.lplfinancial.com"
    }
    ElseIf ($vm.vCenter -like "vc02"){
        $vc = "p02napv-fvctr01.lplfinancial.com"
    }
    ElseIf ($vm.vCenter -like "txprd"){
        $vc = "txvcenterprd01.corp.lpl.com"
    }
    ElseIf ($vm.vCenter -like "txdev"){
        $vc = "txvcenterdev01.corp.lpl.com"
    }
    ElseIf ($vm.vCenter -like "qpf"){
        $vc = "p01napv-fvctr03.corp.lpl.com"
    }
    Else{
        $vc = "Undefined"
    }
    # Final check - Connect to vCenter and get Power State     
        Connect-VIServer $vc -User $Username -Password ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))) | Out-Null
        Get-VM -Name $vm.ShutdownVMName | select PowerState, Name | ft -HideTableHeaders
}

#Clear hash variable for extra security
$Username = $null
$password = $null


#>

################################################################################
#                                                                              #
# Version Control / Code Backup                                                #
#                                                                              #
################################################################################

<#
#                                                                              #
# This line is the path to the CSV containing the build information            #
#                                                                              #
# Declare the parameter to import the CSV file.  Must be a full path           #
# param (                                                                      #
#    [Parameter(Mandatory=$true)][string]$ShutdownVMName                       #
#                                                                              #


#>