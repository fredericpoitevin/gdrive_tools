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

Say you want to upload the directory `[dirname]` (where this is the relative path from the script to the directory you want to upload). You first need to create the directory *in the cloud*, using `gdrive mkdir`, and storing the output of that command in `[dirname].id`, where you retain the full relative path. All the information needed by `upload2gdrive` is now in place, so you just need to run `upload2gdrive [dirname]`. See below for a few more comments.

## Initialize <a id='upload_init'></a>
```
gdrive mkdir [dirname] > [dirname].id
```
*Note*: if you want to upload `[dirname]` under a parent ID in your gdrive, find the ID to the parent and use `-p` option. See the test provided here, where we have the following tree (note that you can upload the local directory to any *cloud* directory you want, it does not have to correspond to the local parent directory):
```
gd_test (is already present in our gdrive)
      |
      --> dir_to_upload (is not present there yet)
                      |
                      --> d1
                      --> d2
                      --> d3
``` 
We first need to find the gdrive ID of directory `gd_test` where we want to upload `dir_to_upload`:
```
[fpoitevi@langev2]$ gdrive list -q "name ='gdt_test'"
Id                                  Name       Type   Size   Created
19Wlag7uIw2rmGzVp1nhgsjGkXY8YxnvL   gdt_test   dir           2018-07-16 16:51:31
```
Now we can create a directory called `dir_to_upload` in gdrive under `gd_test`:
```
gdrive mkdir -p 19Wlag7uIw2rmGzVp1nhgsjGkXY8YxnvL dir_to_upload > dir_to_upload.id
```

## Run <a id='upload_run'></a>
```
upload2gdrive [dirname] 
#(relative path from here, or absolute path)
```

