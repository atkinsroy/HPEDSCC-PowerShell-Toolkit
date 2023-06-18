<#
.SYNOPSIS
    Returns access control records for storage systems accessible to an instance of Data Storage Cloud Console (DSCC).
.DESCRIPTION
    Returns access control records for storage systems accessible to an instance of Data Storage Cloud Console (DSCC).
    You must be logged in with valid credentials to a HPE GreenLake account.
.PARAMETER SystemID
    Accepts one or more System IDs if specified, or shows disks from all storage systems accessible to this 
    HPE GreenLake account.
.PARAMETER SystemName
    Accepts one or more System names if specified, or shows disks from all storage systems accessible to this 
    HPE GreenLake account.
.PARAMETER VolumeId 
    Accepts one or more Volume IDs.
.PARAMETER VolumeName
    Accepts one or more Volume names.
.EXAMPLE
    PS:> Get-DsccAccessControlRecord -SystemId 2M234353456TZ -VolumeId 4d3f2a56e8cfc0bbd58c6654c88710c6

    Displays the access control records for the specified volume(s) on the specified storage system(s).
.EXAMPLE
    PS:> Get-DsccAccessControlRecord -SystemId 2M234353456TZ -VolumeName PRODVOL001,PRODVOL002

    Displays the access control records for the specified volume(s) on the specified storage system(s).
.EXAMPLE
    PS:> Get-DSCCAccessControlRecord

    Displays the access control records for all volumes on every storage system accessible to this HPE GreenLake account.
    This command will take a long time to complete. Consider refining the command to filter on storage system and volume.
.EXAMPLE
    PS:> Get-DsccAccessControlRecord -SystemId 2M234353456TZ,CZ10495643Z

    Displays the access control records for all volumes on each specified storage systems. This command with work, but
    will take a long time to complete. 
.EXAMPLE
    PS:> Get-DSCCAccessControlRecord -VolumeId 9cbb15cb8a45def4d98ca0ba09a1b137,1f1f27f95289872fea4cf2e9e5ef6421

    Displays the access control records for the specified volume(s). This command will work, but is inefficiently checking
    every storage system for the specified volume(s). If known, specify the SystemId or SystemName parameters.
.INPUTS
    DSCC.StorageSystem.Combined.Typename
    String
.OUTPUTS
    DSCC.AccessControlRecord.Typename
.LINK
    https://github.com/HewlettPackard/HPEDSCC-PowerShell-Toolkit
.NOTES
    For device-type1, you cannot filter on "id" using V1 of the storage API, as it appears to change each time you 
    make a call. The Volume Id is not available in the response but volume name is present. 
