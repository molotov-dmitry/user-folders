#!/bin/bash

### Constants ==================================================================

readonly target_disk="/media/documents/$USER"

declare -a target_dir=( "Downloads" "Documents" "Music" "Images"   "Video"  "Templates" "Projects"         )
declare -a source_dir=( ""          ""          ""      ""         ""       ""          "${HOME}/Projects" )
declare -a source_xdg=( "DOWNLOAD"  "DOCUMENTS" "MUSIC" "PICTURES" "VIDEOS" "TEMPLATES" ""                 )
declare -a source_ico=( ''          ''          ''      ''         ''       ''          'folder-projects'  )

if dpkg -s virtualbox >/dev/null 2>&1
then
    target_dir+=( "VirtualBox" )
    source_dir+=( "${HOME}/VirtualBox VMs" )
    source_xdg+=( "" )
    source_ico+=( 'folder-vbox' )
fi

if dpkg -s libvirt0 >/dev/null 2>&1 || dpkg -s gir1.2-libvirt-glib-1.0 || dpkg -s gnome-boxes >/dev/null 2>&1
then
    target_dir+=( "KVM/libvirt/config"              "KVM/libvirt/images"                    )
    source_dir+=( "${HOME}/.config/libvirt/qemu"    "${HOME}/.local/share/libvirt/images"   )
    source_xdg+=( ""                                ""                                      )
    source_ico+=( 'folder-vmware'                   'folder-vmware'                         )
fi

if dpkg -s gnome-boxes >/dev/null 2>&1
then
    target_dir+=( "KVM/gnome-boxes/images"                  )
    source_dir+=( "${HOME}/.local/share/gnome-boxes/images" )
    source_xdg+=( ''                                        )
    source_ico+=( 'folder-vmware'                           )
fi

let DIR_COUNT=${#target_dir[@]}

### Check destination directory exist ==========================================

[[ -d "${target_disk}" ]] || exit 1

#### Update XDG directories database ===========================================

xdg-user-dirs-update --force

#### Update old directory names ================================================

if [[ -d "${target_disk}/Boxes/images" && ! -e "${target_disk}/KVM/gnome-boxes/images"  ]]
then
    mkdir -p "${target_disk}/KVM/gnome-boxes"
    mv "${target_disk}/Boxes/images" "${target_disk}/KVM/gnome-boxes/images"
    rmdir "${target_disk}/Boxes" 2>/dev/null
fi

if [[ -d "${target_disk}/Boxes/config" && ! -e "${target_disk}/KVM/libvirt/config"  ]]
then
    mkdir -p "${target_disk}/KVM/libvirt"
    mv "${target_disk}/Boxes/config" "${target_disk}/KVM/libvirt/config"
    rmdir "${target_disk}/Boxes" 2>/dev/null
fi

if [[ -d "${target_disk}/VM" && ! -e "${target_disk}/VirtualBox"  ]]
then
    mv "${target_disk}/VM" "${target_disk}/VirtualBox"
fi

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
    icon="${source_ico[$index]}"

    if [[ -z "$src_dir" ]]
    then
        src_dir="$(xdg-user-dir ${source_xdg[$index]} 2>/dev/null)"
    fi

	if [[ -z "${src_dir}" || "$(realpath -q "${src_dir}")" == "${HOME}" ]]
	then
	    :
	else
	    if test -L "${src_dir}" && [[ "$(readlink -f "${src_dir}")" == "$(readlink -f "${dst_dir}")" ]]
	    then
	        :
	    else
	        test -d "${src_dir}" && find "${src_dir}/" -mindepth 1 -maxdepth 1 -exec mv -b -f -t "${dst_dir}/" {} +
	        test -L "${src_dir}" && unlink "${src_dir}"
	        test -e "${src_dir}" && rm -rf "${src_dir}"

            mkdir -p "$(dirname "${src_dir}")"
	        ln -s "${dst_dir}" "${src_dir}"
	    fi
	fi
	
	#### Set custom icons ------------------------------------------------------

	if which gio >/dev/null 2>/dev/null && [[ -n "${icon}" ]]
	then
	    gio set "${src_dir}" metadata::custom-icon-name "${icon}"
    fi

done

#### Link templates to global ==================================================

if [[ "$(realpath -q "$(xdg-user-dir TEMPLATES 2>/dev/null)")" != "${HOME}" ]]
then
    if [[ "$(basename "$(xdg-user-dir TEMPLATES 2>/dev/null)")" == 'Шаблоны' ]]
    then
        dir_path="$(xdg-user-dir TEMPLATES 2>/dev/null)/Система"
    else
        dir_path="$(xdg-user-dir TEMPLATES 2>/dev/null)/System"
    fi

    if [[ -d '/usr/share/templates' && "$(realpath -q "${dir_path}")" != '/usr/share/templates' ]]
    then
        rm -rf "${dir_path}"
        ln -sfT /usr/share/templates "${dir_path}"
    fi
fi

