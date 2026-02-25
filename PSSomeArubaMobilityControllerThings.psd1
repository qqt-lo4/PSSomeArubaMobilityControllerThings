@{
    # Module manifest for PSSomeArubaMobilityControllerThings

    # Script module associated with this manifest
    RootModule        = 'PSSomeArubaMobilityControllerThings.psm1'

    # Version number of this module
    ModuleVersion     = '1.0.0'

    # ID used to uniquely identify this module
    GUID              = 'f5b2d8c4-1a63-4e97-b04d-9c7e3f1a28b5'

    # Author of this module
    Author            = 'Loïc Ade'

    # Description of the functionality provided by this module
    Description       = 'Aruba Mobility Controller API wrapper: controller connection, show commands, and access point management.'

    # Minimum version of PowerShell required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = '*'

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport  = @()

    # Aliases to export from this module
    AliasesToExport    = @()

    # Private data to pass to the module specified in RootModule
    PrivateData       = @{
        PSData = @{
            Tags       = @('Aruba', 'MobilityController', 'WiFi', 'AccessPoint', 'API')
            ProjectUri = ''
        }
    }
}
