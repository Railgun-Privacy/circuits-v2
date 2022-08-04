/* eslint-disable no-plusplus */
const fs = require('fs');

function template(nInputs, nOutputs) {
  return `pragma circom 2.0.6;
include "./library/joinsplit.circom";

component main{public [merkleRoot, boundParamsHash, nullifiers, commitmentsOut]} = JoinSplit(${nInputs}, ${nOutputs},16);`;
}

function main(){
  fs.writeFileSync(`./joinsplit_1x1.circom`, template(1,1));
  fs.writeFileSync(`./joinsplit_1x10.circom`, template(1,1));
  for(let i=1; i<=10; i++) {
    for(let j=2; j<=5; j++) {
      fs.writeFileSync(`./joinsplit_${i}x${j}.circom`, template(i,j));
    }
  }
};

if (require.main === module) {
  main();
}