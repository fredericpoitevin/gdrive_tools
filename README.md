# gdrive_tools
a set of scripts that help me use the gdrive CLI

heavy use of [prasmussen](https://github.com/prasmussen/gdrive) gdrive tool (not maintained anymore).

# Setup
Check `gd.prm` for its content and edit accordingly. Make sure `gd.prm` and `gd.lib` are found when running main scripts.

# Upload directory recursively
## Initialize
```
gdrive mkdir [dirname] > [dirname].id
```
*Note*: if you want to upload `[dirname]` under a parent ID in your gdrive, find the ID to the parent and use `-p` option.

## Run
```
upload2gdrive [directory name (relative path from here, or absolute path)]
```

# SLURM manager
since gdrive gets stuck often, a workaround is to rerun in periodically. Do:
```
sbatch launch.slurm
sbatch launch_control.slurm
```
