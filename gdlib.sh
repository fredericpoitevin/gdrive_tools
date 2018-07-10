#!/bin/bash
source "./gdprm.sh"
# ======================= #
# ////// FUNCTIONS \\\\\\ #
# ======================= #

#>>> FUNCTION PROCEED
#... returns TRUE/0 if we can proceed, FALSE/1 if not
function proceed() { 
  flag=0
  if [ ! -f "${1}.id" ]; then flag=1;  echo "ERROR: ${1}.id not found locally..."
  else if [ "$( head -n 1 "${1}.id" | awk '{print $1}')" != "Directory" ]; then flag=1; echo "ERROR: ${1} was not created on gdrive..."; fi; fi
  numitems=$(ls ${1} | wc -l); if [ $numitems -eq 0 ]; then flag=1; echo "SKIP: ${1} is empty..."; fi
  return $flag; }
#<<< 

#>>> FUNCTION SIMLINK
#... returns TRUE if argument is a symlink
function simlink() { test "$(readlink "${1}")"; } 
#<<<

#>>> FUNCTION ADD_LINK_TO_LIST
#... add link info of 1st argument to file named 2nd argument
function add_link_to_list() {
  if [ ! -f "$2" ]; then touch "$2"; fi
  if ! grep -q "$(readlink "$1")" $2 ; then echo "$1 -> $(readlink "$1")" >> "$2"; fi; } 
#<<<

#>>> FUNCTION TEST_COMPRESS
#... returns TRUE/0 if files needs to be compressed, FALSE/1 if not
function test_compress() {
  compress=1
  filename=$(basename "$1")
  if [[ ${filename: -3} != ".gz" && ${filename: -3} != ".id" ]]; then compress=0; fi
  if [ $filename = $logsymlinks ]; then compress=1; fi
  return $compress; }
#<<< 

#>>> FUNCTION LIST_LENGTH
#... returns the lenght of an input list
function list_length() { echo $(wc -w <<< "$@"); }
#<<< 

#>>> FUNCTION GET_ID
#... returns the ID of the input argument (directory path)
function get_id() {
  parent_id=$( head -n 1 "${1}.id" | awk '{print $2}')
  echo "$parent_id"; }
#<<< 

