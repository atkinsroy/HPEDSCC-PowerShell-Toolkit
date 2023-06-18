# API call to 'access-controls' is depreciated
#function Get-DSCCAccessControl {
#    [CmdletBinding()]
#    param(  [switch]    $whatIf
#    )
#    process {
#        return ( Invoke-DSCCRestMethod -uriAdd 'access-controls' -method 'Get' -WhatIfBoolean $WhatIf ) 
#    }       
#}  

# API call to 'group-access' is depreciated
#function Get-DsccGroupAccess {
#    [CmdletBinding(SupportsShouldProcess)]
#    Param (
#    )
#
#    Process {
#        Invoke-DsccRestMethod -UriAdd 'group-access' -Method 'Get' -WhatIf:$WhatIfPreference
#    }
#}
<#
.SYNOPSIS
    Returns the DSCC Authz Resource Types.    
.DESCRIPTION
    Returns the HPE Data Services Cloud Console Data Operations Manager Resource Types information;
.PARAMETER WhatIf
    This option shows you the command that will be sent to the DSCC, will include the URI being sent to, the Header, Method, and the Body of the message.
.EXAMPLE
    PS:> Get-DSCCResourceType

    .EXAMPLE
    PS:> Get-DSCCResourceType -whatIf

    WARNING: You have selected the What-IF option, so the call will note be made to the array,
    instead you will see a preview of the RestAPI call

    The URI for this call will be
        https://scalpha-app.qa.cds.hpe.com/api/v1/access-controls
    The Method of this call will be
        Get
    The Header for this call will be :
        {   "Authorization":  "Bearer eyJhbGcsONZZjviVT71xz0...iGDDefq_9NEzKX-CsC2dLww8WglRiODredKeRORGKIkesKew"
        }
    The Body of this call will be:
        "No Body"
#>
function Get-DSCCResourceType {
    [CmdletBinding(SupportsShouldProcess)]
    param (
    )
    process {
        Invoke-DSCCRestMethod -UriAdd 'resource-types' -Method 'Get' -WhatIf:$WhatIfPreference
    }
}