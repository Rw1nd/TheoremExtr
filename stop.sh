docker kill $(docker ps -a |grep lemma_extraction | awk '{print $1}')
docker container rm -f $(docker container ls -a |grep lemma_extraction | awk '{print $1}')
docker image rm -f $(docker image ls -a |grep lemma_extraction | awk '{print $1}')
