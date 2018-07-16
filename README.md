# gdrive_tools
a set of scripts that help me use the [gdrive](https://github.com/prasmussen/gdrive) CLI.

[Setup](#setup)

#<a id='setup'></a> Setup
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

# Upload directory recursively
## Initialize
```
gdrive mkdir [dirname] > [dirname].id
```
*Note*: if you want to upload `[dirname]` under a parent ID in your gdrive, find the ID to the parent and use `-p` option. 

## Run
```
upload2gdrive [dirname] 
#(relative path from here, or absolute path)
```

# SLURM manager
since gdrive gets stuck often, a workaround is to rerun in periodically. Do:
```
sbatch launch.slurm
sbatch launch_control.slurm
```

# Acknowledgments

This relies exclusively on [prasmussen](https://github.com/prasmussen/gdrive) gdrive tool (not maintained anymore).
