enum buildType {
    UNDEFINED   
    EXE
    LIB
}

class job_config {
    [string]    $jobName
    [buildType] $build
    [string]    $outDir
    [string]    $outName
    [string[]]  $include
    [string[]]  $source
    [string[]]  $linkDir
    [string[]]  $link
    [string[]]  $flags
    [string[]]  $waitJob
    [bool]      $debug
    [bool]      $valid
}