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

    "mac")
        # 64bit instantclient seg faults on OSX, force 32bit
        for i in `ls -1 ${PH_OIC_INSTALL_DIR}/${PH_OS}/32bit/*.zip`; do
            unzip ${i} -d /tmp/phundamental-oic
        done

        LIBDIR="/usr/local/instantclient"
        ph_mkdirs ${LIBDIR}

        mv /tmp/phundamental-oic/instantclient_10_2/* ${LIBDIR}
        rm -rf /tmp/phundamental-oic

        ph_symlink ${LIBDIR}/sqlplus /usr/local/bin/sqlplus true

        # Export environmental variables now so that PHP installation works right away
        export ORACLE_HOME=${LIBDIR}
        export LYLD_LIBRARY_PATH=${LIBDIR}

        echo "You need to add the following lines to your ~/.profile:"
        echo "export ORACLE_HOME=${LIBDIR}"
        echo "export LYLD_LIBRARY_PATH=${LIBDIR}"
        echo ""

        read -p "Press any key to continue..."
    ;;

    *)
        echo "Instant Client installtion not implemented for this OS yet!"
esac
