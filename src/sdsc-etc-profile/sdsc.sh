# Add /opt/modulefiles/* to module search path
for F in `find /opt/modulefiles -maxdepth 1 -mindepth 1 -type d`; do
  export MODULEPATH=${F}:${MODULEPATH}
done

# Point Python to scar library
if test -n "$PYTHONPATH"; then
  export PYTHONPATH=/opt/scar/lib:/opt/sphinx/lib:$PYTHONPATH
else
  export PYTHONPATH=/opt/scar/lib:/opt/sphinx/lib
fi

# Add sdsc scripts to path
export PATH=/opt/scar/bin:/opt/scar/sbin:$PATH

# Env vars to locate SDSC resources
export SDSCHOME=/opt/sdsc
export SDSCDEVEL=/opt/sdsc/devel
