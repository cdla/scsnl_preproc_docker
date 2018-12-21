# scsnl_preproc_docker

docker container version of scsnl preprocessing pipeline



## Objective

The goal is to begin dockerizing the available workflows located at the [SCSNL github page](https://github.com/scsnl/scsnlScripts/) , starting with the preprocessing workflow. Dockerization/containerization of workflows allows for scalable, reproducible workflows that can be run on any environment that supports docker.



## Installation / Requirements

- Docker installation


## Usage

1. check whether docker is installed and running

```
docker info
```

2. clone the latest github version, by either clicking [here](https://github.com/cdla/scnsnl_preproc_docker/archive/master.zip), or running

```
git clone git@github.com:cdla/scnsnl_preproc_docker.git
```  

 3. unzip the directory (if needed) and cd into the directory

```
unzip scsnl_preproc_docker;
cd scnsnl_preproc_docker
```  

 4. build the docker image
```
docker build -f dockerfile -t scsnl/preproc_spm12
```

 5. run the workflow, with the three arguments indicating the location of the config_file.m, the data_dir, and the output_dir
```
docker run -it scsnl/preproc_spm12 config_file.m data_dir output_dir
```

## Future Directions

- use docker2singularity to create a singularity image so that the docker workflow can run in research computing clusters such as Sherlock.





## Background Info

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

II. create MCR version of preprocessing scripts and add to official spm docker

III. translate existing pipeline to nipype and then dockerize nipype environment with something like neurodocker



### Choosing a Route:

route I.

- the official spm docker works mainly off spm_batch formatted language.  I would need to figure out how to translate the wrapped command line functions such as [this](https://github.com/scsnl/scsnlScripts/blob/master/brainImaging/mri/fmri/preprocessing/spm12/utils/nifti4Dto3D.m#L20-L21), as well as how to translate the pipeline's use of fsl at certain points like when reorienting the data/"FlipZ", like [here](https://github.com/scsnl/scsnlScripts/blob/master/brainImaging/mri/fmri/preprocessing/spm12/preprocessfmrimodules/scripts/preprocessfmri_FlipZ.m#L2))

route III

 - this route is the one that I would be most comfortable with, given my relative comfort with nipype as compared to nipype. I think that this route would take the longest.

route II *I chose to go this route*

- this route I think will have the best translation / easiest for users to who are familiar with the existing pipeline to translate over to

- For this route, the goal is to create a dockerfile that has:
  - spm12 standalone (mcr version) - [source](https://github.com/spm/spm-docker/blob/master/matlab/Dockerfile)
  - fsl 5.0.10 - [source](https://github.com/kaczmarj/neurodocker/blob/master/examples/fsl/Dockerfile)
  - scsnl preprocessing scripts - [source](https://github.com/scsnl/scsnlScripts/tree/master/brainImaging/mri/fmri/preprocessing/spm12)



### Plan

- [ ] make a dockerfile that supports SPM12 MCR and FSL

- [ ] compile the SCSNL preprocessing scripts into an executable using [mcc](https://www.mathworks.com/help/compiler/mcc.html) .

- [ ] test that both spm functions and unix/fsl functions are running appropriately

- [ ] integrate scsnl standalone app into dockerfile

- [ ] test dockerfile

- [ ] comparison against non-dockerized version of scripts to make sure no hidden bugs arise.
