. ./.SeaGull/Utils/s_utils.ps1

function Contents_Check {
    param( 
        [string[]] $dir_In,
        [bool] $make_In
    )
    return _l_Check -dir_In $dir_In -type_In "file" -make_In $make_In
}

function Contents_Read {
    [OutputType([file[]])]
    param ( [job] $job_In )
    [string[]] $contents = File_Read -dir_In ($job_In.objDir + "\contents.txt")
    if(!$contents) { return $null }
    $files = New-Object System.Collections.ArrayList
    $contents | ForEach-Object {
        $line = $_.Split("~")
        [file] $file = @{
            state = $line[0]
            dir = $line[1]
            modified = $line[2]
        }
        $null = $files.Add($file)
    }
    return [file[]] $files | Sort-Object dir
}

function Contents_Write {
    param ( [job] $job_In )
    if(!$job_In.source) { return $false }
    $dir = $job_In.objDir + "\contents.txt"
    [System.Collections.ArrayList] $outArray = File_Read -dir_In $dir
    if(!$outArray) { $outArray = New-Object System.Collections.ArrayList }
    ForEach($src in $job_In.source) {
        if(!$src.state) { continue }
        switch($src.state) {
            "N" { 
                $null = $outArray.Add(("A~" + $src.dir + "~" + $src.modified)) 
            }
            "U" {
                0..($outArray.Count - 1) | ForEach-Object {
                    if($outArray[$_].Contains($src.dir)) {
                        $split = $outArray[$_].Split("~")
                        $outArray[$_] = $outArray[$_] -replace $split[-1], $src.modified
                    }
                }
            }
            "K" {
                 0..($outArray.Count - 1) | ForEach-Object {
                    if($outArray[$_].Contains($src.dir)) {
                        $outArray.RemoveAt($_)
                        break
                    }
                }
            }
            default { continue }
        }
    }
    if($outArray.Count -gt 0) {
        File_Write -dir_In $dir -content_In $outArray | Sort-Object
    }
    return $true
}

function Contents_CheckNew {
    [OutputType([file[]])]
    param (  [job] $job_In )
    $contents = Contents_Read -job_In $job_In
    $new = New-Object System.Collections.ArrayList
    0..($job_In.source.Count - 1) | ForEach-Object {
        $src = $job_In.source[$_].dir
        $match = $false
        $contents | ForEach-Object {
            if($src -eq $_.dir) { $match = $true }
        }
        if($match -eq $false) {
                $job_In.source[$_].state = "N"
                $null = $new.Add($job_In.source[$_])
            }
    }
    return $new
}

function Contents_CheckUpdate {
    [OutputType([file[]])]
    param ( [job] $job_In )
    $contents = Contents_Read -job_In $job_In
    $updated = New-Object System.Collections.ArrayList
    for($i = 0; $i -lt $job_In.source.Count; $i++) {
        $contents | ForEach-Object {
            if($job_In.source[$i].dir -eq $_.dir) {
                if($job_In.source[$i].modified -ne $_.modified) { 
                    $job_In.source[$i].state = "U"
                    $null = $updated.Add($job_In.source[$i])
                }
            }
        }
    }
    return $updated
}

function Contents_CheckOld {
    [OutputType([file[]])]
    param ( [job] $job_In )
    $contents = Contents_Read -job_In $job_In
    if(!$contents) { return $null }
    $old = New-Object System.Collections.ArrayList
    0..($contents.Count - 1) | ForEach-Object {
        $match = $false
        $listing = $contents[$_].dir
        $job_In.source | ForEach-Object {
            if($listing -eq $_.dir) { $match = $true }
        }
        if($match -eq $false) {
            $contents[$_].state = "K"
            $null = $old.Add($contents[$_])
        }
    }
    return $old
}

function Contents_CrossRef {
    [OutputType([file[]])]
    param ( [job] $job_In )
    [file[]] $new
    [file[]] $update
    [file[]] $kill
    $threads = New-Object System.Collections.ArrayList
    $thread = Start-ThreadJob -OutVariable $new -ScriptBlock {
        param( $job_In )
        . ./.SeaGull/Src/s_contents.ps1
        
        $new = Contents_CheckNew -job_In $job_In
        return $new
    } -Arg ([job] $job_In)
    $null = $threads.Add($thread)
    $thread = Start-ThreadJob -OutVariable $update -ScriptBlock {
        param( $job_In )
        . ./.SeaGull/Src/s_contents.ps1
        
        $update = Contents_CheckUpdate -job_In $job_In
        return $update
    } -Arg ([job] $job_In)
    $null = $threads.Add($thread)
    $thread = Start-ThreadJob -OutVariable $kill -ScriptBlock {
        param( $job_In )
        . ./.SeaGull/Src/s_contents.ps1
        
        $kill = Contents_CheckOld -job_In $job_In
        return $kill
    } -Arg ([job] $job_In)
    $null = $threads.Add($thread)
    Receive-Job -Job $threads -Wait -AutoRemoveJob
    return ($new + $update + $kill)
}