#>
function Get-DSCCAccessControlRecord { 
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'BySystemId')]
    param (
        # These Paremeter Sets allow optional specification of either SystemId or SystemName along with 
        # optionally either VolumeId or VolumeName. VolumeId by itself works (as its part of default Parameter Set)
        # However, VolumeName by itself fails - not enough information to work out Parameter Set, so SystemId or 
        # SystemName must be specified.
        [Parameter(ValueFromPipeLineByPropertyName, ParameterSetName = 'BySystemId')]
        [Parameter(ValueFromPipeLineByPropertyName, ParameterSetName = 'BySystemIdAndVolumeName')]
        [alias('id')]
        [string[]]$SystemId = (($DsccStorageSystem).Id),

        [Parameter(ParameterSetName = 'BySystemName')]
        [Parameter(ParameterSetName = 'BySystemNameAndVolumeId')]
        [alias('name')]
        [string[]]$SystemName,

        [Parameter(ParameterSetName = 'BySystemId')]
        [Parameter(ParameterSetName = 'BySystemNameAndVolumeId')]
        [string[]]$VolumeId,

        [Parameter(ParameterSetName = 'BySystemName')]
        [Parameter(ParameterSetName = 'BySystemIdAndVolumeName')]
        [string[]]$VolumeName
    )

    begin {
        Write-Verbose 'Executing Get-DsccAccessControlRecord'
        if ($PSBoundParameters.ContainsKey('SystemName')) {
            $SystemId = Resolve-DsccSystemId -SystemName $SystemName
        }
    }
    process {
        foreach ($ThisId in $SystemId) {
            $DeviceType = ($DsccStorageSystem | Where-Object Id -EQ $ThisId).DeviceType
            if (-not $DeviceType) {
                return
            }
            elseif ($DeviceType -eq 'device-type1') {
                # The API is really slow for so filter before calling to minimise the number of calls to the API
                # Also, the json object returned does not have a volume ID in it so we must filter before. Volume 
                # name is there as vol_name, but we rename it to VolumeName for consistency across device types.
                # Note also that the "access-control-record" ID's change with every call (personally, I think this is 
                # busted and should be fixed).
                if ($PSBoundParameters.ContainsKey('VolumeId')) {
                    $AllVolumeId = $VolumeId
                }
                elseif ($PSBoundParameters.ContainsKey('VolumeName')) {
                    $AllVolumeId = (Get-DSCCVolume -SystemId $ThisId -VolumeName $VolumeName).Id
                }
                else {
                    # Default is all volumes for this storage system.
                    $AllVolumeId = (Get-DSCCVolume -SystemId $ThisId).Id
                }
                foreach ($ThisVolumeId in $AllVolumeId) {
                    $UriAdd = "storage-systems/$DeviceType/$ThisId/volumes/$ThisVolumeId/vluns"
                    $Response = Invoke-DsccRestMethod -UriAdd $UriAdd -Method Get -WhatIf:$WhatIfPreference
                    Invoke-RepackageObjectWithType -RawObject $Response -ObjectName 'AccessControlRecord'
                }
            }
            elseif ($DeviceType -eq 'device-type2') {
                $UriAdd = "storage-systems/$DeviceType/$ThisId/access-control-records"
                $Response = Invoke-DsccRestMethod -UriAdd $UriAdd -Method Get -WhatIf:$WhatIfPreference
                if ($PSBoundParameters.ContainsKey('VolumeId') -or $PSBoundParameters.ContainsKey('VolumeId')) {
                    $Response = $Response | Where-Object id -In $AllVolumeId
                }
                Invoke-RepackageObjectWithType -RawObject $Response -ObjectName 'AccessControlRecord'
            }
            else {
                # Additional device types are coming
                Write-Error "Device type of $DeviceType (system $ThisId) is not currently supported"
            }
        } #end foreach
    } # end process
} # end Get-DsccAccessControlRecord

