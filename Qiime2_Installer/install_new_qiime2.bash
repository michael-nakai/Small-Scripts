#!/bin/bash

link_to_new_qiime2=$1
filename=${link_to_new_qiime2##*/}
intermediate=${filename%%-linux*}
qiime2_ver=${intermediate%-*}
current_loc=$PWD
person=$(basename $HOME)
filepath=${HOME}/dw30_scratch/${person}/conda_envs/${qiime2_ver}

activate_miniconda

cd ~

echo 'Downloading QIIME2 files...'
wget $1

echo ''
echo 'Creating QIIME2 environment...'
conda env create -p $filepath --file $filename
rm -f $filename
echo 'alias activate_'$qiime2_ver'="conda activate' $filepath'"' >> ~/.bashrc
cd $current_loc

echo ''
echo ''
echo 'Finished. Bash will now restart. '
echo 'Please activate miniconda, then'
echo 'activate the new QIIME2 environment'
echo 'via the command:'
echo ''
echo 'activate_'$qiime2_ver

bash