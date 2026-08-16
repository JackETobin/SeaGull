. ./.SeaGull/Utils/s_utils.ps1
. ./.SeaGull/Src/s_Job.ps1
. ./.SeaGull/Src/s_contents.ps1
. ./.SeaGull/Src/s_obj.ps1

function Dispatch_Prep {
    param ( [job_config] $config_In )
    if($Settings.verbose -eq $true){ Write-Host ("Preparing " + $config_In.jobName + " for dispatch.") }
    $jobDir = (Get-Item $PSScriptRoot).Parent.FullName + "\Temp\" + $config_In.jobName
    if((Dir_Make -dir_In $jobDir) -ne $true) {
        if($Settings.verbose -eq $true) { Write-Host "Unable to generate necessary directories. Aborting..." }
        return $false
    }
    if((File_Make -dir_In ($jobDir + "\contents.txt")) -ne $true) {
        if($Settings.verbose -eq $true) { Write-Host "Unable to generate contents file." }
        return $false
    }
    if($config_In.build -eq [buildType]::LIB) {
        if((File_SetBlock -name_In $config_In.jobName) -ne $true) {
            if($Settings.verbose -eq $true) { Write-Host "Unable to generate contents file." }
            return $false
        }
    }
    return $true
}

function Dispatch_Job {
    param ( [job_config] $config_In )
    $job = Job_Build -config_In $config_In
    if($null -eq $job){ return 1 }

    
    if($Settings.verbose -eq $true) { Write-Host($job.name + ": dispatching.") }
    $job.source = Contents_CrossRef -job_In $job
    if((Obj_Set -job_In $job) -ne $true) {
        if($Settings.verbose -eq $true) { Write-Host $job.name + ": Unable to assemble .obj files." }
        if($job.build = [buildType]::LIB) { $null = File_Unblock -name_In $job.name }
        return $false
    }
    $threads = New-Object System.Collections.ArrayList
    $thread = Start-ThreadJob -ScriptBlock {
        param( 
            $job_In, 
            $settings_In 
        )
        . ./.SeaGull/Src/s_extern.ps1
        
        $Global:Settings = $settings_In
        switch( $job_In.build ) {
            EXE { return Extern_Link -job_In $job_In }
            LIB { return Extern_Lib -job_In $job_In }
            default { Write-Host ($job_In.name + ": Unknown build type.") }
        }
        if($job_In.build = [buildType]::LIB) { $null = File_Unblock -name_In $job_In.name }
        return $false
    } -Arg ([job] $job, $Settings)
    $null = $threads.Add($thread)
    $thread = Start-ThreadJob -ScriptBlock {
        param( 
            $job_In, 
            $settings_In 
        )
        . ./.SeaGull/Src/s_contents.ps1
        
        $Global:Settings = $settings_In
        Contents_Write -job_In $job_In
        return
    } -Arg ([job] $job, $Settings)
    $null = $threads.Add($thread)
    $res = Receive-Job -Job $threads -Wait -AutoRemoveJob
    if($res -ne $true ) { return $false }
    return $true
}