#>>> FUNCTION PRINT_LOCAL_LISTS
#...
function print_local_lists() {
  list_file=""; n_file=0; list_dir=""; n_dir=0; n_links=0
  for item in "$1"/*; do
    if simlink "${item}"; then add_link_to_list $item ${1}/${logsymlinks}; n_links=` expr $n_links + 1` 
    else if [ ! -d "${item}" ]; then list_file="${list_file}$(basename "$item") "; n_file=` expr $n_file + 1`
         else list_dir="${list_dir}$(basename "$item") "; n_dir=` expr $n_dir + 1`; fi; fi; done
  echo $cute_line; echo "@$1 -> Directories: $n_dir | Files: $n_file | Link: $n_links"
  if [ $n_dir -gt 0 ]; then for dir in $list_dir; do list_file="${list_file}$(basename "$dir").id "; done; fi
  if [ $n_links -gt 0 ]; then list_file="${list_file}${logsymlinks} "; fi
  echo "$list_file" | tr ' ' '\n' > local_file.list
  echo "$list_dir"  | tr ' ' '\n' > local_dir.list
}
#<<<

#>>>FUNCTION CLEAR_LOCAL_LISTS
#...
function clear_local_lists() { for mimetype in "dir" "file"; do rm -f local_${mimetype}.list; done; }
#<<<

#>>> FUNCTION PRINT_PARENT_LIST
#...
function print_parent_list() {
  vartmp="="; if [ "$2" != "dir" ]; then vartmp="!$vartmp"; fi
  #echo "$( $GD list -m $nlinemax --name-width 0 --query " '$( get_id "$1" )' in parents and mimeType $vartmp 'application/vnd.google-apps.folder'" | awk '{print $2}')" > parent_${2}.list; }
  echo "$( $GD list -m $nlinemax --name-width 0 --query " '$( get_id "$1" )' in parents and mimeType $vartmp 'application/vnd.google-apps.folder'" | awk '{print $1" "$2}')" > parent_${2}.list
  if [ "$3" == "listname" ]; then mv parent_${2}.list parent_tmp.list; cat parent_tmp.list | awk '{print $2}' > parent_${2}.list; rm -f parent_tmp.list; fi
}
#<<<

#>>> FUNCTION CLEAR_PARENT_LIST
#...
function clear_parent_list() { rm -f parent_${1}.list; }
#<<<

#>>> FUNCTION CHECK_NOT_UPLOADED
#...
function check_not_uploaded() {
  not_done=0
  if grep -q "...${2}..." ${1}.id; then not_done=1; fi
  return $not_done ; }
#<<<

#>>> FUNCTION SET_DONE
#... 
function set_uploaded() { echo "...${2}... all uploaded" >> ${1}.id; }
#<<<

#>>> FUNCTION DO_UPLOAD
#...
function do_upload() {
  if [ $3 == "dir" ]; then
    if [ "$quiet" = false ] ; then echo "gdrive mkdir -p $( get_id "$1" ) "$2" > ${1}/${2}.id"; fi 
    if [ "$dry_run" = false ] ; then $GD mkdir -p $( get_id "$1" ) "$2" > ${1}/${2}.id ; fi
  else
    file=${1}/${2}
    if [ "$quiet" = false ] ; then if test_compress $file; then echo "gzip $file"; fi; echo "gdrive upload -p $(get_id "$1") $file"; fi
    if [ "$dry_run" = false ] ; then if test_compress $file; then gzip $file; file="${file}.gz"; fi; $GD upload -p $(get_id "$1") $file ; fi
  fi
}
#<<<

#>>> FUNCTION UPLOAD_RECURSIVE
#...
function upload_recursive() {
if proceed $1; then # proceed only if directory has been initiated (check presence of $1.id)
  # ! Get content: files, directories, symlinks
  print_local_lists $1
  # !! Compare with uploaded content, and upload remaining
  for mimetype in "dir" "file"; do
    if check_not_uploaded $1 $mimetype; then
      print_parent_list $1 $mimetype "listname"
        remaining_list=$(comm -23 <(cat local_${mimetype}.list | sort -u) <(cat parent_${mimetype}.list | sort -u))
        if [ $(list_length $remaining_list) -gt 0 ]; then for item in $remaining_list; do 
           do_upload $1 $item $mimetype; done
        else 
           set_uploaded $1 $mimetype
        fi
      clear_parent_list ${mimetype}; fi; done
  list_dir=$(cat local_dir.list | tr '\n' ' ')
  clear_local_lists
  # !!! Now traverse
  for dir in $list_dir; do dir="${1}/$dir"
    upload_recursive "${dir}"
  done
fi
}
#<<<

#>>> FUNCTION CLEAN_PARENT_LIST
#...
function clean_parent_list() {
  n_parent=$(cat parent_file.list | wc -l )
  n_unique=$(cat parent_file.list | awk '{print $2}' | sed 's/.gz//g' | sort -u  | wc -l )
  ratio=$(echo $n_unique / $n_parent | bc -l)
  if [ "${ratio:0:3}" != "1.0"  ]; then
    echo "... Uniqueness ratio: $ratio"
    cat parent_file.list | awk '{print $1" "$2}' > tmp_w.list
    nline=$(cat tmp_w.list | wc -l)
    while [ $nline -ne 0 ]
    do
      name=$(head -n 1 tmp_w.list | awk '{print $2}' | sed 's/.gz//g')
      grep "$name" tmp_w.list | sort -k2,2 > tmp_w2.list; mv tmp_w.list tmp_w3.list
      grep -v "$name" tmp_w3.list > tmp_w.list; rm -f tmp_w3.list
      num_name=$(cat tmp_w2.list | wc -l)
      if [ $num_name -ne 1 ]; then
        id=$(tail -n 1 tmp_w2.list | awk '{print $1}')
        while read line
        do
          id_test=$( echo $line | awk '{print $1}')
          if [ "$id_test" != "$id" ]; then
            if [ "$quiet" = false ] ; then echo "gdrive delete $id_test"; fi
            if [ "$dry_run" = false ] ; then $GD delete $id_test ; fi
          fi
        done < tmp_w2.list
      fi
      nline=$(cat tmp_w.list | wc -l)
    done
  fi
}
#<<<

#>>> FUNCTION CLEAN_RECURSIVE
#... this functions goes down the tree, and only keep one version of possibly duplicated files. 
#... Keeps a compressed version, if it exists
function clean_recursive() {
if proceed $1; then
  # Get list of uploaded files, and trim them so we only have unique occurences 
  print_parent_list $1 "file" "listidname"
  clean_parent_list 
  clear_parent_list "file"
  # Now traverse
  print_local_lists $1
  list_dir=$(cat local_dir.list | tr '\n' ' ')
  clear_local_lists
  for dir in $list_dir; do dir="${1}/$dir"
    clean_recursive "${dir}"
  done
fi
}
#<<<
