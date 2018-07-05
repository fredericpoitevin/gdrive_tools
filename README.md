# gdrive_tools
a set of scripts that help me use the gdrive CLI

heavy use of [prasmussen](https://github.com/prasmussen/gdrive) gdrive tool (not maintained anymore).

# SLURM manager
since gdrive gets stuck often, a workaround is to rerun in periodically. Do:
```
sbatch launch.sh
sbatch launch_control.sh
```

# Upload directory recursively
```
upload2gdrive.sh
```
