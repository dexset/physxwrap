#!/bin/sh
echo "Building physx wrap"
DIR=$(dirname ${BASH_SOURCE[0]})
cd $DIR
if [ ! -d libs ]; then
    mkdir libs
fi
g++ -DNDEBUG -w -c ./src/wrap.cpp -o ./lib/wrap.o &&
ar rcs ./lib/libdphysx.a ./lib/wrap.o
rm ./lib/wrap.o
