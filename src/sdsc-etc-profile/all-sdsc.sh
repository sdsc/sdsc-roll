# Add sdsc libraries to search paths
if test -d /opt/sdsc/lib; then
  if test -z "${PYTHONPATH}"; then
    export PYTHONPATH=/opt/sdsc/lib
  elif ! [[ "${PYTHONPATH}" =~ "/opt/sdsc/lib" ]]; then
    export PYTHONPATH=${PYTHONPATH}:/opt/sdsc/lib
  fi
fi

# Add sdsc scripts to path
if test -d /opt/sdsc/bin; then
  if test -z "${PATH}"; then
    export PATH=/opt/sdsc/bin
  elif ! [[ "${PATH}" =~ "/opt/sdsc/bin" ]]; then
    export PATH=${PATH}:/opt/sdsc/bin
  fi
fi
if test -d /opt/sdsc/sbin; then
  if test -z "${PATH}"; then
    export PATH=/opt/sdsc/sbin
  elif ! [[ "${PATH}" =~ "/opt/sdsc/sbin" ]]; then
    export PATH=${PATH}:/opt/sdsc/sbin
  fi
fi

# Env vars to locate SDSC resources
export SDSCHOME=/opt/sdsc
export SDSCDEVEL=/opt/sdsc/devel
