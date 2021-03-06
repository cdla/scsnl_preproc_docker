#!/bin/bash
# To use this script, download the ARTRepair toolbox and place it within toolboxes. It is separate from this github due to ARTRepair's request to gather name and organization information of its users.

base_dir="/Users/cdla/Repository/github/scsnl_preproc_docker"

matlab -r "mcc -d ${base_dir}/compiled_scsnl_app/ -I ${base_dir}/toolboxes/scsnlScripts/brainImaging/mri/fmri/preprocessing/spm12/preprocessfmrimodules/scripts/ -I ${base_dir}/toolboxes/scsnlScripts/brainImaging/mri/fmri/preprocessing/spm12/preprocessfmrimodules/batchtemplates/ -I ${base_dir}/toolboxes/scsnlScripts/brainImaging/mri/fmri/preprocessing/spm12/utils -I ${base_dir}/toolboxes/ArtRepair/ -m ${base_dir}/toolboxes/scsnlScripts/brainImaging/mri/fmri/preprocessing/spm12/preprocessfmri.m"
