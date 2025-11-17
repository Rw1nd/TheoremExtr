
PROJECTS_INSTALL = AAC_tactics menhir coq-elpi algebra-tactics math-comp-mathcomp mczify hierarchy-builder finmap bigenough analysis bignums compcert coq-equations coq-ext-lib coq-hott coq-simple-io coqeal real-closed coq-paramcoq multinomials coqprime coquelicot coqword coq-corn MathClasses coq-fcsl-pcm flocq coq-gappa coq-htt interval stdpp-coq-stdpp iris Cdcl LibHyps coq-unicoq mtac ott QuickChick reglang coq-relation-algebra vst coq-stdlib

.DEFAULT_GOAL := all
.PHONY : all 

all : install

install :  | $(PROJECTS_INSTALL)

AAC_tactics:
	cd aac-tactics-8.20.0   && make -j16 

menhir:
	cd menhir-20240715-d71051f500c4f34c9faf93192a593cdf4903b0c0/coq-menhirlib  && make -j16 

coq-elpi:
	cd coq-elpi-2.3.0   && make -j16 

algebra-tactics: 
	cd algebra-tactics-1.2.3   && make -j16 

math-comp-mathcomp: 
	cd math-comp-mathcomp-2.3.0/mathcomp && make clean  && make -j16 

mczify:
	cd mczify-1.5.0-2.0-8.16   && make -j16 

hierarchy-builder: 
	cd hierarchy-builder-1.8.0   && make -j16 

finmap:
	cd finmap-2.2.0   && make -j16 

bigenough :
	cd bigenough-1.0.1   && make -j16 

analysis:
	cd analysis-1.8.0   && make -j16 

bignums:
	cd bignums-9.0.0-coq8.20   && make -j16 

compcert: 
	cd CompCert-3.15 && ./configure amd64-linux -prefix /home/opam/.opam/lemmaextraction -install-coqdev -clightgen -use-external-Flocq -use-external-MenhirLib -coqdevdir  /home/opam/.opam/lemmaextraction/lib/coq/user-contrib/compcert -ignore-coq-version && make all

coq-equations:
	cd Coq-Equations-1.3.1-8.20 && ./configure.sh  && make -j16 

coq-ext-lib:
	cd coq-ext-lib-0.13.0   && make -j16 

coq-hott:
	cd Coq-HoTT-8.20  && make -j16 

coq-simple-io:
	cd coq-simple-io-1.10.0  && dune build

coqeal:
	cd coqeal-2.0.3   && make -j16 

real-closed: 
	cd real-closed-2.0.2   && make -j16 

coq-paramcoq:
	cd paramcoq-1.1.3-coq8.20   && make -j16 

multinomials: 
	cd multinomials-2.3.0 && make clean  && make -j16 

coqprime: 
	cd coqprime-8.20   && make -j16 

coquelicot:
	cd coquelicot-3.4.2 && ./configure && ./remake

coqword:
	cd coqword-3.2   && make -j16 

coq-corn: 
	cd corn-8.20.0 && ./configure.sh  && make -j16 

MathClasses:
	cd math-classes-8.19.0 && ./configure.sh  && make -j16 

coq-fcsl-pcm: 
	cd fcsl-pcm-2.1.0   && make -j16 

flocq:
	cd flocq-4.2.0 && ./configure && ./remake 

coq-gappa:
	cd gappalib-coq-1.5.5 && ./configure && ./remake 

coq-htt:
	cd htt-2.1.0   && make -j16 

interval:
	cd interval-4.11.1 && ./configure && ./remake 

stdpp-coq-stdpp:
	cd stdpp-coq-stdpp-1.11.0   && make -j16 

iris: 
	cd iris-iris-4.3.0-3d176f124f708e7325a362722c3d2b3957e3675d   && make -j16 

Cdcl: 
	cd itauto-8.20.0   && make -j16 

LibHyps:
	cd LibHyps-3.0.1 && ./configure.sh  && make -j16 

coq-unicoq:
	cd unicoq-1.6-8.20 && coq_makefile -f _CoqProject -o Makefile  && make -j16 

mtac: 
	cd Mtac2-1.4-coq8.20 && ./configure.sh  && make -j16 

ott:
	cd ott-0.34/coq  && make -j16 

QuickChick:
	cd QuickChick-2.0.5   && make -j16 

reglang: 
	cd reglang-1.2.1  && make -j16 

coq-relation-algebra:
	cd relation-algebra-1.7.11  && ./configure --enable-ssr --enable-aac && make -j16 

vst:
	cd VST-2.15   && make -j16 

coq-stdlib:
	cd rocq  && dune clean && make dunestrap && dune build -p coq-core,coq-stdlib,coq