# Add /opt/modulefiles/* to module search path
foreach F (`find /opt/modulefiles -maxdepth 1 -mindepth 1 -type d`)
  setenv MODULEPATH ${F}:${MODULEPATH}
end

# Point Python to scar library
if ($?PYTHONPATH) then
  setenv PYTHONPATH /opt/sdsc/lib:$PYTHONPATH
else
  setenv PYTHONPATH /opt/sdsc/lib
endif

# Add sdsc scripts to path
set path = ( /opt/sdsc/bin /opt/sdsc/sbin $path )

# Env vars to locate SDSC resources
setenv SDSCHOME /opt/sdsc
setenv SDSCDEVEL /opt/sdsc/devel
