require recipes-kernel/linux/linux-openxt-copy-objtool.inc
require classes/module-signing.bbclass
require classes/kernel-signing.bbclass

DEPENDS += "bc-native"

S = "${WORKDIR}/linux-${PV}"

# Don't use update-alternatives for kernel at all. 
pkg_postinst_kernel-image () {
    mv $D/${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE}-${KERNEL_VERSION} $D/${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE}
}

pkg_postrm_kernel-image () {
    rm -f $D/${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE}
}
