#!/usr/bin/env bash
# author: deadc0de6 (https://github.com/deadc0de6)
# Copyright (c) 2019, deadc0de6
#
# test transformations using templates
#

# exit on first error
set -e
#set -v

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

echo -e "$(tput setaf 6)==> RUNNING $(basename $BASH_SOURCE) <==$(tput sgr0)"

################################################################
# this is the test
################################################################

# the dotfile source
tmps=`mktemp -d --suffix='-dotdrop-tests' || mktemp -d`
mkdir -p ${tmps}/dotfiles
echo "dotfiles source (dotpath): ${tmps}"
# the dotfile destination
tmpd=`mktemp -d --suffix='-dotdrop-tests' || mktemp -d`
echo "dotfiles destination: ${tmpd}"

# create the config file
cfg="${tmps}/config.yaml"

cat > ${cfg} << _EOF
trans_read:
  r_echo_abs_src: echo "\$(cat {0}); {{@@ _dotfile_abs_src @@}}" > {1}
  r_echo_var: echo "\$(cat {0}); {{@@ r_var @@}}" > {1}
trans_write:
  w_echo_key: echo "\$(cat {0}); {{@@ _dotfile_key @@}}" > {1}
  w_echo_var: echo "\$(cat {0}); {{@@ w_var @@}}" > {1}
variables:
  r_var: readvar
  w_var: writevar
config:
  backup: true
  create: true
  dotpath: dotfiles
dotfiles:
  f_def:
    dst: ${tmpd}/def
    src: def
  f_abc:
    dst: ${tmpd}/abc
    src: abc
    trans_read: r_echo_abs_src
    trans_write: w_echo_key
  f_ghi:
    dst: ${tmpd}/ghi
    src: ghi
    trans_read: r_echo_var
    trans_write: w_echo_var
profiles:
  p1:
    dotfiles:
    - f_abc
    - f_def
    - f_ghi
_EOF
#cat ${cfg}

# create the dotfiles
echo 'abc' > ${tmps}/dotfiles/abc
echo 'marker' > ${tmps}/dotfiles/def
echo 'ghi' > ${tmps}/dotfiles/ghi

###########################
# test install and compare
###########################

# install
cd ${ddpath} | ${bin} install -f -c ${cfg} -p p1 -b -V

# check dotfile
[ ! -e ${tmpd}/def ] && exit 1
[ ! -e ${tmpd}/abc ] && exit 1
[ ! -e ${tmpd}/ghi ] && exit 1
grep marker ${tmpd}/def
cat ${tmpd}/abc
grep "^abc; ${tmps}/dotfiles/abc$" ${tmpd}/abc
cat ${tmpd}/ghi
grep "^ghi; readvar$" ${tmpd}/ghi

###########################
# test update
###########################

# update single file
cd ${ddpath} | ${bin} update -f -k -c ${cfg} -p p1 -b -V

# checks
[ ! -e ${tmps}/dotfiles/def ] && exit 1
[ ! -e ${tmps}/dotfiles/abc ] && exit 1
[ ! -e ${tmps}/dotfiles/ghi ] && exit 1
grep marker ${tmps}/dotfiles/def
cat ${tmps}/dotfiles/abc
grep "^abc; ${tmps}/dotfiles/abc; f_abc$" ${tmps}/dotfiles/abc
cat ${tmps}/dotfiles/ghi
grep "^ghi; readvar; writevar$" ${tmps}/dotfiles/ghi

## CLEANING
rm -rf ${tmps} ${tmpd}

echo "OK"
exit 0
