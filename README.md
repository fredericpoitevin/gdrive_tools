# gdrive_tools
a set of scripts that help me use the [gdrive](https://github.com/prasmussen/gdrive) CLI.

* [Setup](#setup)
* [Upload a directory recursively](#upload)
  * [Initialize](#upload_init)
  * [Run](#upload_run)
* [Using with SLURM manager](#slurm)
* [Acknowledgements](#acknowledgements)

# Setup <a id='setup'></a>
Make sure `gdprm.sh` and `gdlib.sh` are found when running main scripts.

Check `gdprm.sh` for its content and edit accordingly. `GD` points to your [gdrive](https://github.com/prasmussen/gdrive) executable. Make sure it is installed. `quiet` defines the verbose level of the script. `dry_run` defines whether the actions planned are executed. 
```#!/bin/bash
# 
GD=~/Toolkit/gdrive/gdrive
nlinemax=1000000
quiet=false
dry_run=false
logsymlinks="zymlinks.log"
cute_line="<==========>"
#
```

# Upload directory recursively <a id='upload'></a>
## Initialize <a id='upload_init'></a>
```
gdrive mkdir [dirname] > [dirname].id
```
*Note*: if you want to upload `[dirname]` under a parent ID in your gdrive, find the ID to the parent and use `-p` option. 

## Run <a id='upload_run'></a>
```
upload2gdrive [dirname] 
#(relative path from here, or absolute path)
```

# SLURM manager <a id='slurm'></a>
since gdrive gets stuck often, a workaround is to rerun in periodically. Do:
```
sbatch launch.slurm
sbatch launch_control.slurm
```

# Acknowledgments <a id='acknowledgements'></a>

This relies exclusively on [prasmussen](https://github.com/prasmussen/gdrive) gdrive tool (not maintained anymore).
