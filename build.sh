docker build -t "lemma_extraction" .
docker run -dit -v $(pwd):/home/opam/data lemma_extraction /bin/bash