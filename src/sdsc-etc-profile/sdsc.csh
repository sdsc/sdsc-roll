# Add /opt/modulefiles/* to module search path
foreach F (`find /opt/modulefiles -maxdepth 1 -mindepth 1 -type d`)
  if (! $?MODULEPATH ) then
    setenv MODULEPATH ${F}
  else if ( "$MODULEPATH" !~ *${F}* ) then
    setenv MODULEPATH ${F}:${MODULEPATH}
  endif
end

# Point Python to scar library
if (! $?PYTHONPATH) then
  setenv PYTHONPATH /opt/sdsc/lib
else if ( "$PYTHONPATH" !~ */opt/sdsc/lib* ) then
  setenv PYTHONPATH /opt/sdsc/lib:$PYTHONPATH
endif

# Add sdsc scripts to path
if (! $?path ) then
  set path = ( /opt/sdsc/bin /opt/sdsc/sbin )
else
  if ( "$path" !~ */opt/sdsc/bin* ) then
    set path = ( /opt/sdsc/bin $path )
  endif
  if ( "$path" !~ */opt/sdsc/sbin* ) then
    set path = ( /opt/sdsc/sbin $path )
  endif
endif

# Env vars to locate SDSC resources
setenv SDSCHOME /opt/sdsc
setenv SDSCDEVEL /opt/sdsc/devel
