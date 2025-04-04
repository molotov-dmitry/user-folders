#!/bin/bash

### Constants ==================================================================

readonly target_disk="/media/documents"

declare -a target_dir=( )
declare -a source_dir=( )

if dpkg -s libvirt0 >/dev/null 2>&1
then
    target_dir+=( 'libvirt/qemu'      'libvirt/images' )
    source_dir+=( '/etc/libvirt/qemu' '/var/lib/libvirt/images' )
fi

let DIR_COUNT=${#target_dir[@]}

### Check destination directory exist ==========================================

[[ -d "${target_disk}" ]] || exit 1

#### Create directories ========================================================

for (( index = 0; index < DIR_COUNT; index++ ))
do
    dst_dir="${target_disk}/${target_dir[$index]}"

    if ! test -d "${dst_dir}"
    then
        mkdir -p "${dst_dir}"

        [[ -d "${dst_dir}" ]] || exit 2
    fi
done

#### Move and link =============================================================

for (( index = 0; index < DIR_COUNT; index++ ))
do
	dst_dir="${target_disk}/${target_dir[$index]}"
    src_dir="${source_dir[$index]}"

	if [[ -z "${src_dir}" ]]
	then
	    continue
	fi

    if test -L "${src_dir}" && [[ "$(readlink -f "${src_dir}")" == "$(readlink -f "${dst_dir}")" ]]
    then
        continue
    fi
    
    test -d "${src_dir}" && find "${src_dir}/" -mindepth 1 -maxdepth 1 -exec mv -b -f -t "${dst_dir}/" {} +
    test -L "${src_dir}" && unlink "${src_dir}"
    test -d "${src_dir}" && rmdir "${src_dir}"

    mkdir -p "$(dirname "${src_dir}")"
    ln -s "${dst_dir}" "${src_dir}"

done
