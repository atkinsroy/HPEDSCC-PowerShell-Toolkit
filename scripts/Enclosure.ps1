<#
.SYNOPSIS
    Returns the enclosures (disk shelves) of storage systems accessible to an instance of 
    HPE GreenLake Data Storage Cloud Console (DSCC).
.DESCRIPTION
    Returns the enclosures (disk shelves) of storage systems accessible to an instance of 
    HPE GreenLake Data Storage Cloud Console (DSCC).
    You must be logged in with valid credentials to a HPE GreenLake account.
.PARAMETER SystemID
    Accepts one or more System IDs if specified, or shows all storage systems accessible to this HPE GreenLake account.
.PARAMETER SystemName
    Accepts one or more System names if specified, or shows all storage systems accessible to this HPE GreenLake account.
.EXAMPLE
    PS:> Get-DsccStorageSystem -DeviceType device-type1 | Get-DsccShelf

    Display enclosure information for all device-type1 storage systems (HPE Alletra 9000, HPE Primera, HPE 3PAR) 
    accessible to this instance of DSCC.
.EXAMPLE
    PS:> Get-DsccStorageSystem -DeviceType device-type2 | Get-DsccEnclosure

    Display enclosure information for all device-type2 storage systems (HPE Alletra 6000 and 5000) accessible to this 
    instance of DSCC.
.EXAMPLE
    PS:> Get-DsccEnclosure -SystemId 000849204632ec0d70000000000000000000000001

    Display enclosure information for the specified device-type2 storage system.
.EXAMPLE
    PS:>Get-DsccStorageSystem | Get-DsccShelf

    Displays enclosure information for all storage systems accessible to this instance of DSCC. Get-DsccShelf is
    an alias for Get-DsccEnclosure.
.OUTPUTS
    Returns objects of type DSCC.Shelf.Combined, made up of storage systems with device type 1 and 2. There 
    are some common properties between them but not all properties are common
.LINK
    https://github.com/HewlettPackard/HPEDSCC-PowerShell-Toolkit
#>
function Get-DsccEnclosure { 
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'BySystemId')]
    [alias('Get-DsccShelf')]
    param (
        [Parameter(ValueFromPipeLineByPropertyName, ParameterSetName = 'BySystemId')]
        [alias('id')]
        [string[]]$SystemId = (($DsccStorageSystem).Id),

        [Parameter(ParameterSetName = 'BySystemName')]
        [alias('name')]
        [string[]]$SystemName,

        [alias('ShelfId')]
        [string[]]$EnclosureId
    )

    begin {
        Write-Verbose 'Executing Get-DsccEnclosure'
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
            elseif ( $DeviceType -eq 'Device-Type1') {
                $UriAdd = "storage-systems/$DeviceType/$ThisId/enclosures"
            }
            elseif ( $DeviceType -eq 'Device-Type2' ) {
                $UriAdd = "storage-systems/$DeviceType/$ThisId/shelves"
            }
            else {
                # Additional device types are coming
                Write-Error "Device type of $DeviceType (system $ThisId) is not currently supported"
            }

            $Response = Invoke-DSCCRestMethod -UriAdd $UriAdd -Method Get -WhatIf:$WhatIfPreference
            if ($PSBoundParameters.ContainsKey('EnclosureId')) {
                $Response = $Response | Where-Object id -In $EnclosureId
            }

            Invoke-RepackageObjectWithType -RawObject $Response -ObjectName 'Shelf.Combined'
        }
    } #end process
} # end Get-DsccEnclosure

