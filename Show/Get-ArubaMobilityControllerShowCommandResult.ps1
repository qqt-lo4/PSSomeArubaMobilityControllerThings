function Get-ArubaMobilityControllerShowCommandResult {
    <#
    .SYNOPSIS
        Executes a show command on an Aruba Mobility Controller

    .DESCRIPTION
        Runs a CLI show command via the Aruba Mobility Controller REST API and returns
        the result. Uses the configuration/showcommand endpoint.

    .PARAMETER ArubaMobilityControllerAPI
        The API connection object. If not specified, uses $Global:ArubaMobilityControllerAPI.

    .PARAMETER command
        The show command to execute (e.g., "show ap database", "show clients").

    .OUTPUTS
        [hashtable]. The API response with command output.

    .EXAMPLE
        Get-ArubaMobilityControllerShowCommandResult -command "show ap database"

    .EXAMPLE
        Get-ArubaMobilityControllerShowCommandResult -ArubaMobilityControllerAPI $conn -command "show clients"

    .NOTES
        Author  : Loïc Ade
        Version : 1.0.0
    #>
    Param(
        [object]$ArubaMobilityControllerAPI,
        [Parameter(Mandatory, Position = 0)]
        [string]$command
    )
    Begin {
        $oArubaMobilityControllerAPI = if ($ArubaMobilityControllerAPI) { $ArubaMobilityControllerAPI } else { $Global:ArubaMobilityControllerAPI }
        $hParam = Get-FunctionParameters -RemoveParam "ArubaMobilityControllerAPI"
    }
    Process {
        $oArubaMobilityControllerAPI.CallAPIGet("configuration/showcommand", $hParam)
    }
}
