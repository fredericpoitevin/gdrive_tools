#!/bin/bash
#
GD=~/Toolkit/gdrive/gdrive
if [ $# -ne 1 ]; then echo "Provide the directory name that you want to upload to gdrive" ; exit ; fi
quiet=false
dry_run=false
logsymlinks="zzzymlinkz.log"
cute_line="<==========>"
# ======================= #
# ////// FUNCTIONS \\\\\\ #
# ======================= #

function simlink() { # returns TRUE if $1 is a symlink
  test "$(readlink "${1}")";
} ### END OF FUNCTION SYMLINK ###

function proceed() { # returns TRUE if we can proceed
  flag=0
  if [ ! -f "${1}.id" ]; then flag=1;  echo "ERROR: ${1}.id not found locally..."
  else if [ "$( cat "${1}.id" | awk '{print $1}')" != "Directory" ]; then flag=1; echo "ERROR: ${1} was not created on gdrive..."; fi; fi
  numitems=$(ls ${1} | wc -l); if [ $numitems -eq 0 ]; then flag=1; echo "SKIP: ${1} is empty..."; fi
  return $flag
} ### END OF FUNCTION PROCEED

function add_link_to_list() {
  if [ ! -f "$2" ]; then touch "$2"; fi
  if ! grep -q "$(readlink "$1")" $2 ; then echo "$(readlink "$1")" >> "$2"; fi
} ### END OF FUNCTION ADD_LINK_TO_LIST

function test_compress() {
  compress=1
  filename=$(basename "$1")
  if [[ ${filename: -3} != ".gz" && ${filename: -3} != ".id" ]]; then compress=0; fi
  if [ $filename = $logsymlinks ]; then compress=1; fi
  return $compress
} ### END OF FUNCTION TEST_COMPRESS

list_length() {
  echo $(wc -w <<< "$@")
} ### END OF FUNCITON LIST_LENGTH

### FUNCTION TRAVERSE ###
function traverse() {
if proceed $1; then # proceed only if directory has been initiated (check presence of $1.id)
  list_file=""; n_file=0; list_dir=""; n_dir=0; n_links=0
  for item in "$1"/*; do
    if simlink "${item}"; then add_link_to_list $item ${1}/${logsymlinks}; n_links=` expr $n_links + 1` 
    else if [ ! -d "${item}" ]; then list_file="${list_file}$(basename "$item") "; n_file=` expr $n_file + 1`
                                else list_dir="${list_dir}$(basename "$item") "; n_dir=` expr $n_dir + 1`; fi; fi; done
  echo $cute_line; echo "@$1 -> Directories: $n_dir | Files: $n_file | Link: $n_links"; nlines=` expr $n_dir + $n_file`; nlines=` expr $nlines + 1000`
  if [ $n_dir -gt 0 ]; then for dir in $list_dir; do list_file="${list_file}$(basename "$dir").id "; n_file=` expr $n_file + 1`; done; fi
  if [ $n_links -gt 0 ]; then list_file="${list_file}${logsymlinks} "; n_file=` expr $n_file + 1`; fi
  parent_id=$( cat "${1}.id" | awk '{print $2}')
  echo "$( $GD list -m $nlines --name-width 0 --query " '$parent_id' in parents" | awk '{print $2}')" > parent.list  
  echo "$list_dir" | tr ' ' '\n' > dir.list; remaining_list=$(comm -23 <(cat dir.list | sort -u) <(cat parent.list | sort -u))
  if [ $(list_length $remaining_list) -gt 0 ]; then for dir in $remaining_list; do dir="${1}/$dir"
    if [ "$quiet" = false ] ; then echo "gdrive mkdir -p $parent_id $(basename "$dir") > ${dir}.id"; fi 
    if [ "$dry_run" = false ] ; then $GD mkdir -p $parent_id $(basename "$dir") > ${dir}.id ; fi; done; fi
  echo "$list_file" | tr ' ' '\n' > file.list; remaining_list=$(comm -23 <(cat file.list | sort -u) <(cat parent.list | sort -u))
  if [ $(list_length $remaining_list) -gt 0 ]; then for file in $remaining_list; do file="${1}/${file}"
    if [ "$quiet" = false ] ; then if test_compress $file; then echo "gzip $file"; fi; echo "gdrive upload -p $parent_id $file"; fi
    if [ "$dry_run" = false ] ; then if test_compress $file; then gzip $file; file="${file}.gz"; fi; $GD upload -p $parent_id $file ; fi; done; fi
  rm -f file.list dir.list parent.list
  # now traverse
  for dir in $list_dir; do dir="${1}/$dir"
    traverse "${dir}"
  done
fi
}
### END OF FUNCTION TRAVERSE ###

### FUNCTION MAIN ###
function main() {
    traverse "$1"
}
### END OF FUNCTION MAIN ###

# ============================== #
# \\\\\\ END OF FUNCTIONS ////// #
# ============================== #

# ================================== #
# <<<<< BEGINNING OF THE SCRIPT >>>> #
# ================================== #
main "$1"
# ================================== #
# <<<<<<<<<<<< THE END >>>>>>>>>>>>> #
# ================================== #
