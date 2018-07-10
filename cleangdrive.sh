#!/bin/bash
source "./gdprm.sh"
source "./gdlib.sh"
if [ $# -ne 1 ]; then echo "Provide the directory name that you want to upload to gdrive" ; exit ; fi
#================================#
function main() { clean_recursive "$1"; }
#================================#
#>>>>>>>?
main "$1"
#<<<<<<<!
