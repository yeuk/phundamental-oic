#!/bin/bash

PH_OIC_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_OIC_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

case "${PH_OS}" in \
    "linux")
        for i in `ls -1 ${PH_OIC_INSTALL_DIR}/${PH_OS}/${PH_ARCH}/*.rpm`; do
            rpm -Uvh ${i}
        done

        test ${PH_ARCH} == '32bit' && LIBDIR='client' || LIBDIR='client64'
        LIBDIR="/usr/lib/oracle/10.2.0.5/${LIBDIR}"

        # Append new library if not already there
        grep "${LIBDIR}/lib" /etc/ld.so.conf >/dev/null || { \
            echo "${LIBDIR}/lib" >> /etc/ld.so.conf && ldconfig; \
        }

        # Add executables to PATH
        for i in `ls -1 $LIBDIR/bin`; do
            ph_symlink $LIBDIR/bin/$i /usr/local/bin/$i
        done
    ;;

    *)
        echo "Instant Client installtion not implemented for this OS yet!"
esac
