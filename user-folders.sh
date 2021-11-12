#!/bin/bash

### Constants ==================================================================

readonly target_disk="/media/documents/$USER"

declare -a target_dir=( "Downloads" "Documents" "Music" "Images"   "Video"  "Templates" "Projects"         )
declare -a source_dir=( ""          ""          ""      ""         ""       ""          "${HOME}/Projects" )
declare -a source_xdg=( "DOWNLOAD"  "DOCUMENTS" "MUSIC" "PICTURES" "VIDEOS" "TEMPLATES" ""                 )

if dpkg -s virtualbox >/dev/null 2>&1
then
    target_dir+=( "VM" )
    source_dir+=( "${HOME}/VirtualBox VMs" )
    source_xdg+=( "" )
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

    if [[ -z "$src_dir" ]]
    then
        src_dir=$(eval echo $(grep "XDG_${source_xdg[$index]}_DIR" "$HOME/.config/user-dirs.dirs" | cut -d '"' -f 2))
    fi

	test -n "${src_dir}" || continue

	test -L "${src_dir}" && [[ "$(readlink -f "${src_dir}")" == "$(readlink -f "${dst_dir}")" ]] && continue

	test -d "${src_dir}" && find "${src_dir}/" -mindepth 1 -maxdepth 1 -exec mv -b -f -t "${dst_dir}/" {} +
	test -L "${src_dir}" && unlink "${src_dir}"
	test -e "${src_dir}" && rm -rf "${src_dir}"

	ln -s "${dst_dir}" "${src_dir}"

done

