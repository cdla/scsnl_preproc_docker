# scsnl_preproc_docker

docker container version of scsnl preprocessing pipeline



## Objective

The goal is to begin dockerizing the available workflows located at the [SCSNL github page](https://github.com/scsnl/scsnlScripts/) , starting with the preprocessing workflow. Dockerization/containerization of workflows allows for scalable, reproducible workflows that can be run on any environment that supports docker.



## Installation / Requirements

- Docker installation ([docker docs](https://docs.docker.com/get-started/))

## Usage

1. check whether docker is installed and running

```
docker info
```

2. clone the latest github version, by either clicking [here](https://github.com/cdla/scsnl_preproc_docker/archive/master.zip), or running

```
git clone git@github.com:cdla/scsnl_preproc_docker.git
```  

 3. unzip the directory (if needed) and cd into the directory

```
unzip scsnl_preproc_docker.zip;
cd scsnl_preproc_docker
```  

 4. build the docker image
```
docker build -t scsnl/preproc_spm12 .
```

 5. *(not tested/functional, but this is how the docker workflow woudl be run)* run the workflow, with the three arguments indicating the location of the config_file.m, the data_dir, and the output_dir
```
docker run -t scsnl/preproc_spm12 -v /oak/project_location:/project_dir/ -v /oak/raw_data_location/:/raw_data/ -v /oak/output_dir/:/output_dir/ -v /oak/config_file_location.txt:/config.m subject_index
```

## Future Directions

- use docker2singularity to create a singularity image so that the docker workflow can run in research computing clusters such as Sherlock.
- generate the same environment using neurodocker





## Thought Process

Upon doing some preliminary research, it looks like there are some field tools that have already done the lion's share of work in this process including:

- [the spm bids-app](https://github.com/BIDS-Apps/SPM)
  -  I was surprised when I ran across this tool.  Using the spm12 standalone MCR version, it runs a [preset preprocessing pipeline](https://github.com/BIDS-Apps/SPM/blob/master/pipeline_participant.m#L28-L57), that has been written in spm_batch format already.
- [neurodocker](https://github.com/kaczmarj/neurodocker)
  - this tool looks particularly interesting and I will likely make time to familiarize myself with it. It's a command line tool that generates Dockerfiles and Singularity images. Ultimately dockerization of workflows typically also needs to be followed by the creation of singularity images because singularity images can be run on university hpcc resources like Sherlock. Docker containers/daemons require root/admin power, whereas singularity images can be run without that requirement.
    - common tool to translate docker containers to singularity images is [docker2simularity](https://github.com/singularityware/docker2singularity).
- [the official spm docker](https://github.com/spm/spm-docker)
  - This repository looks like its been created three months ago, and recently updated, to include both the Matlab Compiled Runtime (MCR) version as well as the octave version. SPM Documentation says that officially SPM is **not** supported, and there are currently some known issues as indicated [here](https://en.wikibooks.org/wiki/SPM/Octave) .

### Possible Routes to Dockerizing Workflow

I. use official spm dockerfile

II. translate existing pipeline to nipype and then dockerize nipype environment with something like neurodocker

III. create MCR version of preprocessing scripts and add to official spm docker

IV. use neurodocker framework to create environment




### Choosing a Route:

route I.

- the official spm docker works mainly off spm_batch formatted language.  I would need to figure out how to translate the wrapped command line functions such as [this](https://github.com/scsnl/scsnlScripts/blob/master/brainImaging/mri/fmri/preprocessing/spm12/utils/nifti4Dto3D.m#L20-L21), as well as how to translate the pipeline's use of fsl at certain points like when reorienting the data/"FlipZ", like [here](https://github.com/scsnl/scsnlScripts/blob/master/brainImaging/mri/fmri/preprocessing/spm12/preprocessfmrimodules/scripts/preprocessfmri_FlipZ.m#L2))

route II

 - this route is the one that I would be most comfortable with, given my relative comfort with nipype as compared to nipype. I think that this route would take the longest.

route III *I chose to go this route*

- this route I think will have the best translation / easiest for users to who are familiar with the existing pipeline to translate over to

- For this route, the goal is to create a dockerfile that has:
  - spm12 standalone (mcr version) - [source](https://github.com/spm/spm-docker/blob/master/matlab/Dockerfile)
  - fsl 5.0.10 - [source](https://github.com/kaczmarj/neurodocker/blob/master/examples/fsl/Dockerfile) or something similar
  - scsnl preprocessing scripts - [source](https://github.com/scsnl/scsnlScripts/tree/master/brainImaging/mri/fmri/preprocessing/spm12)
    - include ArtRepair toolbox [website](https://cibsr.stanford.edu/tools/human-brain-project/artrepair-software.html)

- will need to modify existing scripts to use the spm12 mcr

route IV
- neurodocker seems like a very useful tool that I should familiarize myself with. I could see myself using this tool in the future.

### Plan

- [x] make a dockerfile that supports SPM12 MCR and FSL ([relevant commit](https://github.com/cdla/scsnl_preproc_docker/commit/5b2c7fd3880c0cd67a0ac48efacca706eb511b65))

- [x] remove/update script locations to docker relevant places ([relevant commit](https://github.com/cdla/scsnlScripts/commit/6cffbf8c8d4e7c21784d6e09bf4fbe77ee1409c8))
- [x] modify existing scripts to take data location/project location/ output location as arguments for command ([relevant commit](https://github.com/cdla/scsnlScripts/commit/977f1b577e7b9a3299e229c125b505f6ad0f4931))
  - due to the nature of containers, these directories will have to be mounted as volumes within the container.
- [x] within preproc functions and utils, remove filepaths (fsl commands and added toolboxes) ([relevant commit](https://github.com/cdla/scsnlScripts/commit/5149b937eec6786a4ca471b895543a13a4bc985a))
- [x] modify existing scripts to change spm_run locations to unix matlab commands that invoke spm12-mcr compiled versions [standalone usage docs](https://en.wikibooks.org/wiki/SPM/Standalone)
  - example:
  ```
  spm_jobman('run', BatchFile);
  ```
  turns to
  ```
  system(sprintf('spm12 batch %s',BatchFile));
  ```
([relevant commit](https://github.com/cdla/scsnlScripts/commit/7c41bb20d0f7423c7c6d5a3893bfcf7b10a4139f))
- [x] compile the SCSNL preprocessing scripts (including ARTRepair toolbox) into an executable using [mcc](https://www.mathworks.com/help/compiler/mcc.html) . ([relevant script](https://github.com/cdla/scsnl_preproc_docker/blob/master/scsnl_compile.sh))

- [ ] test that spm functions, artrepair functions, and unix/fsl functions are running appropriately within the matlab compiled app on a sample dataset
  - this will determine whether matlab runtime compiler and docker interaction requires workflow restructure to handle passing data to the container.



- [ ] integrate scsnl standalone app into dockerfile (add volume mounts from modified scsnl preproc scripts)

- [ ] test dockerfile

- [ ] comparison against non-dockerized version of scripts to make sure no hidden bugs arise.
