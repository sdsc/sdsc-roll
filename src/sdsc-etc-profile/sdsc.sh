# Add /opt/modulefiles/* to module search path
for F in `find /opt/modulefiles -maxdepth 1 -mindepth 1 -type d`; do
  if test -z "$MODULEPATH"; then
    export MODULEPATH=${F}
  elif ! [[ "${MODULEPATH}" =~ "${F}" ]]; then
    export MODULEPATH=${F}:${MODULEPATH}
  fi
done

# Point Python to sdsc library
if test -z "${PYTHONPATH}"; then
  export PYTHONPATH=/opt/sdsc/lib
elif ! [[ "${PYTHONPATH}" =~ "/opt/sdsc/lib" ]]; then
  export PYTHONPATH=/opt/sdsc/lib:$PYTHONPATH
fi

# Add sdsc scripts to path
if test -z "${PATH}"; then
  export PATH=/opt/sdsc/bin:/opt/sdsc/sbin
else
  if ! [[ "${PATH}" =~ "/opt/sdsc/bin" ]]; then
    export PATH=/opt/sdsc/bin:$PATH
  fi
  if ! [[ "${PATH}" =~ "/opt/sdsc/sbin" ]]; then
    export PATH=/opt/sdsc/sbin:$PATH
  fi
fi

# Env vars to locate SDSC resources
export SDSCHOME=/opt/sdsc
export SDSCDEVEL=/opt/sdsc/devel
