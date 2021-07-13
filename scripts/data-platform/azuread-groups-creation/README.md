# Data Platform: Azure AD Groups Creation

## Description

Some customers feel more comfortable creating the Azure AD groups required by our Data Platform manually.
We are providing a script that can be used interactively from the Azure Cloud Shell.

## Prerequisites

You must have access to the Azure Cloud Shell and have the necessary permissions to create Azure AD groups.

## Usage

Open the [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)

Run the following command

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ingenii-solutions/public/main/scripts/data-platform/azuread-groups-creation/script.ps1'))
```

Use the interactive menu

![Menu](./files/menu.png)
