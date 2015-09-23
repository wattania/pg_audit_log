fs      = require 'fs'
path    = require 'path'
async   = require 'async'
log4js  = require 'log4js'
_       = require 'underscore'
moment  = require 'moment'
pg      = require 'pg'
yaml    = require 'js-yaml'

CHANNEL = "PG_LOG"
appenders = [
  type: 'file'
  absolute: true
  filename: "/logs/" + (moment(new Date()).format 'YYYY') + ".log"
  layout: type: 'pattern', pattern: "[%d{ISO8601}][%p] - [#{CHANNEL}] %m "
  alwaysIncludePattern: true
]

log4js.configure appenders: appenders
log = log4js.getLogger()

config = yaml.safeLoad fs.readFileSync (path.join __dirname, 'config.yml'), 'utf8'
pg.connect config.conn, (err, client, done)->
  return console.error 'error fetching client from pool', err if err
  client.on 'notification', (msg)->
    #console.log msg.payload
    log.debug msg.payload
  
  client.query "LISTEN #{CHANNEL}", [], (err, result)->
    if err
      return console.error 'error running query', err

    