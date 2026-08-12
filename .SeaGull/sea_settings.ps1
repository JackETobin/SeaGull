. ./.SeaGull/Utils/s_utils.ps1

    function Split_Args {
    param ( $args_In )
    $args_In = $args_In.Replace(" ", "")
    $userArgs = New-Object System.Collections.ArrayList
    For(([int] $i = $args_In.Length), ($ie = $args_In.Length); $i -ge 0; $i--) {
        if($args_In[$i] -eq '-') {
            $ib = $i + 1
            $null = $userArgs.Add($args_In.Substring($ib, $ie - $ib))
            $ie = $i
        }
    }
    return [string[]] $userArgs
}

function Check_Arguments {
    param ( $args_In )
    [settings] $settings = @{
        verbose = $false
        clean = $false
        exeonly = $false
    }
    [string[]] $argList = Split_Args -args_In $args_In
    ForEach ( $item in $argList ) {
        switch( $item ) {
            "verbose" { 
                $settings.verbose = $true
                Write-Host "-Verbose output enabled."
                break
            }
            "clean" { 
                $settings.clean = $true
                Write-Host "-Clean build enabled."
                break
            }
            "exeonly" {
                 $settings.exeonly = $true
                 Write-Host "-Exeonly enabled."
                 break
                }
            default { Write-Host "-Unknown flag: $item" }
        }
    }
    return $settings
}