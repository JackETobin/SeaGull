# SeaGull
SeaGull is a powershell build system that I use specifically for C projects. 

It takes in a job_config[] that must be named $jobConfigList, and builds out either an executable or a static library based on the build configuration.
Notes: 
    -The sea_config.ps1 file must be in the project root for the system to work properly.
    -Run the system by calling sea_main.ps1.
    -It will take in a few command-line arguments, but only -verbose is plugged in. I will be getting rid of command-line arguments in lieu of config arguments.
    -It is currently set up to call clang on object and executable creation, and llvm-ar on lib creation.
    -SeaGull only works on windows at present.
    -This thing is a perpetual work in progress, I'll continue to refine it as my own requirements evolve.

Please take this and tailor it to your own needs if you're interested in using it, it's a crude tool, but it gets the job done consistently and quickly without the overhead of learning C-make or another build system.
Please do reach out if you have comments or questions!
Enjoy!
