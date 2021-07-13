#----------------------------------------------------------------------------------------------------------------------
# Ingenii LLC 2021
# Author: Teodor Kostadinov
#
# Description:
# The script provides an interactive way to create the pre-requisite Azure AD Groups required for Ingenii Data Platform.
#
# How To Use:
# Ideally you should copy and paste it to an Azure Shell and follow the menu prompts.
#----------------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------------
# DEFAULT GROUPS AND ENVIRONMENTS
#----------------------------------------------------------------------------------------------------------------------
# The default Azure AD Groups required by the Data Platform.
$defaultAzureADGroups = @(
    "Engineers",
    "Analysts",
    "Admins"
)

# The default Deployment Environments used by the Data Platform.
$defaultEnvironments = @(
    "Shared",
    "Dev",
    "Test",
    "Prod"
)


#----------------------------------------------------------------------------------------------------------------------
# FUNCTIONS
#----------------------------------------------------------------------------------------------------------------------
function New-IIAzureADGroup {
    param(
        [string]$Prefix,
        [string]$Environment,
        [string]$GroupName,
        [switch]$DryRun
    )

    if ($DryRun) {
        Write-Host "[DRYRUN] New-AzureADGroup -DisplayName "$Prefix-$Environment-$GroupName" -MailEnabled $false -SecurityEnabled $true -MailNickName 'NotSet'"
    }
    else {
        New-AzureADGroup -DisplayName "$Prefix-$Environment-$GroupName" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet" | Select-Object ObjectId, DisplayName
    }
}

function Test-IIAzureADGroupExists {
    param(
        [string]$Prefix,
        [string]$Environment,
        [string]$GroupName
    )

    $result = Get-AzureADGroup -SearchString "$Prefix-$Environment-$GroupName"

    if ($result) {
        $true
    }
    else {
        $false
    }
}

function New-IIDefaultAzureADGroups {
    param(
        [string]$Prefix,
        [array]$GroupsList,
        [array]$EnvironmentsList,
        [switch]$DryRun
    )

    foreach ($GroupName in $GroupsList) {
        foreach ($Environment in $EnvironmentsList) {
            if ($DryRun) {
                New-IIAzureADGroup -Prefix $Prefix -GroupName $GroupName -Environment $Environment -DryRun
            }
            else {
                New-IIAzureADGroup -Prefix $Prefix -GroupName $GroupName -Environment $Environment
            }
        }
    }
}

function Test-IIDefaultAzureADGroupsExist {
    param(
        [string]$Prefix,
        [array]$GroupsList,
        [array]$EnvironmentsList
    )

    foreach ($GroupName in $GroupsList) {
        foreach ($Environment in $EnvironmentsList) {
            $result = Test-IIAzureADGroupExists -GroupName $GroupName -Environment $Environment -Prefix $Prefix

            if ($result) {
                Write-Host An Azure AD Group with the name $Prefix-$Environment-$GroupName already exist in your Azure Active Directory -ForegroundColor Yellow
            } 
            else {
                Write-Host $Prefix-$Environment-$GroupName group name is available in your Azure Active Directory -ForegroundColor Green
            }
        }
    }
}

function Show-Menu {
    param(
        [string]$Prefix
    )

    Clear-Host
    Write-Host "==================================================="
    Write-Host "#### ##    ##  ######   ######## ##    ## #### ####"
    Write-Host " ##  ###   ## ##    ##  ##       ###   ##  ##   ##"
    Write-Host " ##  ####  ## ##        ##       ####  ##  ##   ##"
    Write-Host " ##  ## ## ## ##   #### ######   ## ## ##  ##   ##"  
    Write-Host " ##  ##  #### ##    ##  ##       ##  ####  ##   ##"  
    Write-Host " ##  ##   ### ##    ##  ##       ##   ###  ##   ##" 
    Write-Host "#### ##    ##  ######   ######## ##    ## #### ####"
    Write-Host "==================================================="
    Write-Host
    Write-Host "The Ingenii Data Platform requires specific Azure AD Groups for Role Based Access Control."
    Write-Host "Use this menu to review and create those groups in your Azure Active Directory."
    Write-Host
    Write-Host "Make sure to review the default name prefix and change it to fit your needs."
    Write-Host
    Write-Host "Current name prefix: $Prefix"
    Write-Host
    Write-Host "Example Group Names:"
    Write-Host "- $Prefix-Shared-Engineers"
    Write-Host "- $Prefix-Dev-Analysts"
    Write-Host "- $Prefix-Test-Admins"
    Write-Host
    Write-Host "Menu"
    Write-Host "1: Press '1' to change the name prefix"
    Write-Host "2: Press '2' to check the group name availability"
    Write-Host "3: Press '3' to create the Azure AD Groups (confirmation required)"
    Write-Host "Q: Press 'Q' to quit."
}

#----------------------------------------------------------------------------------------------------------------------
# MAIN
#----------------------------------------------------------------------------------------------------------------------

# Connect to Azure AD
Connect-AzureAD

# Set default Group Name prefix
$Prefix = "ADP"

# Show the interactive menu
do {
    Show-Menu -Prefix $Prefix

    $selection = Read-Host "Please make a selection"

    switch ($selection) {
        '1' { 
            $Prefix = Read-Host "Please enter the new prefix. (All capitals recommended)"
        } 
        '2' { 
            Test-IIDefaultAzureADGroupsExist -Prefix $Prefix -GroupsList $defaultAzureADGroups -EnvironmentsList $defaultEnvironments

            Write-Host "Press Enter to continue"
            Read-Host
        } 
        '3' {
            Write-Host The following commands will be executed:
            
            New-IIDefaultAzureADGroups -Prefix $Prefix -GroupsList $defaultAzureADGroups -EnvironmentsList $defaultEnvironments -DryRun

            do {
                $answer = Read-Host "Do you want to proceed? (y/n)"
            } until ($answer -eq "n" -or $answer -eq "y")

            if ($answer -eq "y") {
                New-IIDefaultAzureADGroups -Prefix $Prefix -GroupsList $defaultAzureADGroups -EnvironmentsList $defaultEnvironments
                
                Write-Host
                Write-Host "Please copy this table and send it back to the Ingenii engineer.`n" -ForegroundColor Yellow
            }

            Write-Host "Press Enter to continue"
            Read-Host
        }
    }
}
until ($selection -eq 'q')