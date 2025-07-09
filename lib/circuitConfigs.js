const circuitConfigs = [];

// Every combination of nullifiers and commitments where nullifiers + commitments + 3 <= 17
for (let nullifiers = 1; nullifiers <= 14; nullifiers += 1) {
  for (let commitments = 1; commitments <= 14 - nullifiers; commitments += 1) {
    circuitConfigs.push({
      nullifiers,
      commitments,
    });
  }
}

module.exports = circuitConfigs;
