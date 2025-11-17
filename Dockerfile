FROM ocaml/opam:ubuntu-22.04-ocaml-4.14

RUN opam upgrade -y
RUN opam switch create lemmaextraction 4.14.1
RUN eval $(opam env --set-switch --switch=lemmaextraction)

RUN sudo apt-get update && sudo apt-get -y dist-upgrade && \
    sudo apt-get install -y lib32z1 xinetd && \
     sudo apt-get install -y pkg-config && \
    sudo apt-get install -y libgmp-dev && \
    sudo apt-get install -y python3 && \
    sudo apt-get install -y build-essential  && \
    sudo apt-get install -y git-all  && \
    sudo apt-get install -y python3-pip

RUN sudo apt-get -y install libgtksourceview-3.0-dev
RUN opam install -y dune ocamlfind zarith lablgtk3-sourceview3 yojson.2.2.2 
RUN opam install -y ppx_optcomp odoc ocaml-lsp-server stdlib-shims elpi.2.0.7 ocamlgraph
RUN opam repo add coq-released https://coq.inria.fr/opam/released