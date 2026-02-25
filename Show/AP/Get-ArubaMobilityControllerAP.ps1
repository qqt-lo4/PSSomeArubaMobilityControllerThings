function Get-ArubaMobilityControllerAP {
    <#
    .SYNOPSIS
        Retrieves access point information from an Aruba Mobility Controller

    .DESCRIPTION
        Executes various "show ap" commands via the API to retrieve access point data.
        Supports multiple parameter sets for different query types: all APs, active APs,
        standby APs, status filters (up/down), and type filters (campus/mesh/remote).

    .PARAMETER ArubaMobilityControllerAPI
        The API connection object. If not specified, uses $Global:ArubaMobilityControllerAPI.

    .PARAMETER All
        Retrieves all APs from the database.

    .PARAMETER AllDetailed
        Retrieves all APs with detailed information (long format).

    .PARAMETER Active
        Retrieves only active APs.

    .PARAMETER Standby
        Retrieves only standby APs.

    .PARAMETER Up
        Retrieves only APs with status "up".

    .PARAMETER Down
        Retrieves only APs with status "down".

    .PARAMETER CampusAP
        Retrieves only campus APs.

    .PARAMETER MeshAP
        Retrieves only mesh APs.

    .PARAMETER RemoteAP
        Retrieves only remote APs (RAPs).

    .OUTPUTS
        [hashtable]. The API response with AP information.

    .EXAMPLE
        Get-ArubaMobilityControllerAP -AllDetailed

    .EXAMPLE
        Get-ArubaMobilityControllerAP -ArubaMobilityControllerAPI $conn -Active

    .EXAMPLE
        Get-ArubaMobilityControllerAP -Up

    .NOTES
        Author  : Loïc Ade
        Version : 1.0.0
    #>
    [CmdletBinding(DefaultParameterSetName = "None")]
    Param(
        [object]$ArubaMobilityControllerAPI,
        [Parameter(ParameterSetName = "database")]
        [switch]$All,
        [Parameter(ParameterSetName = "database long")]
        [switch]$AllDetailed,
        [Parameter(ParameterSetName = "active")]
        [switch]$Active,
        [Parameter(ParameterSetName = "standby")]
        [switch]$Standby,
        [Parameter(ParameterSetName = "database status up")]
        [switch]$Up,
        [Parameter(ParameterSetName = "database status down")]
        [switch]$Down,
        [Parameter(ParameterSetName = "database type cap")]
        [switch]$CampusAP,
        [Parameter(ParameterSetName = "database type mesh")]
        [switch]$MeshAP,
        [Parameter(ParameterSetName = "database type rap")]
        [switch]$RemoteAP
    )
    Begin {
        $oArubaMobilityControllerAPI = if ($ArubaMobilityControllerAPI) { $ArubaMobilityControllerAPI } else { $Global:ArubaMobilityControllerAPI }
        $sCommand = if ($PSCmdlet.ParameterSetName -eq "None") {
            "database long"
        } else {
            $PSCmdlet.ParameterSetName
        }
    }
    Process {
        return Get-ArubaMobilityControllerShowCommandResult "show ap $sCommand" -ArubaMobilityControllerAPI $oArubaMobilityControllerAPI
    }
}