function Remove-DSCCAccessControlRecord {
    <#
.SYNOPSIS
    Removes a HPE DSSC Access Group Record or vLUN mapping 
.DESCRIPTION
    Removes a HPE Data Services Cloud Console Data Operations Manager Access Groups Record or vLUN mapping.
.PARAMETER SystemID
    This parameter is required for both device-type1 and device-type2; A single System ID is specified and required.
.PARAMETER DeviceType1
    This switch is used to tell the command that the end device is the specific device type, and to only allow the correct
    parameter set that matches this device type.
.PARAMETER DeviceType2
    This switch is used to tell the command that the end device is the specific device type, and to only allow the correct
    parameter set that matches this device type.
.PARAMETER volumeId
    This parameter is required for device-type1 systems, and representes a volumeId
.PARAMETER vLunId
    This parameter is required for device-type1 systems, and representes a specific vlun mapping.
.PARAMETER AccessControlRecordID
    This parameter is required for device-type2; A single Access Control Record ID is specified and required.
.PARAMETER WhatIf
    The WhatIf directive will show you the RAW RestAPI call that would be made to DSCC instead of actually sending the request.
    This option is very helpful when trying to understand the inner workings of the native RestAPI calls that DSCC uses.
#>    
    [CmdletBinding()]
    param   (   [Parameter(ParameterSetName = ('type1'), ValueFromPipeLineByPropertyName = $true, Mandatory = $true )]
        [Parameter(ParameterSetName = ('type2'), ValueFromPipeLineByPropertyName = $true, Mandatory = $true )]
        [Alias('id')]   [string]    $SystemId,  
        [Parameter(ParameterSetName = ('type1'))]                     [switch]    $DeviceType1,
        [Parameter(ParameterSetName = ('type2'))]                     [switch]    $DeviceType2,
                                                                        
        [Parameter(ParameterSetName = ('type1'), Mandatory = $true )]    [string]    $volumeId,      
        [Parameter(ParameterSetName = ('type1'), Mandatory = $true )]    [string]    $vLunId,      
        [Parameter(ParameterSetName = ('type2'), Mandatory = $true )]    [string]    $AccessControlRecordId,      
        [switch]    $WhatIf
    )
    process {
        Invoke-DSCCAutoReconnect
        $DeviceType = ( Find-DSCCDeviceTypeFromStorageSystemID -SystemId $SystemId )
        switch ( $devicetype ) {
            'device-type1' {
                $MyAdd = 'storage-systems/' + $DeviceType + '/' + $SystemId + '/volumes/' + $VolumeId + '/vluns/' + $vLunId
                if ( $DeviceType2 ) {
                    Write-Error 'The Wrong Device Type was specified'
                    Return
                }
            }
            'device-type2' {
                $MyAdd = 'storage-systems/' + $DeviceType + '/' + $SystemId + '/access-control-records/' + $AccessControlRecordId
                if ( $DeviceType1 ) {
                    Write-Error 'The Wrong Device Type was specified'
                    Return
                }
            }
        }
        return Invoke-DSCCRestMethod -uriAdd $MyAdd -Method Delete -WhatIfBoolean $WhatIf
    }       
}   
Function New-DSCCAccessControlRecord {
    <#
.SYNOPSIS
    Creates a HPE DSSC Access Group Record or LUN Mapping Record.
.DESCRIPTION
    Creates a HPE Data Services Cloud Console Data Operations Manager Access Group Record or LUN Mapping Record.
.PARAMETER SystemID
    A single System ID is specified and required.
.PARAMETER DeviceType1
    This switch is used to tell the command that the end device is the specific device type, and to only allow the correct
    parameter set that matches this device type.
.PARAMETER DeviceType2
    This switch is used to tell the command that the end device is the specific device type, and to only allow the correct
    parameter set that matches this device type.
.PARAMETER VolId
    A single Volume must be presented for either a device-type1 or device-type2 to be mapped to a set of hosts.
.PARAMETER autoLun
    Only valid for Device-Type1 target systems; Boolean if the volume should autocreate a LUN
.PARAMETER hostGroupIds
    Only valid for Device-Type1 target systems; Either a single or multiple Host Group IDs
.PARAMETER maxAutoLun
    Only valid for Device-Type1 target systems; The maximum number of AutoLuns
.PARAMETER noVcn
    Only valid for Device-Type1 target systems; a boolean if Nvc should be used.
.PARAMETER override
    Only valid for Device-Type1 target systems; will override specific safetys. 
.PARAMETER position
    Only valid for Device-Type1 target systems; will accept a position comment like 'position_1'. 
.PARAMETER applyTo
    Only valid for Device-Type2 target systems; External management agent type. Possible values:'volume', 'pe', 'vvol_volume', 'vvol_snapshot', 'snapshot', 'both'.
.PARAMETER chapUserId
    Only valid for Device-Type2 target systems; Identifier for the CHAP user.
.PARAMETER initiatorGroupId
    Only valid for Device-Type2 target systems; Identifier for the initiator group.
.PARAMETER lun
    Only valid for Device-Type2 target systems;  
    If this access control record applies to a regular volume, this attribute is the volume's LUN (Logical Unit Number). 
    If the access protocol is iSCSI, the LUN will be 0. However, if the access protocol is Fibre Channel, the LUN will 
    be in the range from 0 to 2047. If this record applies to a Virtual Volume, this attribute is the volume's secondary 
    LUN in the range from 0 to 399999, for both iSCSI and Fibre Channel. If the record applies to a OpenstackV2 volume, 
    the LUN will be in the range from 0 to 2047, for both iSCSI and Fibre Channel. If this record applies to a protocol
    endpoint or only a snapshot, this attribute is not meaningful and is set to null.
.PARAMETER pe_id
    Only valid for Device-Type2 target systems; Identifier for the protocol endpoint this access control record applies to.
.PARAMETER pe_ids
    Only valid for Device-Type2 target systems; 
    List of candidate protocol endpoints that may be used to access the Virtual Volume. One of them will be selected 
    for the access control record. This field is required only when creating an access control record for a Virtual Volume.
.PARAMETER snapId
    Only valid for Device-Type2 target systems; Identifier for the snapshot this access control record applies to.   
.PARAMETER WhatIf
    The WhatIf directive will show you the RAW RestAPI call that would be made to DSCC instead of actually sending the request.
    This option is very helpful when trying to understand the inner workings of the native RestAPI calls that DSCC uses.
.LINK
    The API call for this operation is file:///api/v1/storage-systems/{systemid}/device-type1/access-control-records
#>   
    [CmdletBinding()]
    param(  [Parameter(ParameterSetName = ('type1'), ValueFromPipeLineByPropertyName = $true, Mandatory = $true )]
        [Parameter(ParameterSetName = ('type2'), ValueFromPipeLineByPropertyName = $true, Mandatory = $true )]
        [Alias('id')]            [string]    $SystemId, 
        [Parameter(ParameterSetName = ('type1'), mandatory = $true)]  
        [Parameter(ParameterSetName = ('type2'))]             [Alias('VolumeId')]      [string]    $vol_id,
        [Parameter(ParameterSetName = ('type1'))]                                      [switch]    $DeviceType1,
        [Parameter(ParameterSetName = ('type2'))]                                      [switch]    $DeviceType2,
        [Parameter(ParameterSetName = ('type1'))]                                      [string]    $position,
        [Parameter(ParameterSetName = ('type1'))]                                      [boolean]   $autoLun,
        [Parameter(ParameterSetName = ('type1'))]                                      [int]       $maxAutoLun,
        [Parameter(ParameterSetName = ('type1'))]                                      [boolean]   $override,
        [Parameter(ParameterSetName = ('type1'))]                                      [boolean]   $noVcn,
        [Parameter(ParameterSetName = ('type1'))]
        [ValidateSet('PRIMARY', 'SECONDARY', 'ALL')]                                   [string]   $proximity,
        [Parameter(ParameterSetName = ('type1'))]                                      [string[]]  $hostGroupIds,

        [Parameter(ParameterSetName = ('type2'))]                                      [int]       $lun,
        [ValidateSet('volume', 'pe', 'vvol_volume', 'vvol_snapshot', 'snapshot', 'both') ][string]    $applyTo,
        [Parameter(ParameterSetName = ('type2'))]                                      [string]    $chapUserId,
        [Parameter(ParameterSetName = ('type2'))]                                      [string]    $initiatorGroupId,
        [Parameter(ParameterSetName = ('type2'))]                                      [string]    $pe_id,
        [Parameter(ParameterSetName = ('type2'))]                                      [string]    $pe_ids,
        [Parameter(ParameterSetName = ('type2'))]                                      [string]    $snapId,
        [Parameter(ParameterSetName = ('type1'))]
        [Parameter(ParameterSetName = ('type2'))]                                      [boolean]   $WhatIf = $false
    )
    process {
        $DeviceType = ( Find-DSCCDeviceTypeFromStorageSystemID -SystemId $SystemId )
        switch ( $devicetype ) {
            'device-type1' {
                $MyAdd = 'storage-systems/' + $DeviceType + '/' + $SystemId + '/volumes/' + $vol_id + '/export'
                $MyBody = @{}
                if ($autoLun) { $MyBody += @{ autoLun = $autoLun } }
                if ($hostGroupIds) { $MyBody += @{ hostGroupIds = $hostGroupIds } }
                if ($maxAutoLun ) { $MyBody += @{ maxAutoLun = $maxAutoLun } }
                if ($noVcn ) { $MyBody += @{ noVcn = $noVcn } }
                if ($override ) { $MyBody += @{ override = $override } }
                if ($position ) { $MyBody += @{ position = $position } }
                if ($proximity ) { $MyBody += @{ proximity = $proximity } }
                if ( $DeviceType2 ) {
                    Write-Error 'The Wrong Device Type was specified'
                    Return
                }
            }
            'device-type2' {
                $MyAdd = 'storage-systems/' + $devicetype + '/' + $SystemId + '/access-control-records'
                $MyBody = @{}
                if ($applyTo) { $MyBody += @{ apply_to = $applyTo } }
                if ($chapUserId) { $MyBody += @{ chap_user_id = $chapUserId } }
                if ($initiatorGroupId ) { $MyBody += @{ initiator_group_id = $initiatorGroupId } }
                if ($lun ) { $MyBody += @{ lun = $lun } }
                if ($pe_id ) { $MyBody += @{ pe_id = $pe_id } }
                if ($pe_ids ) { $MyBody += @{ pe_ids = $pe_ids } }
                if ($snapId ) { $MyBody += @{ snap_id = $snapId } }
                if ($vol_id ) { $MyBody += @{ vol_id = $vol_id } }
                if ( $DeviceType1 ) {
                    Write-Error 'The Wrong Device Type was specified'
                    Return
                }
            }
        }
        return Invoke-DSCCRestMethod -uriadd $MyAdd -method 'POST' -body ( $MyBody | ConvertTo-Json ) -whatifBoolean $WhatIf
    }      
} 