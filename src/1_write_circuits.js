/* eslint-disable no-plusplus */
const fs = require('fs');

function template(nInputs, nOutputs) {
  return `pragma circom 2.0.6;
include "./library/joinsplit.circom";

component main{public [merkleRoot, boundParamsHash, nullifiers, commitmentsOut]} = JoinSplit(${nInputs}, ${nOutputs},16);`;
}

function main(){
  fs.writeFileSync(`./joinsplit_1x1.circom`, template(1,1));
  fs.writeFileSync(`./joinsplit_1x10.circom`, template(1,10));
  fs.writeFileSync(`./joinsplit_1x13.circom`, template(1,13));

  fs.writeFileSync(`./joinsplit_10x1.circom`, template(10,1));
  fs.writeFileSync(`./joinsplit_10x2.circom`, template(10,2));
  fs.writeFileSync(`./joinsplit_10x3.circom`, template(10,3));
  fs.writeFileSync(`./joinsplit_10x4.circom`, template(10,4));

  fs.writeFileSync(`./joinsplit_11x1.circom`, template(11,1));
  fs.writeFileSync(`./joinsplit_12x1.circom`, template(12,1));
  fs.writeFileSync(`./joinsplit_13x1.circom`, template(13,1));
  
  for(let i=1; i<=9; i++) {
    for(let j=2; j<=5; j++) {
      fs.writeFileSync(`./joinsplit_${i}x${j}.circom`, template(i,j));
    }
  }
};

if (require.main === module) {
  main();
}