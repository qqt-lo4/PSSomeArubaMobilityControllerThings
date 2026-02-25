# PSSomeArubaMobilityControllerThings

A PowerShell module for managing Aruba Mobility Controllers via the REST API: controller connection, show command execution, and access point management.

## Features

### Connect (1 function)

| Function | Description |
|----------|-------------|
| `Connect-ArubaMobilityControllerAPI` | Establishes a connection to the Aruba Mobility Controller API with cookie-based session management |

### Show (1 function)

| Function | Description |
|----------|-------------|
| `Get-ArubaMobilityControllerShowCommandResult` | Executes a show command on an Aruba Mobility Controller via the configuration/showcommand endpoint |

### Show/AP (2 functions)

| Function | Description |
|----------|-------------|
| `Get-ArubaMobilityControllerAP` | Retrieves access point information with multiple filters (all, active, standby, up, down, campus, mesh, remote) |
| `Get-ArubaMobilityControllerAPDetails` | Retrieves detailed information for a specific AP by name, IP, IPv6, or wired MAC address |

## Requirements

- **PowerShell** 5.1 or later
- **Network access** to Aruba Mobility Controller API (typically HTTPS on port 4343)
- **Credentials** with appropriate permissions on the Aruba Mobility Controller
- **Helper modules** (for API utilities):
  - Functions like `Invoke-IgnoreSSL`, `Convert-HashtableToURLArguments`, `ConvertTo-Hashtable`, `Get-FunctionParameters`
  - These utilities are typically provided by related modules (e.g., PSSomeAPIThings, PSSomeDataThings)

## Installation

```powershell
# Clone or copy the module to a PowerShell module path
Copy-Item -Path ".\PSSomeArubaMobilityControllerThings" -Destination "$env:USERPROFILE\Documents\PowerShell\Modules\PSSomeArubaMobilityControllerThings" -Recurse

# Or import directly
Import-Module ".\PSSomeArubaMobilityControllerThings\PSSomeArubaMobilityControllerThings.psd1"
```

## Quick Start

### Connect to the Aruba Mobility Controller API
```powershell
# Create a connection object
$securePass = ConvertTo-SecureString "your_password" -AsPlainText -Force
$conn = Connect-ArubaMobilityControllerAPI -Address "192.168.1.1" -Port 4343 -Username "admin" -Password $securePass

# Or store in a global variable
Connect-ArubaMobilityControllerAPI -Address "192.168.1.1" -Port 4343 -Username "admin" -Password $securePass -GlobalVar
```

### Query access points
```powershell
# Get all APs with detailed information (default)
$aps = Get-ArubaMobilityControllerAP -ArubaMobilityControllerAPI $conn

# Get only active APs
$activeAps = Get-ArubaMobilityControllerAP -Active

# Get only APs that are down
$downAps = Get-ArubaMobilityControllerAP -Down

# Get mesh APs
$meshAps = Get-ArubaMobilityControllerAP -MeshAP

# Get detailed information for a specific AP
$apDetails = Get-ArubaMobilityControllerAPDetails -ap-name "AP-Floor1-01"

# Get AP details by IP with advanced information
$apDetails = Get-ArubaMobilityControllerAPDetails -ip-addr "192.168.1.10" -Advanced
```

### Execute show commands
```powershell
# Execute any show command
$result = Get-ArubaMobilityControllerShowCommandResult -command "show ap database"

# Another example
$clients = Get-ArubaMobilityControllerShowCommandResult -command "show clients"
```

### Working with the global connection
```powershell
# If you used -GlobalVar during connection, you can omit the -ArubaMobilityControllerAPI parameter
Get-ArubaMobilityControllerAP -AllDetailed
Get-ArubaMobilityControllerAPDetails -ip-addr "192.168.1.10"
```

## Connection Object Methods

The connection object returned by `Connect-ArubaMobilityControllerAPI` includes several useful methods:

| Method | Description |
|--------|-------------|
| `IgnoreSSL()` | Disables SSL certificate validation (if -ignoreSSLError was specified) |
| `Reconnect()` | Re-authenticates and obtains a new session cookie |
| `CallAPIGet($url, $args, $verbose)` | Performs a GET request to the API endpoint with automatic reconnection |
| `CallAPI($url, $method, $args, $verbose)` | Performs any HTTP method request to the API endpoint |

## Parameter Sets for Get-ArubaMobilityControllerAP

The `Get-ArubaMobilityControllerAP` function supports multiple parameter sets to filter AP queries:

| Parameter | Description | Command Executed |
|-----------|-------------|------------------|
| (default) | All APs with detailed information | `show ap database long` |
| `-All` | All APs from database | `show ap database` |
| `-AllDetailed` | All APs with long format | `show ap database long` |
| `-Active` | Only active APs | `show ap active` |
| `-Standby` | Only standby APs | `show ap standby` |
| `-Up` | Only APs with status up | `show ap database status up` |
| `-Down` | Only APs with status down | `show ap database status down` |
| `-CampusAP` | Only campus APs | `show ap database type cap` |
| `-MeshAP` | Only mesh APs | `show ap database type mesh` |
| `-RemoteAP` | Only remote APs (RAPs) | `show ap database type rap` |

## Module Structure

```
PSSomeArubaMobilityControllerThings/
├── PSSomeArubaMobilityControllerThings.psd1    # Module manifest
├── PSSomeArubaMobilityControllerThings.psm1    # Module loader (dot-sources all .ps1 files)
├── README.md                                    # This file
├── LICENSE                                      # PolyForm Noncommercial License
├── Connect/                                     # API connection management
│   └── Connect-ArubaMobilityControllerAPI.ps1
├── Show/                                        # Show command execution
│   └── Get-ArubaMobilityControllerShowCommandResult.ps1
└── Show/AP/                                     # Access Point queries
    ├── Get-ArubaMobilityControllerAP.ps1
    └── Get-ArubaMobilityControllerAPDetails.ps1
```

## Common Use Cases

### Monitor AP health
```powershell
# Get all APs that are down
$downAps = Get-ArubaMobilityControllerAP -Down
if ($downAps) {
    Write-Warning "The following APs are down: $($downAps -join ', ')"
}
```

### Get detailed diagnostics for a specific AP
```powershell
# Get advanced details for troubleshooting
$details = Get-ArubaMobilityControllerAPDetails -ap-name "AP-Floor2-05" -Advanced
$details | ConvertTo-Json -Depth 10
```

### Filter APs by type
```powershell
# Get all mesh APs
$meshAps = Get-ArubaMobilityControllerAP -MeshAP

# Get all remote APs (RAPs)
$raps = Get-ArubaMobilityControllerAP -RemoteAP
```

## API Endpoint

The module uses the Aruba Mobility Controller v1 API:
- **Base URL:** `https://<controller>:<port>/v1/`
- **Authentication:** Cookie-based session (SESSION cookie with UIDARUBA value)
- **Show commands endpoint:** `/v1/configuration/showcommand`

## Author

**Loïc Ade**

## License

This project is licensed under the [PolyForm Noncommercial License 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0/). See the [LICENSE](LICENSE) file for details.

In short:
- **Non-commercial use only** — You may use, modify, and distribute this software for any non-commercial purpose.
- **Attribution required** — You must include a copy of the license terms with any distribution.
- **No warranty** — The software is provided as-is.
