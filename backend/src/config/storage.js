const config = require('./index');

let storage;

if (config.storageType === 'local') {
  storage = require('../storage/local');
} else if (config.storageType === 'oss') {
  storage = require('../storage/oss');
} else {
  throw new Error(`Unsupported storage type: ${config.storageType}`);
}

module.exports = storage;
