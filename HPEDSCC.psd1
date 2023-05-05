#
# Module manifest for module 'HPEDSCC'
#
# Generated by: HPE Services
#
# Generated on: 4/05/2023
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'HPEDSCC.psm1'

    # Version number of this module.
    ModuleVersion        = '1.0.1'

    # Supported PSEditions
    CompatiblePSEditions = 'Desktop', 'Core'

    # ID used to uniquely identify this module
    GUID                 = '106caea9-7796-4a2d-9ef7-ad5f5348c4cf'

    # Author of this module
    Author               = 'HPE Services'

    # Company or vendor of this module
    CompanyName          = 'Hewlett Packard Enterprise'

    # Copyright statement for this module
    Copyright            = '(C) Copyright 2023 Hewlett Packard Enterprise Development L.P. Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'

    # Description of the functionality provided by this module
    Description          = 'The HPE GreenLake Data Storage Cloud Console (DSCC) PowerShell Module provides the ability to monitor and manage your on-premise HPE GreenLake storage infrastructure via the provided REST API.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess     = 'HPEDSCC.Format.ps1xml'

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = 'Connect-DSCC', 'Get-DSCCAuditEvent', 'Get-DSCCAccessControl', 
    'Get-DSCCResourceType', 'Get-DSCCController', 
    'Get-DSCCControllerPerf', 'Get-DSCCControllerSubComponent', 
    'Invoke-DSCCControllerLocatePCBM', 'Get-DSCCAccessControlRecord', 
    'Remove-DSCCAccessControlRecord', 'New-DSCCAccessControlRecord', 
    'Get-DSCCVolumeSet', 'Remove-DSCCVolumeSet', 'Set-DSCCVolumeSet', 
    'New-DSCCVolumeSet', 'Get-DSCCHostVolume', 'Get-DSCCHostGroup', 
    'Remove-DSCCHostGroup', 'Set-DSCCHostGroup', 'New-DSCCHostGroup', 
    'Get-DSCCHost', 'Remove-DSCCHost', 'Set-DSCCHost', 'New-DSCCHost', 
    'Get-DSCCInitiator', 'Remove-DSCCInitiator', 'New-DSCCInitiator', 
    'Get-DsccStorageSystem', 'Enable-DsccStorageSystemLocate', 
    'Disable-DsccStorageSystemLocate', 'Get-DSCCPool', 'Get-DSCCFolder', 
    'Get-DSCCPoolVolume', 'Get-DSCCVolume', 'Remove-DSCCVolume', 
    'Set-DSCCVolume', 'New-DSCCVolume', 'Get-DSCCVolumePerf', 
    'Get-DSCCSnapshot', 'Remove-DSCCSnapshot', 'New-DSCCSnapshot', 
    'Get-DSCCComponentPerfStats', 'Get-DSCCPort', 'Get-DsccDisk', 
    'Get-DsccEnclosure', 'Invoke-DSCCShelfLocate', 'Get-DSCCCertificate', 
    'Find-DSCCDeviceTypeFromStorageSystemID', 
    'Invoke-RepackageObjectWithType', 'Invoke-DSCCAutoReconnect'

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    # VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = 'Get-DsccShelf'

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = 'Hewlett', 'Packard', 'Enterprise', 'HPE', 'DSCC', 'Storage', 'Cloud', 'REST', 
            'RESTAPI', 'Data Storage', 'Cloud Console'

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/HewlettPackard/HPEDSCC-PowerShell-ToolKit'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

