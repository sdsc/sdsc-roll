#!/bin/bash
#
# @Copyright@
#
# @Copyright@
#

function usage () 
{
    echo "$0 [-h][-c copyright]"
    echo "Update Copyright in all files"  
    echo " -h      help"  
    echo " -c      copyright file"  
}

# Defaults
SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)
COPYRIGHTFILE=$SCRIPTPATH/copyright.txt

while getopts hc: opt
do
    case "$opt" in
      h)  usage; exit 1;;
      c)  COPYRIGHTFILE="$OPTARG";;
      \?)       # unknown flag
          echo >&2 \
      usage 
      exit 1;;
    esac
done
shift $(($OPTIND - 1))

FILES=$(find . -type f -not -path "./.git/*")

echo "Processing..."
for FILE in $FILES; do
    echo "     $FILE"
    ed $FILE >/dev/null 2>&1<<EOF
/^#[ ]*@Copyright@
+,/^#[ ]*@Copyright@/-1d
-r $COPYRIGHTFILE
w
q
EOF

done

