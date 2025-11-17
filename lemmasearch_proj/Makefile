
PROJECTS_INSTALL = AAC_tactics menhir coq-elpi algebra-tactics math-comp-mathcomp mczify hierarchy-builder finmap bigenough analysis bignums compcert coq-equations coq-ext-lib coq-hott coq-simple-io coqeal real-closed coq-paramcoq multinomials coqprime coquelicot coqword coq-corn MathClasses coq-fcsl-pcm flocq coq-gappa coq-htt interval stdpp-coq-stdpp iris Cdcl LibHyps coq-unicoq mtac ott QuickChick reglang coq-relation-algebra vst coq-stdlib

.DEFAULT_GOAL := all
.PHONY : all 

all : install

install :  | $(PROJECTS_INSTALL)

AAC_tactics:
	cd aac-tactics-8.20.0   && make -j16 && make install

menhir:
	cd menhir-20240715-d71051f500c4f34c9faf93192a593cdf4903b0c0/coq-menhirlib  && make -j16 && make install

coq-elpi:
	cd coq-elpi-2.3.0   && make -j16 && make install

algebra-tactics: coq-elpi math-comp-mathcomp mczify
	cd algebra-tactics-1.2.3   && make -j16 && make install

math-comp-mathcomp: hierarchy-builder menhir
	cd math-comp-mathcomp-2.3.0/mathcomp   && make -j16 && make install

mczify: math-comp-mathcomp
	cd mczify-1.5.0-2.0-8.16   && make -j16 && make install

hierarchy-builder: menhir
	cd hierarchy-builder-1.8.0   && make -j16 && make install

finmap: math-comp-mathcomp
	cd finmap-2.2.0   && make -j16 && make install

bigenough : math-comp-mathcomp
	cd bigenough-1.0.1   && make -j16 && make install

analysis: math-comp-mathcomp finmap bigenough
	cd analysis-1.8.0   && make -j16 && make install

bignums:
	cd bignums-9.0.0-coq8.20   && make -j16 && make install

compcert: flocq menhir
	cd CompCert-3.15 && ./configure amd64-linux -prefix /home/opam/.opam/lemmaextraction -install-coqdev -clightgen -use-external-Flocq -use-external-MenhirLib -coqdevdir  /home/opam/.opam/lemmaextraction/lib/coq/user-contrib/compcert -ignore-coq-version && make all && make install all

coq-equations:
	cd Coq-Equations-1.3.1-8.20 && ./configure.sh  && make -j16 && make install

coq-ext-lib:
	cd coq-ext-lib-0.13.0   && make -j16 && make install

coq-hott:
	cd Coq-HoTT-8.20  && make -j16 && make install

coq-simple-io:
	cd coq-simple-io-1.10.0  && dune build && dune build -p coq-simple-io @install && dune install

coqeal: coq-paramcoq math-comp-mathcomp bignums real-closed multinomials
	cd coqeal-2.0.3   && make -j16 && make install

real-closed:  math-comp-mathcomp 
	cd real-closed-2.0.2   && make -j16 && make install

coq-paramcoq:
	cd paramcoq-1.1.3-coq8.20   && make -j16 && make install

multinomials: math-comp-mathcomp bigenough finmap
	cd multinomials-2.3.0   && make -j16 && make install

coqprime: bignums
	cd coqprime-8.20   && make -j16 && make install

coquelicot:
	cd coquelicot-3.4.2 && ./configure && ./remake && ./remake install

coqword:
	cd coqword-3.2   && make -j16 && dune install

coq-corn: coq-elpi bignums MathClasses
	cd corn-8.20.0 && ./configure.sh  && make -j16 && make install

MathClasses:
	cd math-classes-8.19.0 && ./configure.sh  && make -j16 && make install

coq-fcsl-pcm: hierarchy-builder math-comp-mathcomp
	cd fcsl-pcm-2.1.0   && make -j16 && make install

flocq:
	cd flocq-4.2.0 && ./configure && ./remake && ./remake install

coq-gappa:
	cd gappalib-coq-1.5.5 && ./configure && ./remake && ./remake install

coq-htt: math-comp-mathcomp
	cd htt-2.1.0   && make -j16 && make install

interval:
	cd interval-4.11.1 && ./configure && ./remake && ./remake install

stdpp-coq-stdpp:
	cd stdpp-coq-stdpp-1.11.0   && make -j16 && make install

iris: stdpp-coq-stdpp
	cd iris-iris-4.3.0-3d176f124f708e7325a362722c3d2b3957e3675d   && make -j16 && make install

Cdcl: mczify
	cd itauto-8.20.0   && make -j16 && make install

LibHyps:
	cd LibHyps-3.0.1 && ./configure.sh  && make -j16 && make install

coq-unicoq:
	cd unicoq-1.6-8.20 && coq_makefile -f _CoqProject -o Makefile  && make -j16 && make install

mtac: coq-unicoq
	cd Mtac2-1.4-coq8.20 && ./configure.sh  && make -j16 && make install

ott:
	cd ott-0.34/coq  && make -j16 && make install

QuickChick: coq-ext-lib coq-simple-io math-comp-mathcomp
	cd QuickChick-2.0.5   && make -j16 && make install

reglang: math-comp-mathcomp hierarchy-builder
	cd reglang-1.2.1  && make -j16 && make install

coq-relation-algebra: math-comp-mathcomp AAC_tactics menhir
	cd relation-algebra-1.7.11  && ./configure --enable-ssr --enable-aac && make -j16 && make install

vst:
	cd VST-2.15   && make -j16 && make install