In the example provided here, we would run a first time:
```
[fpoitevi@langev2 gdrive_tools]$ ./upload2gdrive gdt_test/dir_to_upload
<==========>
@gdt_test/dir_to_upload -> Directories: 3 | Files: 0 | Link: 0
gdrive mkdir -p 1rwNn14Yd1Gif-avILbVqqrzztqEg5rpL d1 > gdt_test/dir_to_upload/d1.id
gdrive mkdir -p 1rwNn14Yd1Gif-avILbVqqrzztqEg5rpL d2 > gdt_test/dir_to_upload/d2.id
gdrive mkdir -p 1rwNn14Yd1Gif-avILbVqqrzztqEg5rpL d3 > gdt_test/dir_to_upload/d3.id
gdrive upload -p 1rwNn14Yd1Gif-avILbVqqrzztqEg5rpL gdt_test/dir_to_upload/d1.id
Uploading gdt_test/dir_to_upload/d1.id
Uploaded 1gCIcZo8W1WIJ2RSH6ZBr8n-LCHk8MEsy at 25.0 B/s, total 52.0 B
gdrive upload -p 1rwNn14Yd1Gif-avILbVqqrzztqEg5rpL gdt_test/dir_to_upload/d2.id
Uploading gdt_test/dir_to_upload/d2.id
Uploaded 1NOABbIFkeKSHdXGj3gTgBRTHTo6oOB8B at 52.0 B/s, total 52.0 B
gdrive upload -p 1rwNn14Yd1Gif-avILbVqqrzztqEg5rpL gdt_test/dir_to_upload/d3.id
Uploading gdt_test/dir_to_upload/d3.id
Uploaded 1lLTzhTHXRpiG9cNErVbtsrNfye9MHmSA at 42.0 B/s, total 52.0 B
<==========>
@gdt_test/dir_to_upload/d1 -> Directories: 2 | Files: 0 | Link: 0
gdrive mkdir -p 1deuB9YTV3R6rCdT3TejX_XAgxs97xd7h d11 > gdt_test/dir_to_upload/d1/d11.id
gdrive mkdir -p 1deuB9YTV3R6rCdT3TejX_XAgxs97xd7h d12 > gdt_test/dir_to_upload/d1/d12.id
gdrive upload -p 1deuB9YTV3R6rCdT3TejX_XAgxs97xd7h gdt_test/dir_to_upload/d1/d11.id
Uploading gdt_test/dir_to_upload/d1/d11.id
Uploaded 1tzuKkvwbxEwM8yA058pyW2rmRTEQA0q8 at 27.0 B/s, total 52.0 B
gdrive upload -p 1deuB9YTV3R6rCdT3TejX_XAgxs97xd7h gdt_test/dir_to_upload/d1/d12.id
Uploading gdt_test/dir_to_upload/d1/d12.id
Uploaded 1_coqPUyt4SXOhj6sBwfTLwZ7RN-BdsVN at 50.0 B/s, total 52.0 B
<==========>
@gdt_test/dir_to_upload/d1/d11 -> Directories: 0 | Files: 2 | Link: 0
gzip gdt_test/dir_to_upload/d1/d11/f111.txt
gdrive upload -p 1K4jivesCuXiPqQU2uceR41Jak8WT0Az7 gdt_test/dir_to_upload/d1/d11/f111.txt
Uploading gdt_test/dir_to_upload/d1/d11/f111.txt.gz
Uploaded 1oJCgV4tLhghOaDAQeHIo3d4TXuWpBL0r at 10.0 B/s, total 29.0 B
gzip gdt_test/dir_to_upload/d1/d11/f112.txt
gdrive upload -p 1K4jivesCuXiPqQU2uceR41Jak8WT0Az7 gdt_test/dir_to_upload/d1/d11/f112.txt
Uploading gdt_test/dir_to_upload/d1/d11/f112.txt.gz
Uploaded 1i1g70cgX5mlt77FmK_Q4vnm_qVdh35GM at 29.0 B/s, total 29.0 B
<==========>
@gdt_test/dir_to_upload/d1/d12 -> Directories: 0 | Files: 1 | Link: 0
gzip gdt_test/dir_to_upload/d1/d12/f121.txt
gdrive upload -p 1uAHwoWoQrS0MQ7-2Dv5ju7WVwJE9r1y7 gdt_test/dir_to_upload/d1/d12/f121.txt
Uploading gdt_test/dir_to_upload/d1/d12/f121.txt.gz
Uploaded 1ekfmNyjMSX6GvBQoACJpgPw6vcdqhu4O at 24.0 B/s, total 29.0 B
<==========>
@gdt_test/dir_to_upload/d2 -> Directories: 2 | Files: 0 | Link: 0
gdrive mkdir -p 1EM_Kb5yQqY0WFt3cM7ziuvx4YJL2d_P3 d21 > gdt_test/dir_to_upload/d2/d21.id
gdrive mkdir -p 1EM_Kb5yQqY0WFt3cM7ziuvx4YJL2d_P3 d22 > gdt_test/dir_to_upload/d2/d22.id
gdrive upload -p 1EM_Kb5yQqY0WFt3cM7ziuvx4YJL2d_P3 gdt_test/dir_to_upload/d2/d21.id
Uploading gdt_test/dir_to_upload/d2/d21.id
Uploaded 1QBfEVPA41ue8qpQ7UrdWlZGUs0qzbpWy at 44.0 B/s, total 52.0 B
gdrive upload -p 1EM_Kb5yQqY0WFt3cM7ziuvx4YJL2d_P3 gdt_test/dir_to_upload/d2/d22.id
Uploading gdt_test/dir_to_upload/d2/d22.id
Uploaded 1Ve2DrDupGAAOKoNT9MKipfAL6q8cJ8z4 at 40.0 B/s, total 52.0 B
<==========>
@gdt_test/dir_to_upload/d2/d21 -> Directories: 0 | Files: 3 | Link: 0
gzip gdt_test/dir_to_upload/d2/d21/f211.txt
gdrive upload -p 13AD2qaOvDxN7FzrpYzmpuvPh2U2QzkVK gdt_test/dir_to_upload/d2/d21/f211.txt
Uploading gdt_test/dir_to_upload/d2/d21/f211.txt.gz
Uploaded 1D8jZlOEtvUVMe8TbJUtPjFI_E3zjD55B at 26.0 B/s, total 29.0 B
gzip gdt_test/dir_to_upload/d2/d21/f212.txt
gdrive upload -p 13AD2qaOvDxN7FzrpYzmpuvPh2U2QzkVK gdt_test/dir_to_upload/d2/d21/f212.txt
Uploading gdt_test/dir_to_upload/d2/d21/f212.txt.gz
Uploaded 1Mk6NljlnZbjEJqz9fK3Quj3FANc4Vm3a at 29.0 B/s, total 29.0 B
gzip gdt_test/dir_to_upload/d2/d21/f213.txt
gdrive upload -p 13AD2qaOvDxN7FzrpYzmpuvPh2U2QzkVK gdt_test/dir_to_upload/d2/d21/f213.txt
Uploading gdt_test/dir_to_upload/d2/d21/f213.txt.gz
Uploaded 1u_5MDmmBxn_CeBa1ZfQmZcHQ5XIlq6Kc at 29.0 B/s, total 29.0 B
<==========>
@gdt_test/dir_to_upload/d2/d22 -> Directories: 0 | Files: 1 | Link: 0
gzip gdt_test/dir_to_upload/d2/d22/f221.txt
gdrive upload -p 1wDKYdI931MG7pyhYheVDdgHFf_9ABuTH gdt_test/dir_to_upload/d2/d22/f221.txt
Uploading gdt_test/dir_to_upload/d2/d22/f221.txt.gz
Uploaded 1T9M9wuBVMKEeBqDxB6OyfU9yAoQsickK at 29.0 B/s, total 29.0 B
<==========>
@gdt_test/dir_to_upload/d3 -> Directories: 0 | Files: 0 | Link: 1
gdrive upload -p 1b2nwyYqzBVlpZ6qdYTq17I9THN7qoNK4 gdt_test/dir_to_upload/d3/zymlinks.log
Uploading gdt_test/dir_to_upload/d3/zymlinks.log
Uploaded 1HzLaT5Lm1lq0vEYukOtZhFUrUZ6LRoUl at 47.0 B/s, total 57.0 B
```

