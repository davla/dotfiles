#!/usr/bin/env bash
# author: deadc0de6 (https://github.com/deadc0de6)
# Copyright (c) 2019, deadc0de6
#
# test compare ignore relative
# returns 1 in case of error
#

# exit on first error
#set -e

# all this crap to get current path
rl="readlink -f"
if ! ${rl} "${0}" >/dev/null 2>&1; then
  rl="realpath"

  if ! hash ${rl}; then
    echo "\"${rl}\" not found !" && exit 1
  fi
fi
cur=$(dirname "$(${rl} "${0}")")

#hash dotdrop >/dev/null 2>&1
#[ "$?" != "0" ] && echo "install dotdrop to run tests" && exit 1

#echo "called with ${1}"

# dotdrop path can be pass as argument
ddpath="${cur}/../"
[ "${1}" != "" ] && ddpath="${1}"
[ ! -d ${ddpath} ] && echo "ddpath \"${ddpath}\" is not a directory" && exit 1

export PYTHONPATH="${ddpath}:${PYTHONPATH}"
bin="python3 -m dotdrop.dotdrop"

echo "dotdrop path: ${ddpath}"
echo "pythonpath: ${PYTHONPATH}"

# get the helpers
source ${cur}/helpers

echo -e "\e[96m\e[1m==> RUNNING $(basename $BASH_SOURCE) <==\e[0m"

################################################################
# this is the test
################################################################

# dotdrop directory
basedir=`mktemp -d --suffix='-dotdrop-tests'`
echo "[+] dotdrop dir: ${basedir}"
echo "[+] dotpath dir: ${basedir}/dotfiles"

# the dotfile to be imported
tmpd=`mktemp -d --suffix='-dotdrop-tests'`

# some files
mkdir -p ${tmpd}/{program,config,vscode}
touch ${tmpd}/program/a
touch ${tmpd}/config/a
touch ${tmpd}/vscode/extensions.txt
touch ${tmpd}/vscode/keybindings.json

# create the config file
cfg="${basedir}/config.yaml"
create_conf ${cfg} # sets token

# import
echo "[+] import"
cd ${ddpath} | ${bin} import -c ${cfg} ${tmpd}/program
cd ${ddpath} | ${bin} import -c ${cfg} ${tmpd}/config
cd ${ddpath} | ${bin} import -c ${cfg} ${tmpd}/vscode

# add files on filesystem
echo "[+] add files"
touch ${tmpd}/program/b
touch ${tmpd}/config/b

# expects diff
echo "[+] comparing normal - diffs expected"
set +e
cd ${ddpath} | ${bin} compare -c ${cfg} --verbose
ret="$?"
echo ${ret}
[ "${ret}" = "0" ] && exit 1
set -e

# expects one diff
patt="b"
echo "[+] comparing with ignore (pattern: ${patt}) - no diff expected"
set +e
cd ${ddpath} | ${bin} compare -c ${cfg} --verbose --ignore=${patt}
[ "$?" != "0" ] && exit 1
set -e

# adding ignore in dotfile
cfg2="${basedir}/config2.yaml"
sed '/d_config:/a \ \ \ \ cmpignore:\n\ \ \ \ - "b"' ${cfg} > ${cfg2}
#cat ${cfg2}

# expects one diff
echo "[+] comparing with ignore in dotfile - diff expected"
set +e
cd ${ddpath} | ${bin} compare -c ${cfg2} --verbose
[ "$?" = "0" ] && exit 1
set -e

# adding ignore in dotfile
cfg2="${basedir}/config2.yaml"
sed '/d_config:/a \ \ \ \ cmpignore:\n\ \ \ \ - "b"' ${cfg} > ${cfg2}
sed -i '/d_program:/a \ \ \ \ cmpignore:\n\ \ \ \ - "b"' ${cfg2}
#cat ${cfg2}

# expects no diff
echo "[+] comparing with ignore in dotfile - no diff expected"
set +e
cd ${ddpath} | ${bin} compare -c ${cfg2} --verbose
[ "$?" != "0" ] && exit 1
set -e

# update files
echo touched > ${tmpd}/vscode/extensions.txt
echo touched > ${tmpd}/vscode/keybindings.json

# expect two diffs
echo "[+] comparing - diff expected"
set +e
cd ${ddpath} | ${bin} compare -c ${cfg} --verbose -C ${tmpd}/vscode
[ "$?" = "0" ] && exit 1
set -e

# expects no diff
echo "[+] comparing with ignore in dotfile - no diff expected"
sed '/d_vscode:/a \ \ \ \ cmpignore:\n\ \ \ \ - "extensions.txt"\n\ \ \ \ - "keybindings.json"' ${cfg} > ${cfg2}
set +e
cd ${ddpath} | ${bin} compare -c ${cfg2} --verbose -C ${tmpd}/vscode
[ "$?" != "0" ] && exit 1
set -e

## CLEANING
rm -rf ${basedir} ${tmpd}

echo "OK"
exit 0
