# PowerShell Environment Variable Management Functions with Colorful Displays

# Function to get the value of an environment variable in all scopes
function Get-EnvVar {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    $scopes = @("Process", "User", "Machine")
    $found = $false

    foreach ($scope in $scopes) {
        try {
            switch ($scope) {
                "Process" {
                    $value = ${env:$Name}
                }
                default {
                    $value = [Environment]::GetEnvironmentVariable($Name, $scope)
                }
            }

            if ($value -ne $null) {
                Write-Host "`n$Name (Scope: $scope):" -ForegroundColor Cyan
                Write-Host "$value`n" -ForegroundColor Green
                $found = $true
            } else {
                Write-Host "`n$Name (Scope: $scope): Not Set`n" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Error retrieving environment variable at $scope scope: $_" -ForegroundColor Red
        }
    }

    if (-not $found) {
        Write-Warning "Environment variable '$Name' is not set in any scope."
    }
}
Set-Alias gev Get-EnvVar

# Function to set or update an environment variable with interactive scope selection
function Set-EnvVar {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Value
    )

    # Get current values at each scope
    $scopes = @("Process", "User", "Machine")
    $options = @()
    $i = 1

    Write-Host "`nSelect the scope to set '$Name' in:" -ForegroundColor Cyan
    foreach ($scope in $scopes) {
        switch ($scope) {
            "Process" {
                $currentValue = ${env:$Name}
            }
            default {
                $currentValue = [Environment]::GetEnvironmentVariable($Name, $scope)
            }
        }

        if ($currentValue -ne $null) {
            $option = "$i. $scope (Current Value: $currentValue)"
        } else {
            $option = "$i. $scope (Not Set)"
        }
        Write-Host $option -ForegroundColor Yellow
        $options += $option
        $i++
    }

    # Prompt user for selection
    Write-Host
    $selection = Read-Host "Enter the number of your choice (or 'q' to quit)"

    if ($selection -eq 'q') {
        Write-Host "Operation cancelled." -ForegroundColor Red
        return
    }

    if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $options.Count) {
        $scope = $scopes[$selection - 1]
        if ($PSCmdlet.ShouldProcess("Environment Variable '$Name'", "Set value at $scope scope")) {
            try {
                switch ($scope) {
                    "Process" {
                        ${env:$Name} = $Value
                        Write-Host "Set environment variable '$Name' to '$Value' in the current session." -ForegroundColor Green
                    }
                    default {
                        [Environment]::SetEnvironmentVariable($Name, $Value, $scope)
                        Write-Host "Set environment variable '$Name' to '$Value' at $scope scope." -ForegroundColor Green
                        Write-Host "Note: Changes will take effect in new sessions." -ForegroundColor Yellow
                    }
                }

                # Also update the current session if scope is User or Machine
                ${env:$Name} = $Value
            } catch {
                Write-Host "Error setting environment variable: $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Warning "Invalid selection. Operation cancelled."
    }
}
Set-Alias sev Set-EnvVar

# Function to clear the value of an environment variable with interactive scope selection
function Clear-EnvVar {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    # Get current values at each scope
    $scopes = @("Process", "User", "Machine")
    $options = @()
    $i = 1

    Write-Host "`nSelect the scope to clear '$Name' from:" -ForegroundColor Cyan
    foreach ($scope in $scopes) {
        switch ($scope) {
            "Process" {
                $value = ${env:$Name}
            }
            default {
                $value = [Environment]::GetEnvironmentVariable($Name, $scope)
            }
        }

        if ($value -ne $null) {
            $option = "$i. $scope (Current Value: $value)"
        } else {
            $option = "$i. $scope (Not Set)"
        }
        Write-Host $option -ForegroundColor Yellow
        $options += $option
        $i++
    }

    # Prompt user for selection
    Write-Host
    $selection = Read-Host "Enter the number of your choice (or 'q' to quit)"

    if ($selection -eq 'q') {
        Write-Host "Operation cancelled." -ForegroundColor Red
        return
    }

    if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $options.Count) {
        $scope = $scopes[$selection - 1]
        if ($PSCmdlet.ShouldProcess("Environment Variable '$Name'", "Clear value at $scope scope")) {
            try {
                switch ($scope) {
                    "Process" {
                        ${env:$Name} = ""
                        Write-Host "Cleared environment variable '$Name' in the current session." -ForegroundColor Green
                    }
                    default {
                        [Environment]::SetEnvironmentVariable($Name, "", $scope)
                        Write-Host "Cleared environment variable '$Name' at $scope scope." -ForegroundColor Green
                        Write-Host "Note: Changes will take effect in new sessions." -ForegroundColor Yellow
                    }
                }

                # Also update the current session if scope is User or Machine
                ${env:$Name} = ""
            } catch {
                Write-Host "Error clearing environment variable: $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Warning "Invalid selection. Operation cancelled."
    }
}
Set-Alias cev Clear-EnvVar

# Function to remove an environment variable with interactive scope selection
function Remove-EnvVar {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    # Get current values at each scope
    $scopes = @("Process", "User", "Machine")
    $options = @()
    $i = 1

    Write-Host "`nSelect the scope to remove '$Name' from:" -ForegroundColor Cyan
    foreach ($scope in $scopes) {
        switch ($scope) {
            "Process" {
                $currentValue = ${env:$Name}
            }
            default {
                $currentValue = [Environment]::GetEnvironmentVariable($Name, $scope)
            }
        }

        if ($currentValue -ne $null) {
            $option = "$i. $scope (Current Value: $currentValue)"
        } else {
            $option = "$i. $scope (Not Set)"
        }
        Write-Host $option -ForegroundColor Yellow
        $options += $option
        $i++
    }

    # Prompt user for selection
    Write-Host
    $selection = Read-Host "Enter the number of your choice (or 'q' to quit)"

    if ($selection -eq 'q') {
        Write-Host "Operation cancelled." -ForegroundColor Red
        return
    }

    if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $options.Count) {
        $scope = $scopes[$selection - 1]
        if ($PSCmdlet.ShouldProcess("Environment Variable '$Name'", "Remove at $scope scope")) {
            try {
                switch ($scope) {
                    "Process" {
                        Remove-Item "Env:\$Name" -ErrorAction SilentlyContinue
                        Write-Host "Removed environment variable '$Name' from the current session." -ForegroundColor Green
                    }
                    default {
                        [Environment]::SetEnvironmentVariable($Name, $null, $scope)
                        Write-Host "Removed environment variable '$Name' from $scope scope." -ForegroundColor Green
                        Write-Host "Note: Changes will take effect in new sessions." -ForegroundColor Yellow
                    }
                }

                # Also update the current session if scope is User or Machine
                Remove-Item "Env:\$Name" -ErrorAction SilentlyContinue
            } catch {
                Write-Host "Error removing environment variable: $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Warning "Invalid selection. Operation cancelled."
    }
}
Set-Alias rev Remove-EnvVar

# Function to get the current PATH environment variable in all scopes
function Get-EnvPath {
    [CmdletBinding()]
    param ()

    Get-EnvVar -Name "Path"
}
Set-Alias gep Get-EnvPath

# Function to add directories to the PATH variable with interactive scope selection
function Add-EnvPath {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Position = 0)]
        [string[]]$Paths
    )

    if (-not $Paths) {
        $inputPaths = Read-Host "Enter the directories to add to PATH (separated by semicolons)"
        $Paths = $inputPaths -Split ';'
    }

    # Get current PATH values at each scope
    $scopes = @("Process", "User", "Machine")
    $options = @()
    $i = 1

    Write-Host "`nSelect the scope to add paths to 'PATH':" -ForegroundColor Cyan
    foreach ($scope in $scopes) {
        $currentPath = switch ($scope) {
            "Process" { $env:Path }
            default { [Environment]::GetEnvironmentVariable("Path", $scope) }
        }

        if ($currentPath -ne $null) {
            $option = "$i. $scope (Current PATH Length: $($currentPath.Length))"
        } else {
            $option = "$i. $scope (Not Set)"
        }
        Write-Host $option -ForegroundColor Yellow
        $options += $option
        $i++
    }

    # Prompt user for selection
    Write-Host
    $selection = Read-Host "Enter the number of your choice (or 'q' to quit)"

    if ($selection -eq 'q') {
        Write-Host "Operation cancelled." -ForegroundColor Red
        return
    }

    if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $options.Count) {
        $scope = $scopes[$selection - 1]
        if ($PSCmdlet.ShouldProcess("PATH", "Add directories at $scope scope")) {
            try {
                $currentPath = switch ($scope) {
                    "Process" { $env:Path }
                    default { [Environment]::GetEnvironmentVariable("Path", $scope) }
                }

                $pathList = $currentPath -split ';' | Where-Object { $_ -ne '' } | Select-Object -Unique

                foreach ($path in $Paths) {
                    if (-not ($pathList -contains $path)) {
                        $pathList += $path
                        Write-Host "Adding '$path' to PATH." -ForegroundColor Green
                    } else {
                        Write-Host "Path '$path' is already in PATH." -ForegroundColor Yellow
                    }
                }

                $newPath = $pathList -join ';'

                switch ($scope) {
                    "Process" {
                        $env:Path = $newPath
                        Write-Host "Updated PATH in the current session." -ForegroundColor Green
                    }
                    default {
                        [Environment]::SetEnvironmentVariable("Path", $newPath, $scope)
                        Write-Host "Updated PATH at $scope scope." -ForegroundColor Green
                        Write-Host "Note: Changes will take effect in new sessions." -ForegroundColor Yellow
                        # Also update current session
                        $env:Path = $newPath
                    }
                }
            } catch {
                Write-Host "Error adding to PATH: $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Warning "Invalid selection. Operation cancelled."
    }
}
Set-Alias aep Add-EnvPath

# Function to remove directories from the PATH variable with interactive scope selection
function Remove-EnvPath {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Position = 0)]
        [string[]]$Paths
    )

    if (-not $Paths) {
        $inputPaths = Read-Host "Enter the directories to remove from PATH (separated by semicolons)"
        $Paths = $inputPaths -Split ';'
    }

    # Get current PATH values at each scope
    $scopes = @("Process", "User", "Machine")
    $options = @()
    $i = 1

    Write-Host "`nSelect the scope to remove paths from 'PATH':" -ForegroundColor Cyan
    foreach ($scope in $scopes) {
        $currentPath = switch ($scope) {
            "Process" { $env:Path }
            default { [Environment]::GetEnvironmentVariable("Path", $scope) }
        }

        if ($currentPath -ne $null) {
            $option = "$i. $scope (Current PATH Length: $($currentPath.Length))"
        } else {
            $option = "$i. $scope (Not Set)"
        }
        Write-Host $option -ForegroundColor Yellow
        $options += $option
        $i++
    }

    # Prompt user for selection
    Write-Host
    $selection = Read-Host "Enter the number of your choice (or 'q' to quit)"

    if ($selection -eq 'q') {
        Write-Host "Operation cancelled." -ForegroundColor Red
        return
    }

    if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $options.Count) {
        $scope = $scopes[$selection - 1]
        if ($PSCmdlet.ShouldProcess("PATH", "Remove directories at $scope scope")) {
            try {
                $currentPath = switch ($scope) {
                    "Process" { $env:Path }
                    default { [Environment]::GetEnvironmentVariable("Path", $scope) }
                }

                $pathList = $currentPath -split ';' | Where-Object { $_ -ne '' } | Select-Object -Unique

                foreach ($path in $Paths) {
                    if ($pathList -contains $path) {
                        $pathList = $pathList | Where-Object { $_ -ne $path }
                        Write-Host "Removing '$path' from PATH." -ForegroundColor Green
                    } else {
                        Write-Host "Path '$path' was not found in PATH." -ForegroundColor Yellow
                    }
                }

                $newPath = $pathList -join ';'

                switch ($scope) {
                    "Process" {
                        $env:Path = $newPath
                        Write-Host "Updated PATH in the current session." -ForegroundColor Green
                    }
                    default {
                        [Environment]::SetEnvironmentVariable("Path", $newPath, $scope)
                        Write-Host "Updated PATH at $scope scope." -ForegroundColor Green
                        Write-Host "Note: Changes will take effect in new sessions." -ForegroundColor Yellow
                        # Also update current session
                        $env:Path = $newPath
                    }
                }
            } catch {
                Write-Host "Error removing from PATH: $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Warning "Invalid selection. Operation cancelled."
    }
}
Set-Alias rep Remove-EnvPath