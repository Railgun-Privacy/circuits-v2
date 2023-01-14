#! /bin/sh

echo "Generating artifacts"

if [ -d ./build ]; then
  rm -rf ./build
fi

mkdir build && cd build
POT=../pot20.ptau 

if [ ! -f $POT ]; then
curl https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_20.ptau -o $POT
fi

echo "Compiling circuits"
for FILE in ../src/*.circom; do 
  circom $FILE  --c --r1cs --wasm
done

echo "Generating initial zkeys"
for FILE in ./*.r1cs; do 
  SEED="${FILE%.*}.00.zkey"

  ../node_modules/.bin/snarkjs g16s $FILE $POT $SEED
done

rm -f *.0000

echo "Done!"
