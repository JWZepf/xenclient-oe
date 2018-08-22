FILESEXTRAPATHS_prepend := "${THISDIR}/ovmf:"

SRC_URI = "git://github.com/tianocore/edk2.git;branch=master \
    file://0002-ovmf-update-path-to-native-BaseTools.patch \
    file://0003-BaseTools-makefile-adjust-to-build-in-under-bitbake.patch \
    "

SRCREV="dd4cae4d82c7477273f3da455084844db5cca0c0"

GCC_VER="$(${CC} -v 2>&1 | tail -n1 | awk '{print $3}')"
FILES_${PN} += "\
    /usr/share/firmware/ovmf.bin \
    "

fixup_target_tools() {
    case ${1} in
      4.4.*)
        FIXED_GCCVER=GCC44
        ;;
      4.5.*)
        FIXED_GCCVER=GCC45
        ;;
      4.6.*)
        FIXED_GCCVER=GCC46
        ;;
      4.7.*)
        FIXED_GCCVER=GCC47
        ;;
      4.8.*)
        FIXED_GCCVER=GCC48
        ;;
      4.9.*)
        FIXED_GCCVER=GCC49
        ;;
      *)
        FIXED_GCCVER=GCC5
        ;;
    esac
    echo ${FIXED_GCCVER}
}

do_compile_class-target() {
    export LFLAGS="${LDFLAGS}"
    OVMF_ARCH="X64"

    # The build for the target uses BaseTools/Conf/tools_def.template
    # from ovmf-native to find the compiler, which depends on
    # exporting HOST_PREFIX.
    export HOST_PREFIX="${HOST_PREFIX}"

    # BaseTools/Conf gets copied to Conf, but only if that does not
    # exist yet. To ensure that an updated template gets used during
    # incremental builds, we need to remove the copy before we start.
    rm -f `ls ${S}/Conf/*.txt | grep -v ReadMe.txt`

    # ${WORKDIR}/ovmf is a well-known location where do_install and
    # do_deploy will be able to find the files.
    rm -rf ${WORKDIR}/ovmf
    mkdir ${WORKDIR}/ovmf
    OVMF_DIR_SUFFIX="X64"
    FIXED_GCCVER=$(fixup_target_tools ${GCC_VER})
    bbnote FIXED_GCCVER is ${FIXED_GCCVER}
    build_dir="${S}/Build/Ovmf$OVMF_DIR_SUFFIX/RELEASE_${FIXED_GCCVER}"

    bbnote "Building without Secure Boot."
    rm -rf ${S}/Build/Ovmf$OVMF_DIR_SUFFIX
    ${S}/OvmfPkg/build.sh $PARALLEL_JOBS -a $OVMF_ARCH -b RELEASE -t ${FIXED_GCCVER}
    ln ${build_dir}/FV/OVMF.fd ${WORKDIR}/ovmf/ovmf.fd
}

do_install_class-target() {
    install -d ${D}/usr/share/firmware/
    install -m 0600 ${WORKDIR}/ovmf/ovmf.fd ${D}/usr/share/firmware/ovmf.bin
}

do_deploy_class-target() {
    :
}
