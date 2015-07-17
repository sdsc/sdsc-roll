# Add /opt/modulefiles/* to module search path
for F in `find /opt/modulefiles -maxdepth 1 -mindepth 1 -type d`; do
  if test -z "$MODULEPATH"; then
    export MODULEPATH=${F}
  elif ! [[ "${MODULEPATH}" =~ "${F}" ]]; then
    export MODULEPATH=${MODULEPATH}:${F}
  fi
done

# Add sdsc libraries to search paths
if test -z "${PYTHONPATH}"; then
  export PYTHONPATH=/opt/sdsc/lib:/opt/sdsc/lib/python2.6/site-packages
elif ! [[ "${PYTHONPATH}" =~ "/opt/sdsc/lib" ]]; then
  export PYTHONPATH=${PYTHONPATH}:/opt/sdsc/lib:/opt/sdsc/lib/python2.6/site-packages
fi
if test -z "${LD_LIBRARY_PATH}"; then
  export LD_LIBRARY_PATH=/opt/sdsc/lib
elif ! [[ "${LD_LIBRARY_PATH}" =~ "/opt/sdsc/lib" ]]; then
  export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/sdsc/lib
fi

# Add sdsc scripts to path
if test -z "${PATH}"; then
  export PATH=/opt/sdsc/bin:/opt/sdsc/sbin
else
  if ! [[ "${PATH}" =~ "/opt/sdsc/bin" ]]; then
    export PATH=${PATH}:/opt/sdsc/bin
  fi
  if ! [[ "${PATH}" =~ "/opt/sdsc/sbin" ]]; then
    export PATH=${PATH}:/opt/sdsc/sbin
  fi
fi

# Env vars to locate SDSC resources
export SDSCHOME=/opt/sdsc
export SDSCDEVEL=/opt/sdsc/devel
