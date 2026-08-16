function File_Process_Out {
    [OutputType([string[]])]
    param( [string[]] $raw_In )
    $processed = New-Object System.Collections.ArrayList
    ForEach($item in $raw_In) {
        if(!$item) { continue }
        $null = $processed.Add($item.TrimEnd() + ";")
    }
    return $processed
}

function File_Write {
    [OutputType([bool])]
    param( 
        [string] $dir_In,
        [string[]] $content_In
    )
    if((Test-Path -Path $dir_In -PathType Leaf) -ne $true) {
        if($Settings.verbose -eq $true) { Write-Host ("Unable to find directory: " + $dir_In) }
        return $false
    }
    if($content_In) {
        $write = File_Process_Out -raw_In $content_In
        Set-Content -NoNewline -Path $dir_In -Value $write
    }
    return $true
}

function File_Read {
    [OutputType([System.Collections.ArrayList])]
    param( [string] $dir_In )
    if((Test-Path -Path $dir_In) -ne $true) {
        if($Settings.verbose -eq $true) { Write-Host ("Unable to find directory: " + $dir_In) }
        return $null
    }
    $content = Get-Content -Raw -Path $dir_In
    if($content) { [System.Collections.ArrayList] $content = $content.Split(";") }
    return $content
}

function File_Make {
    [OutputType([bool])]
    param( [string] $dir_In )
    if((Test-Path -Path $dir_In) -eq $true) {
        return $true
    }
    $null = New-Item -ItemType "file" -Path $dir_In
    return (Test-Path -Path $dir_In)
}
function File_Kill {
    [OutputType([bool])]
    param( [string] $dir_In )
    Remove-Item -Path $dir_In
    return !(Test-Path $dir_In)
}

function File_SetBlock {
    [OutputType([bool])]
    param( [string] $name_In )
    $dir = ("./.SeaGull/Temp/Wait/" + $name_In)
    $null = New-Item -ItemType "file" -Path $dir
    return (Test-Path -Path $dir)
}

function File_Unblock {
    [OutputType([bool])]
    param( [string] $name_In )
    $dir = ("./.SeaGull/Temp/Wait/" + $name_In)
    $null = Remove-Item -Path $dir
    return !(Test-Path -Path $dir)
}

function File_WaitBlock {
    [OutputType([bool])]
    param( [string[]] $names_In )
    ForEach($name in $names_In) {
        $dir = ("./.SeaGull/Temp/Wait/" + $name)
        while((Test-Path -Path $dir -PathType Leaf) -eq $true) {
            Start-Sleep -Milliseconds 10
        }
    }
    return
}