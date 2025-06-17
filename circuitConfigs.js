const circuitConfigs = [];

// Every combination of nullifierCount and commitmentCount where nullifierCount + commitmentCount + 3 <= 17
for (let nullifierCount = 1; nullifierCount <= 14; nullifierCount += 1) {
  for (let commitmentCount = 1; commitmentCount <= 14 - nullifierCount; commitmentCount += 1) {
    circuitConfigs.push({
      nullifierCount,
      commitmentCount
    });
  }
}

module.exports = circuitConfigs;
