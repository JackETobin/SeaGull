. ./.Seagull/Utils/s_utils.ps1

function Extern_Clang {
    [OutputType([bool])]
    param (
        [string[]] $src_In,
        [string[]] $flags_In,
        [string[]] $include_In,
        [string[]] $link_In,
        [string[]] $outDir_In
    )
    clang $src_In $flags_In -o $outDir_In $include_In $link_In
    return $true
}

function Extern_Lib {
    [OutputType([bool])]
    param( [job] $job_In )
    $output = ((Get-Item $PSScriptRoot).Parent.Parent).FullName + $job_In.outDir
    if((Dir_Make -dir_In $output) -ne $true) {
        if($Settings.verbose -eq $true) { Write-Host "Unable to generate necessary directories. Aborting..." }
        return $false
    }
    $output = $output -replace "[.]", ""
    $lib = (Get-ChildItem -Path $job_In.objDir -Recurse -Include *.o).FullName
    if($IsWindows) { $fType = ".lib" }
    if($IsLinux) { $fType = ".a" }
    $dir = ($output + "\" + $job_In.outName + $fType)
    $res = llvm-ar -c -r $dir $lib
    if($res) {
        if($Settings.verbose -eq $true) { Write-Host "Unable to build static library" }
        return $false
    }
    return File_Unblock -name_In $job_In.name
}

function Extern_Link {
    param ( [job] $job_In )
    $output = ((Get-Item $PSScriptRoot).Parent.Parent).FullName + $job_In.outDir
    if((Dir_Make -dir_In $output) -ne $true) {
        if($Settings.verbose -eq $true) { Write-Host "Unable to generate necessary directories. Aborting..." }
        return $false
    }
    $output = $output -replace "[.]", ""
    if($output.EndsWith("/") -eq $false) { $output = $output + "/" }
    $output = $output + $job_In.outName
    if($output.EndsWith(".exe") -eq $false) { $output = $output + ".exe" }
    $src = Get-ChildItem -Path $Job_In.objDir -Recurse -Include *.o
    if($job_In.waitList) {
        File_WaitBlock -names_In $job_In.waitList
    }
    Extern_Clang -src_In $src -flags_In $job_In.flags -link_In $job_In.link -outDir_In $output
    return
}