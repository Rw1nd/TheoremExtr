# TheoremExtr
This repository is the artifact of our paper: Jian Fang, Yingfei Xiong, _Extraction and Search in Rocq: Theorems, Definitions and Their Dependencies_. TheoremExtr is an extraction tool for Rocq projects that extracts theorems, definitions, and their dependencies from Rocq codebases.

## Artifact Overview
This artifact demonstrates the usage of our tool for extracting theorems, definitions, and related data from Rocq projects.

We highly **recommend** using `docker` to configure the environment. The remainder of this guide assumes the use of Docker for environment setup. And this repository requires Git Large File Storage to ensure proper downloading of large files. Please ensure that [git-lfs](https://git-lfs.com/) is configured in your environment.

```bash
# Please ensure that git-lfs is installed.
git clone https://github.com/Rw1nd/TheoremExtr.git
```

## Setting Up Docker
First, follow the [official documentation](https://docs.docker.com/engine/install/ubuntu/) to install `docker`. In this repository, the `Dockerfile` contains all commands required to build the environment. The `build.sh` script builds the Docker image and instantiates a container. Execute the following commands:
```bash
cd your/path/to/the/TheoremExtr
chmod a+x ./build.sh
./build.sh
```

The `use.sh` script executes an interactive `sh` shell within the container. Enter the container by executing:
```bash
chmod a+x ./use.sh
./use.sh
```
This completes the Docker image build process.

## Setting Up the Environment
Due to the large number of theorems and definitions extracted from projects, ensure that your machine has sufficient disk space (at least 20GB of free space).

### Rocq Installation
Since we have integrated extraction code into the Rocq compiler, it is necessary to build and install the modified Rocq version. First, install the latest version of `opam` (version 2.5.0):
```bash
bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"
eval $(opam env --set-switch --switch=lemmaextraction)
```

During this process, the following hint will appear. Use the default configuration by pressing Enter:
```bash
## Where should it be installed ? [/usr/bin]
```

Next, build and install Rocq using the following commands:
```bash
cd /home/opam/data/
tar zxvf rocq.tar.gz
cd ./rocq
make dunestrap
opam install -y .
```
The process may report an error related to `coq-doc`; however, this will not affect the building of `coqc`. We can ignore this error.
After installation, verify that Coq has been successfully installed by executing `opam list`.

### Installing Rocq Projects
The next step involves building and installing all projects required for extraction.
First, extract the project archives:
```bash
cd /home/opam/data/lemmasearch_proj
python3 unzip_file.py
```

Then, build and install all projects into the current OCaml environment. We provide a `Makefile` to automate this process. By default, we use 16 cores to compile projects. The `Makefile` can be modified to adjust the number of cores according to your system configuration.
```bash
cd /home/opam/data/lemmasearch_proj
make
```

This process may require substantial time. Upon completion, all projects will be successfully installed.

## Extracting Theorems
`Coq-Lemmas` is the Rocq plugin we developed for theorem extraction at runtime. Install this plugin into the OCaml environment using the following commands:
```bash
cd /home/opam/data/Coq-Lemmas
make
make install
```

The tool can now be used to extract theorems from Rocq projects. We provide a Python script `e.py` to automate this process. This script extracts theorems from all projects in the `lemmasearch_proj_extraction` directory. First, extract the projects using the `unzip_file.py` script, then execute the extraction script `e.py`:
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