function Invoke-DSCCShelfLocate {
    <#
.SYNOPSIS
    Initiates the HPE DSSC DOM Storage Systems Beacon for a specific Storage System    
.DESCRIPTION
    Initiates the HPE Data Services Cloud Console Data Operations Manager Systems Beacon for a specific Storage System
.PARAMETER StorageSystemID
    The single storage systems beacon light will be illuminated
.PARAMETER ShelfID
    The ID for the beacon light will be illuminated
.PARAMETER CId
    The Controller ID for the LED to illuminate, either A or B
.PARAMETER Status
    The status that the light should be set to, either on ($True) or off ($False)
.PARAMETER WhatIf
    The WhatIf directive will show you the RAW RestAPI call that would be made to DSCC instead of actually sending the request.
    This option is very helpful when trying to understand the inner workings of the native RestAPI calls that DSCC uses.
.EXAMPLE
    PS:> Invoke-DSCCShelfLocate -StorageSystemId 2M234353456TZ -ShelfId 23980342789432789 -CId A -status $True

.EXAMPLE
    PS:> Invoke-DSCCShelfLocate -StorageSystemId 2M2134T112Z -ShelfId 122342234 -CId A -Status $True -WhatIf
    
    WARNING: You have selected the What-IF option, so the call will note be made to the array,
    instead you will see a preview of the RestAPI call

    The URI for this call will be
        https://scalpha-app.qa.cds.hpe.com/api/v1/storage-systems/device-type2/2M2134T112Z/shelves/122342234/action/locate
    The Method of this call will be
        Post
    The Header for this call will be :
        {   "Authorization":  "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IlhwRUVZUGlZWDVkV1JTeDR4SmpNcEVPc1hTSSIsInBpLmF0bSI6ImRlejAifQ.eyJjbGllbnRfaWQiOiIzZjIwODU4NS0zZGE2LTRiZjctOTRjYS00ZjMxMGQwOTYzYjUiLCJpc3MiOiJodHRwczovL3Nzby5jb21tb24uY2xvdWQuaHBlLmNvbSIsImF1ZCI6ImV4dGVybmFsX2FwaSIsInN1YiI6ImNocmlzLmxpb25ldHRpQGhwZS5jb20iLCJ1c2VyX2N0eCI6IjAwNTZiNzFlZWZjNDExZWJhMjY4NjJhZGI4NzdjMmQ4IiwiYXV0aF9zb3VyY2UiOiJjY3NfdG9rZW5fbWFuYWdlbWVudCIsInBsYXRmb3JtX2N1c3RvbWVyX2lkIjoiOGZmYzRiN2VlOWQyMTFlYjhjZWU2ZTEzYzA3MWVhMzciLCJpYXQiOjE2MzYwNzU2NjQsImFwcGxpY2F0aW9uX2luc3RhbmNlX2lkIjoiM2MxOGJkMDMtODMwNi00YzdjLTk0MmUtYzcwNGE0Yjg3NDRjIiwiZXhwIjoxNjM2MDgyODY0fQ.bvcjJqsMO_Ielv2DPepKB_YOuaT5rE8A6T1p29ChOQqJ10W89Ob3-ou4YE_MQa2quaAkgcg_HK7q6AcU3ktmHd_P5l_cNjDkc8XOxux2Bh5n1YGNMkXOY2JPP7GyTOATxopCR311DmXQsUys-hg5LA50g-G8YXbFKzq9zuPIw2MPkEYjQsZ7fglAA36bEd1gQYKB316rrKXFArVMGQUEHJcad3NrkHzDAucw5WB8KkOuFZxN5cr-bShO2R11ZApdQwNRWOl9ph1i2MqjJKrLjSYu_JWeWJLDXoE3-g9gB1C9T4-n9ySLrsa3UT3W6_8v8RnfcuiHq51hcg3ZM9-LZg"
        }
    The Body of this call will be:
        {   "cid":  "A",
            "status":  true
    }
.LINK
#>   
    [CmdletBinding()]
    param(  [parameter(mandatory, ValueFromPipeLineByPropertyName = $true )][Alias('id')]                          
        [string]    $SystemId, 
        [parameter(mandatory)]                          [string]    $ShelfId, 
        [parameter(mandatory)][validateset('A', 'B')]    [string]    $CId,
        [parameter(mandatory)]                          [boolean]   $Status,        
        [switch]    $WhatIf
    )
    process {
        if ( -not $PSBoundParameters.ContainsKey('SystemId' ) ) {
            Write-Verbose 'No SystemID Given, running all SystemIDs'
            $ReturnCol = @()
            foreach ( $Sys in Get-DsccStorageSystem ) {
                Write-Verbose 'Walking Through Multiple Systems'
                If ( ($Sys).Id ) {
                    Write-Verbose 'Found a system with a System.id'
                    $ReturnCol += Get-DSCCAccessControlRecord -SystemId ($Sys).Id -WhatIf $WhatIf
                }
            }
            Write-Verbose 'Returning the Multiple System Id Access Controll Groups.'
            return $ReturnCol
        }
        else {
            $DeviceType = ( Find-DSCCDeviceTypeFromStorageSystemID -SystemId $SystemId )
            if ( $DeviceType ) {
                $MyAdd = 'storage-systems/' + $DeviceType + '/' + $SystemId + '/shelves/' + $ShelfId + '/action/locate'
                $MyBody = @{    cid = $CId 
                    status          = $Status
                } 
                return Invoke-DSCCRestMethod -UriAdd $MyAdd -body ( $MyBody | ConvertTo-Json ) -method Post -WhatIfBoolean $WhatIf
            }
            else {
                Write-Warning 'No StorageSystem detected with a valid that valid System ID'  
                return          
            }
        }
    }       
}   