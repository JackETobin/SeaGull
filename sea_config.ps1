. ./.SeaGull/sea_types.ps1

# Job Config Fields:
#   -jobName    -> Name of the job when dispatched.
#   -build      -> Build type, either EXE or LIB.
#   -outDir     -> Output directory, relative to project root.
#   -outName    -> Output name.
#   -include    -> Include directories.
#   -source     -> Source directories.
#   -linkDir    -> Link directories.
#   -link       -> Libraries to link.
#   -flags      -> Compiler flags.
#   -waitJob    -> Jobs that need to be completed first, by jobName.
#   -debug      -> Debug mode, true or false.
#   -valid      -> Proprietary.

[job_config[]] $jobConfigList = @(
    [job_config] @{
        #jobName    =
        #build      = [buildType]::
        #outDir     =
        #outName    =
        #include    =
        #source     =
        #linkDir    =
        #link       =
        #flags      =
        #waitJob    =
        #debug      =
    })