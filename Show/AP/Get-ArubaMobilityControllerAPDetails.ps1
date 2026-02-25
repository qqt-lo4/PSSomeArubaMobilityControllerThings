function Get-ArubaMobilityControllerAPDetails {
    <#
    .SYNOPSIS
        Retrieves detailed information for a specific access point

    .DESCRIPTION
        Executes the "show ap details" command via the API to retrieve comprehensive
        information about a specific access point. Supports lookup by name, IP address,
        IPv6 address, or wired MAC address. Optionally includes advanced details.

    .PARAMETER ArubaMobilityControllerAPI
        The API connection object. If not specified, uses $Global:ArubaMobilityControllerAPI.

    .PARAMETER ap-name
        The name of the access point.

    .PARAMETER ip-addr
        The IPv4 address of the access point.

    .PARAMETER ip6-addr
        The IPv6 address of the access point.

    .PARAMETER wired-mac
        The wired MAC address of the access point.

    .PARAMETER Advanced
        If specified, includes advanced details in the output.

    .OUTPUTS
        [hashtable]. The API response with detailed AP information.

    .EXAMPLE
        Get-ArubaMobilityControllerAPDetails -ap-name "AP-Floor1-01"

    .EXAMPLE
        Get-ArubaMobilityControllerAPDetails -ip-addr "192.168.1.10" -Advanced

    .EXAMPLE
        Get-ArubaMobilityControllerAPDetails -ArubaMobilityControllerAPI $conn -wired-mac "00:11:22:33:44:55"

    .NOTES
        Author  : Loïc Ade
        Version : 1.0.0
    #>
    Param(
        [object]$ArubaMobilityControllerAPI,
        [Parameter(ParameterSetName = "ap-name")]
        [string]${ap-name},
        [Parameter(ParameterSetName = "ip-addr")]
        [string]${ip-addr},
        [Parameter(ParameterSetName = "ip6-addr")]
        [string]${ip6-addr},
        [Parameter(ParameterSetName = "wired-mac")]
        [string]${wired-mac},
        [switch]$Advanced
    )
    Begin {
        $oArubaMobilityControllerAPI = if ($ArubaMobilityControllerAPI) { $ArubaMobilityControllerAPI } else { $Global:ArubaMobilityControllerAPI }
        $sCommand = "show ap details "
        if ($Advanced) {
            $sCommand += "advanced "
        }
        $sCommand += $PSCmdlet.ParameterSetName + " " + $PSBoundParameters[$PSCmdlet.ParameterSetName]
    }
    Process {
        return Get-ArubaMobilityControllerShowCommandResult $sCommand -ArubaMobilityControllerAPI $oArubaMobilityControllerAPI
    }
}