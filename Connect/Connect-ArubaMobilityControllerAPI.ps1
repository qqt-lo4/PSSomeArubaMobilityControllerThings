function Connect-ArubaMobilityControllerAPI {
    <#
    .SYNOPSIS
        Establishes a connection to the Aruba Mobility Controller API

    .DESCRIPTION
        Creates a connection object for interacting with the Aruba Mobility Controller API.
        Returns an object with methods for authentication, session management (cookie-based),
        and API calls (GET, POST, PUT). Automatically handles authentication and session
        creation. Optionally stores the connection in a global variable.

    .PARAMETER Address
        The hostname or IP address of the Aruba Mobility Controller.

    .PARAMETER Port
        The port number for the API (typically 4343 for HTTPS).

    .PARAMETER Username
        The username for authentication.

    .PARAMETER Password
        The password as a SecureString.

    .PARAMETER ignoreSSLError
        If specified, disables SSL certificate validation.

    .PARAMETER MoreInfo
        Optional additional information to store in the connection object.

    .PARAMETER GlobalVar
        If specified, stores the connection in $Global:ArubaMobilityControllerAPI instead of returning it.

    .OUTPUTS
        [hashtable]. A connection object with methods: IgnoreSSL(), Reconnect(), CallAPIGet(),
        and CallAPI(). Session uses cookie-based authentication.

    .EXAMPLE
        $conn = Connect-ArubaMobilityControllerAPI -Address "192.168.1.1" -Port 4343 -Username "admin" -Password $securePass

    .EXAMPLE
        Connect-ArubaMobilityControllerAPI -Address "controller.local" -Port 4343 -Username "admin" -Password $securePass -GlobalVar

    .NOTES
        Author  : Loïc Ade
        Version : 1.0.0
    #>
    Param(
        [Parameter(Position = 0)]
        [Alias("Server")]
        [string]$Address,
        [Parameter(Position = 1)]
        [int]$Port,
        [Parameter(Position = 2)]
        [string]$Username,
        [Parameter(Position = 3)]
        [securestring]$Password,
        [switch]$ignoreSSLError,
        [object]$MoreInfo,
        [switch]$GlobalVar
    )

    $oResult = [ordered]@{
        Address = $Address
        Port = $Port
        Username = $Username
        Password = $Password
        Credential = New-Object System.Management.Automation.PSCredential($Username,$Password)
        BaseURL = "https://$Address`:$Port/v1/"
        IgnoreSSLError = $ignoreSSLError.IsPresent
        Session = $null
        MoreInfo = $MoreInfo
    }

    $oResult | Add-Member -MemberType ScriptMethod -Name "IgnoreSSL" -Value {
        if ($this.IgnoreSSLError) {
            Invoke-IgnoreSSL
        }
    }
    
    $oResult | Add-Member -MemberType ScriptMethod -Name "Reconnect" -Value {
        $this.IgnoreSSL()
        $sUrl = $this.BaseURL + "api/login"
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($this.Password)
        $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        #Set-UseUnsafeHeaderParsing -Enable
        $oAPICall = Invoke-WebRequest -Uri $sUrl -Method Post -Body "username=$($this.Username)&password=$UnsecurePassword" -UseBasicParsing
        #Set-UseUnsafeHeaderParsing -Disable
        $oResult = $oAPICall.Content | ConvertFrom-Json | ConvertTo-Hashtable
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    
        $cookie = New-Object System.Net.Cookie 
          
        $cookie.Name = "SESSION"
        $cookie.Value = $oResult._global_result.UIDARUBA
        $cookie.Domain = $this.Address
      
        $session.Cookies.Add($cookie);
        $this.Session = $session
        $this.APISession = $oResult
    }

    $oResult | Add-Member -MemberType ScriptMethod -Name "CallAPIGet" -Value {
        Param([string]$url,[hashtable]$arguments,[bool]$Verbose = $false)
        $this.IgnoreSSL()
        $headers = @{
            "Content-Type" = "application/json"
            "Accept" = "application/json"
        }

        $sUrl = if ($url -like "*://*") {
            $url
        } else {
            $this.BaseURL + $url
        }

        $hNewArgs = @{}
        foreach ($key in $arguments.Keys) {
            if ($url -like "*{$key}*") {
                $sUrl = $sUrl -replace "{$key}", $arguments[$key]
            } else {
                $hNewArgs.$key = $arguments[$key]
            }
        }

        $sToken = "UIDARUBA=" + $this.APISession._global_result.UIDARUBA
        if ($hNewArgs.Keys.Count -gt 0) {
            $sURL = $sUrl + "?" + (Convert-HashtableToURLArguments -Arguments $hNewArgs) + "&$sToken"
        } else {
            $sURL = $sUrl + "?$sToken"
        }

        $iwrArgs = @{
            Headers = $headers
            Uri = $sUrl
            Method = "Get"
            Credential = $this.Credential
            UseBasicParsing = $true
        }

        $oAPICall = try {
            Invoke-WebRequest @iwrArgs -WebSession $this.Session
        } catch [System.Net.WebException] {
            try {
                $this.Reconnect()
                Invoke-WebRequest @iwrArgs -WebSession $this.Session
            } catch {
                $_.Exception.Response
            }
        }
        $sStatus = if (($oAPICall.StatusCode -ge 200) -and ($oAPICall.StatusCode -le 299)) { "OK" } else { "Error" }
        $oResult = $oAPICall.Content | ConvertFrom-Json | ConvertTo-Hashtable
        if ($Verbose -or ($sStatus -eq "Error")) {
            $hResult = [ordered]@{
                http = $oAPICall
                json = $oResult
                status = $sStatus
                url = $sUrl
                body = $sbody
            }
            return $hResult    
        } else {
            $oResult
        }
    }

    $oResult | Add-Member -MemberType ScriptMethod -Name "CallAPI" -Value {
        Param([string]$url,[Microsoft.PowerShell.Commands.WebRequestMethod]$method = "Get",[hashtable]$arguments,[bool]$Verbose = $false)
        $this.IgnoreSSL()
        $headers = @{
            "Content-Type" = "application/json"
            "Accept" = "application/json"
        }
        $sBody = if ($body) {
            if ($Body -is [string]) {
                $Body
            } else{
                $Body | ConvertTo-Hashtable | ConvertTo-Json
            }
        } else {
            "{}"
        }
        $sUrl = if ($url -like "*://*") {
            $url
        } else {
            $this.BaseURL + $url
        }

        $iwrArgs = @{
            Headers = $headers
            Uri = $sUrl
            Method = $method
            UseBasicParsing = $true
        }
        if ($method -in @("Post", "Put")) {
            $iwrArgs.Body = $sBody
        }

        $oAPICall = try {
            Invoke-RestMethod @iwrArgs
        } catch [System.Net.WebException] {
            $_.Exception.Response
        }
        $sStatus = if (($oAPICall.StatusCode -ge 200) -and ($oAPICall.StatusCode -le 299)) { "OK" } else { "Error" }
        $oResult = $oAPICall.Content | ConvertFrom-Json
        if ($Verbose -or ($sStatus -eq "Error")) {
            $hResult = [ordered]@{
                http = $oAPICall
                json = $oResult
                status = $sStatus
                url = $sUrl
                body = $sbody
            }
            return $hResult    
        } else {
            $oResult
        }
    }

    $oResult.Reconnect()

    if ($GlobalVar.IsPresent) {
        $Global:ArubaMobilityControllerAPI = $oResult
    } else {
        return $oResult
    }
}