# TheoremExtr
This repository is the artifact of our paper: Jian Fang, Yingfei Xiong, _Extraction and Search in Rocq: Theorems, Definitions and Their dependencies_. TheoremExtr is a extraction tool for Rocq projects. It can extract theorems, definitions, and their dependencies from Rocq projects.

## Artifact overview
We provide our artifact as a Docker image.  We highly **recommend** using `docker` to set up the environment. The rest of this guide assumes that you are doing so. 

This artifact demonstrates how to use our tool to extract theorems, definitions and other information from Rocq projects.

## Setting up docker
Follow the [official website](https://docs.docker.com/engine/install/ubuntu/) to install `docker`. In this repository, the `Dockerfile` contains all the commands we use to build the environment. And the `build.sh` is the shell script to build the image and run a docker container. Use the following command:
```bash
cd your/path/to/the/repo
chmod a+x ./build.sh
./build.sh
```

The `use.sh` is the shell script to execute an interactive `sh` shell on the container, now enter the container by running:
```bash
chmod a+x ./use.sh
./use.sh
```
Now, you successfully build the docker image.

## Setting up environment
Because we will extract large number of theorems and definitions from projects, please make sure your machine has enough disk space (at least 20GB free space).

### Rocq Install
Because we added extraction code in Rocq compiler, we need build and install the modified Rocq version. We need install the newest `opam` (version 2.4.1):
```bash
bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"
eval $(opam env --set-switch --switch=lemmaextraction)
```

This process has the following tips, We use the default configuration and just need to press Enter.
```bash
## Where should it be installed ? [/usr/bin]
```

Now we can build and install Rocq. Use the following commands:
```bash
cd /home/opam/data/
tar zxvf rocq.tar.gz
cd ./rocq
make dunestrap
opam install -y .
```
The precess may report error because of `coq-doc`. But this will not effect the using of `coqc`.
After installation, we can use `opam list` to check whether coq has been installed.

### Install Rocq Projects
Now we need build and install all the project that are used for extraction. 
The first step is unzip the projects:
```bash
cd /home/opam/data/lemmasearch_proj
python3 unzip_file.py
```

Then we build and install all the projects to current ocaml environment. We have provided a `Makefile` to automate this process. Just run:
```bash
cd /home/opam/data/lemmasearch_proj
make
```

This process may take a long time because there are many projects and some projects are large (e.g., CompCert). After this process, all the projects have been installed.

## Extracting Theorems
`Coq-Lemmas` is the Rocq plugin that we implemented to extract theorems from runtimes. We need to install it to the ocaml environment. Use the following commands:
```bash
cd /home/opam/data/Coq-Lemmas
make
make install
```

Now we can use our tool to extract theorems from Rocq projects. We have provided a python script `e.py` to automate this process. The script will extract theorems from all the projects in `lemmasearch_proj_extraction` directory. We need unzip the projects by using script `unzip_file.py` and then run the extraction script `e.py`:
```bash
cp /home/opam/data/rocq.tar.gz /home/opam/data/lemmasearch_proj_extraction/
cd /home/opam/data/lemmasearch_proj_extraction/
python3 unzip_file.py
cd ..
python3 e.py
```
This may take a long time because there are many projects. After this process, all the extracted lemmas will be stored in `/home/opam/data/text` directory. The dependency information and other detailed information will be stored in `/home/opam/data/detail` directory.

## Extracting Definitions
We can also extract definitions from Rocq projects. We have provided a python script `d.py` to automate this process. The script will extract definitions from all the projects in `lemmasearch_proj_extraction` directory. Run the following command:
```bash
cd /home/opam/data
python3 d.py
```
After this process, all the definitions and their types will be stored in `/home/opam/data/text-def` and `/home/opam/data/detail-def` directories.