Running a second time would give:
```
[fpoitevi@langev2 gdrive_tools]$ ./upload2gdrive gdt_test/dir_to_upload
<==========>
@gdt_test/dir_to_upload -> Directories: 3 | Files: 3 | Link: 0
<==========>
@gdt_test/dir_to_upload/d1 -> Directories: 2 | Files: 2 | Link: 0
<==========>
@gdt_test/dir_to_upload/d1/d11 -> Directories: 0 | Files: 2 | Link: 0
<==========>
@gdt_test/dir_to_upload/d1/d12 -> Directories: 0 | Files: 1 | Link: 0
<==========>
@gdt_test/dir_to_upload/d2 -> Directories: 2 | Files: 2 | Link: 0
<==========>
@gdt_test/dir_to_upload/d2/d21 -> Directories: 0 | Files: 3 | Link: 0
<==========>
@gdt_test/dir_to_upload/d2/d22 -> Directories: 0 | Files: 1 | Link: 0
<==========>
@gdt_test/dir_to_upload/d3 -> Directories: 0 | Files: 1 | Link: 1
```

# SLURM manager <a id='slurm'></a>
since gdrive gets stuck often, a workaround is to rerun in periodically. After properly editing the line starting with `srun` in `launch.slurm`, do:
```
sbatch launch.slurm
sbatch launch_control.slurm
```

# Acknowledgments <a id='acknowledgements'></a>

This relies exclusively on [prasmussen](https://github.com/prasmussen/gdrive) gdrive tool (not maintained anymore).
