param ( [string] $cmd_args_In )

if((Test-Path -Path ./sea_config.ps1) -eq $false) {
    Write-Host "Unable to find sea_config.ps1...aborting"
    Exit -3
}
. ./sea_config.ps1
. ./.SeaGull/sea_settings.ps1
. ./.SeaGull/Utils/s_utils.ps1

function Build_Main {
    [settings] $m_Settings = Check_Arguments -args_In $cmd_args_In
    if((Dir_Make -dir_In "./.SeaGull/Temp/Wait") -ne $true) {
        if($m_Settings.verbose) { Write-Host "Unable to make wait directory." }
        return "Build failure."
    }
    $index = New-Object System.Collections.ArrayList
    0..($jobConfigList.Count - 1) | ForEach-Object {
        $null = $index.Add(@{ 
            config = $jobConfigList[$_]
            settings = $m_Settings
        })
    }
    $index | ForEach-Object -Parallel { 
        . ./sea_config.ps1
        . ./.SeaGull/Src/s_job.ps1
        . ./.SeaGull/Src/s_dispatch.ps1
        
        $Global:Settings = $_.settings
        $config = Job_Validate -config_In $_.config
        if($config.valid -ne $true){
            return ( "..." + $config.jobName + " aborted." )
        }
        Write-Host ($config.jobName + " build start." )
        if((Dispatch_Prep -config_In $config) -ne $true) { return ($config.jobName + " build failure." ) }
        if((Dispatch_Job -config_In $config) -ne $true) { return ($config.jobName + " build failure.") }
        return ($config.jobName + " build complete." )
    }
    return;
}

Build_Main