function Dir_Make {
    [OutputType([bool])]
    param( [string] $dir_In )
    if((Test-Path -Path $dir_In) -eq $true) {
        return $true
    }
    $null = New-Item -ItemType "directory" -Path $dir_In
    return (Test-Path -Path $dir_In)
}

function Dir_Parse {
    [OutputType([file[]])]
    param ( [string[]] $dir_In )
    $files = New-Object System.Collections.ArrayList
    ForEach($dir in $dir_In) {
        if((Test-Path -Path $dir) -eq $false) {
            if($Settings.verbose -eq $true) { Write-Host("Directory: " + $dir + " unable to be found") }
            continue
        }
        (Get-ChildItem -Path $dir -Recurse -Include *.c) | ForEach-Object {
            [file] $file = @{
                state = "A"
                dir = $_.FullName;
                modified = $_.LastWriteTime.ToString()
            }
            $null = $files.Add($file)
        }
    }
    return [file[]] $files | Sort-Object dir
}