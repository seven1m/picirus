Config = require('../lib/config')
GLOBAL.CONFIG = new Config
  paths:
    account: 'test-data/:provider-:uid'
    database: 'data.sqlite3'
