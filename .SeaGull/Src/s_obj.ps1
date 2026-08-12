. ./.SeaGull/Utils/s_utils.ps1
. ./.SeaGull/Src/s_extern.ps1

function Obj_Build {
    [OutputType([bool])]
    param( [job] $job_In )
    $source = $job_In.source | Where-Object { $_.state -eq "N" -or $_.state -eq "U" }
    if($source.Count -le 0) { return $false }
    ForEach ( $file in $source) {
        $base = ($file.dir.Split("\"))[-1]
        $output = ($job_In.objDir + "\Obj\" + $base.Replace(".c", ".o"))
        Extern_Clang -src_In $file.dir -flags_In @("-c", $job_In.flags) -include_In $job_In.include -outDir_In $output
    }
    return $true
}

function Obj_Kill {
    [OutputType([bool])]
    param( [job] $job_In )
    $source = $job_In.source | Where-Object { $_.state -eq "K" }
    if($source.Count -le 0) { return $false }
    ForEach($file in $source) {
        $base = ($file.dir.Split("\"))[-1]
        $kill = ($job_In.objDir + "\Obj\" + $base.Replace(".c", ".o"))
        $null = File_Kill $kill
    }
    return $true
}

function Obj_Set {
    [OutputType([bool])]
    param( [job] $job_In )
    if((Dir_Make -dir_In ($job_In.objDir + "\Obj")) -ne $true) {
        if($Settings.verbose -eq $true) { Write-Host "Unable to generate obj directory." }
        return $false
    }
    $threads = New-Object System.Collections.ArrayList
    $thread = Start-ThreadJob -ScriptBlock {
        param( $job_In )
        . ./.SeaGull/Src/s_obj.ps1
        
        return Obj_Build -job_In $job_In
    } -Arg ([job] $job_In)
    $null = $threads.Add($thread)
    $thread = Start-ThreadJob -ScriptBlock {
        param( $job_In )
        . ./.SeaGull/Src/s_obj.ps1
        
        return Obj_Kill -job_In $job_In
    } -Arg ([job] $job_In)
    $null = $threads.Add($thread)
    $res = Receive-Job -Job $threads -Wait -AutoRemoveJob
    if($res[0] -eq $false -and $res[1] -eq $false) {
        if($Settings.verbose -eq $true){ Write-Host ($job_In.name + ": no updates required.") }
    }
    else {
        if($Settings.verbose -eq $true){ Write-Host ($job_In.name + ": update complete.") }
    }
    return $true
}