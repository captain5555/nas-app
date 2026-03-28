const config = require('./index');

let db;

if (config.databaseType === 'sqlite') {
  db = require('../db/sqlite');
} else if (config.databaseType === 'postgres') {
  db = require('../db/postgres');
} else {
  throw new Error(`Unsupported database type: ${config.databaseType}`);
}

module.exports = db;
