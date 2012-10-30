os = require('os')

ifs = os.networkInterfaces()
ips = []
for d of ifs
  for ip in ifs[d] when ip.family == 'IPv4' and ip.address != '127.0.0.1'
    ips.push ip.address

class BasePlugin

  constructor: (app) ->
    # FIXME switching to the ip probably won't work reliably
    @host = "#{ips[0]}#{(p = app.get 'port') != 80 && ':'+p || ''}"
    @setup(app)

  redirect: (req, res) =>
    res.redirect '/accounts'

module.exports = BasePlugin
