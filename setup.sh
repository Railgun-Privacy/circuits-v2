#! /bin/sh

echo "Generating artifacts"

if [ -d ./build ]; then
    rm -rf ./build/*.r1cs
    rm -rf ./build/*.zkey
else
  mkdir build
fi

cd build
POT=./pot16.ptau 

if [ ! -f $POT ]; then
curl https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_16.ptau -o $POT
fi

echo "Compiling circuits"
for FILE in ../src/*.circom; 
do 
  circom $FILE  --wasm --r1cs
done

echo "Generating initial zkeys"
for FILE in ./*.r1cs; 
do 
  SEED="${FILE%.*}.0000"
  ZKEY="${FILE%.*}.zkey"
  VKEY="${FILE%.*}.vkey.json"
  CONTRACT="${FILE%.*}.sol"

  ../node_modules/.bin/snarkjs g16s $FILE $POT $SEED
  ../node_modules/.bin/snarkjs zkc $SEED $ZKEY --name="dev" -v -e="random entropy"
  ../node_modules/.bin/snarkjs zkev $ZKEY $VKEY
done

rm -f *.tmp

echo "Done!"