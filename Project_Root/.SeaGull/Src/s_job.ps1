. ./.SeaGull/sea_types.ps1
[string[]] $results

function Job_Fail {
    param( 
        [string] $field_In,
        [string] $name_In
    )
    Write-Host("Fatal: " + $name_In + $field_In + " is null or empty.")
    return $false
}

function Job_Warn {
    param( 
        [string] $field_In,
        [string] $name_In,
        $passThrough_In
    )
    if($Settings.verbose -eq $true){
        $null = $results.Add((" -Warning: " + $name_In + $field_In + " is null or empty."))
    }
    return $passThrough_In
}
function Job_Validate {
    param ( [job_config] $config_In )
    if($Settings.verbose -eq $true){ 
        Write-Host($config_In.jobName + " validation start.")
        $results = New-Object System.Collections.ArrayList
    }
    $config_In.valid = $true

    if(!$config_In.outDir){ 
        $config_In.valid = Job_Fail -field_In " outDir" -name_In $config_In.jobName }
    if(!$config_In.outName){ 
        $config_In.valid = Job_Fail -field_In " outName" -name_In $config_In.jobName }
    if(!$config_In.source){ 
        $config_In.valid = Job_Fail -field_In " source" -name_In $config_In.jobName }
    if($config_In.build -eq [buildType]::UNDEFINED){ 
        $config_In.valid = Job_Fail -field_In " build" -name_In $config_In.jobName }
    if($config_In.valid -ne $true){ 
        return [job_config] $config_In }

    $config_In.jobName = (!$config_In.jobName) ? 
        (Job_Warn -field_In " jobName" -name_In "Unknown Job" -passThrough_In "Unknown Job") : $config_In.jobName
    $config_In.include = ($null -ne $config_In.include) ? 
        $config_In.include : (Job_Warn -field_In " include" -name_In $config_In.jobName -passThrough_In $null)
    $config_In.link = ($null -ne $config_In.link) ? 
        $config_In.link : (Job_Warn -field_In " link" -name_In $config_In.jobName -passThrough_In $null)
    $config_In.flags = ($null -ne $config_In.flags) ? 
        $config_In.flags : (Job_Warn -field_In " flags" -name_In $config_In.jobName -passThrough_In $null)

    if($Global:Settings.verbose -eq $true){ 
        Write-Host($config_In.jobName + " validation complete.")
        Write-Host("Validation results: ")
        Write-Host($results | Format-List | Out-String)
        Write-Host("Validated config: ")
        Write-Host($config_In | Format-List | Out-String)
    }
    return [job_config] $config_In
}

function Job_Build {
    param( [job_config] $config_In )
    
if($Settings.verbose -eq $true) { Write-Host($config_In.jobName + ": building job.") }
    [job] $job = [job] @{
        name = $config_In.jobName
        build = $config_In.build
        objDir = (Get-Item $PSScriptRoot).Parent.FullName + "/Temp/" + $config_In.jobName
        outDir = $config_In.outDir
        outName = $config_In.outName
        waitList = $config_In.waitJob
    }
    $job.source = Dir_Parse -dir_In $config_In.source
    $include = New-Object System.Collections.ArrayList
    ForEach($dir in $config_In.include) {
        if($dir.StartsWith("-I") -eq $false) { $dir = ("-I" + $dir) }
        $null = $include.Add($dir)
    } $job.include = $include
    $link = New-Object System.Collections.ArrayList
    ForEach($dir in $config_In.linkDir) {
        if($dir.StartsWith("-L") -ceq $false) { $dir = ("-L" + $dir) }
        $null = $link.Add( $dir )
    } 
    ForEach($lib in $config_In.link) {
        if($lib.StartsWith("-l") -ceq $false) { $lib = ("-l" + $lib) }
        $null = $link.Add( $lib )
    } $job.link = $link
    $flags = New-Object System.Collections.ArrayList
    if($config_In.debug -eq $true) { $null = $flags.Add( "-g" ) }
    ForEach( $flag in $config_In.flags ) {
        if($flag.StartsWith("-") -eq $false) { $flag = ("-" + $flag) }
        $null = $flags.Add( $flag )
    } $job.flags = $flags

    return [job] $job
}