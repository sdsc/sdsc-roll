#!/bin/bash

# Find common OSTs from a list of files.
# Call using ./find_common_osts.sh <file name>
# File should be a text list of file names,
# one file name per line.

file_list=$1
nfiles=`wc $file_list | awk '{print $1}'`

# Command to get the striping
getstripe="/opt/lustre/bin/lfs getstripe -q "

for i in `cat $file_list`
  do
  tmpfile=`echo $i | tr '/' 'Z'`
  if [ -e /tmp/$tmpfile.t ]
      then 
      rm -f /tmp/$tmpfile.t
  fi
  ost=`$getstripe $i | grep -v obdidx | grep -v $i`
  if [ -n "$ost" ]
      then
      echo $ost | awk '{printf("%dAA\n", $1)}' >> /tmp/$tmpfile.t
  fi
  sort /tmp/$tmpfile.t > /tmp/$tmpfile
  rm -f /tmp/$tmpfile.t
done

stripe_count_file=/tmp/ost_stripe_count.txt

echo "OST    Stripe Count    File Count    All Files?" > $stripe_count_file

for i in `cat /tmp/ZoasisZ* | sort | uniq | tr -d A`
  do
  echo $i
  cnt=`grep ^"$i"AA /tmp/Zoasis* | wc | awk '{print $1}'`
  echo -n "$i  $cnt" >> $stripe_count_file
  file_count=0
  for f in `cat $file_list`
    do
    tmpfile=`echo $f | tr '/' 'Z'`
    cnt=`grep ^"$i"AA /tmp/$tmpfile | wc | awk '{print $1}'`
    if [ $cnt -gt 0 ]
	then
	let "file_count+=1"
    fi
  done

  if [ $file_count -eq $nfiles ]
      then
      allfiles='Yes'
      else
      allfiles='No'
  fi

  echo "   $file_count   $allfiles" >> $stripe_count_file
done

for i in `cat $file_list`
  do
  tmpfile=`echo $i | tr '/' 'Z'`
  rm -f /tmp/$tmpfile
done

echo "OSTs common to all files"
grep 'File' $stripe_count_file
grep 'Yes' $stripe_count_file
echo 
echo "Full list is in $stripe_count_file"
