# Add sdsc libraries to search paths
if (! $?PYTHONPATH) then
  setenv PYTHONPATH /opt/sdsc/lib::/opt/sdsc/lib/python2.6/site-packages
else if ( "$PYTHONPATH" !~ */opt/sdsc/lib* ) then
  setenv PYTHONPATH ${PYTHONPATH}:/opt/sdsc/lib::/opt/sdsc/lib/python2.6/site-packages
endif
if (! $?LD_LIBRARY_PATH) then
  setenv LD_LIBRARY_PATH /opt/sdsc/lib
else if ( "$LD_LIBRARY_PATH" !~ */opt/sdsc/lib* ) then
  setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/opt/sdsc/lib
endif

# Add sdsc scripts to path
if (! $?path ) then
  set path = ( /opt/sdsc/bin /opt/sdsc/sbin )
else
  if ( "$path" !~ */opt/sdsc/bin* ) then
    set path = ( $path /opt/sdsc/bin )
  endif
  if ( "$path" !~ */opt/sdsc/sbin* ) then
    set path = ( $path /opt/sdsc/sbin )
  endif
endif

# Env vars to locate SDSC resources
setenv SDSCHOME /opt/sdsc
setenv SDSCDEVEL /opt/sdsc/devel
