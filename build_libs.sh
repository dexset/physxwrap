#!/bin/sh
echo "Building physx wrap"
DIR=$(dirname ${BASH_SOURCE[0]})
cd $DIR
if [ ! -d libs ]; then
    mkdir libs
fi
g++ -DNDEBUG -w -c ./src/wrap.cpp -o ./libs/wrap.o &&
ar rcs ./libs/libdphysx.a ./libs/wrap.o
rm ./libs/wrap.o
