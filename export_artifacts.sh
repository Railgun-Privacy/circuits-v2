#! /bin/sh

echo "Generating artifacts"

if [ -d ./build ]; then
  rm -rf ./build
fi

mkdir build && cd build

echo "Compiling circuits"
for FILE in ../src/*.circom; do 
  circom $FILE --c --json --r1cs --sym --wasm --wat
done

echo "Done!"
