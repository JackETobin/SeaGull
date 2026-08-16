. ./.SeaGull/sea_types.ps1
class job {
    [string]    $name
    [buildType] $build
    [string]    $objDir
    [string]    $outDir
    [string]    $outName
    [file[]]    $source
    [string[]]  $include
    [string[]]  $link
    [string[]]  $flags
    [string[]]  $objList
    [string[]]  $waitList
}

class settings {
    [bool]      $verbose
    [bool]      $clean
    [bool]      $exeonly
}

class file {
    [char]      $state
    [string]    $dir
    [string]    $modified
}