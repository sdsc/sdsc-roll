# Add /opt/modulefiles/* to module search path
for F in `find /opt/modulefiles -maxdepth 1 -mindepth 1 -type d`; do
  export MODULEPATH=${F}:${MODULEPATH}
done

# Point Python to sdsc library
if test -n "$PYTHONPATH"; then
  export PYTHONPATH=/opt/sdsc/lib:$PYTHONPATH
else
  export PYTHONPATH=/opt/sdsc/lib
fi

# Add sdsc scripts to path
export PATH=/opt/sdsc/bin:/opt/sdsc/sbin:$PATH

# Env vars to locate SDSC resources
export SDSCHOME=/opt/sdsc
export SDSCDEVEL=/opt/sdsc/devel
