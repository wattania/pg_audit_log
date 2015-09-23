fs      = require 'fs'
path    = require 'path'
async   = require 'async'
log4js  = require 'log4js'
_       = require 'underscore'
moment  = require 'moment'
pg      = require 'pg'
yaml    = require 'js-yaml'

CHANNEL = "PG_LOG"

log_filename = "/logs/" + (moment(new Date()).format 'YYYYMMDD') + ".log"
appenders = [
  type: 'console'
  absolute: true
  filename: log_filename
  layout: type: 'pattern', pattern: "[%d{ISO8601}][%p] - [#{CHANNEL}] %m "
  alwaysIncludePattern: true
]

log4js.configure appenders: appenders
log = log4js.getLogger()

config          = yaml.safeLoad fs.readFileSync (path.join __dirname, 'config.yml'), 'utf8'
stmt_trigger    = fs.readFileSync (path.join __dirname, 'scripts', 'create_trigger.sql'), 'utf8'
stmt_list_table = fs.readFileSync (path.join __dirname, 'scripts', 'list_all_table.sql'), 'utf8'
stmt_fn         = fs.readFileSync (path.join __dirname, 'scripts', 'fn_audit_log.sql'), 'utf8'

pg.connect config.conn, (err, client, done)->
  return console.error 'error fetching client from pool', err if err
   
  client.on 'notification', (msg)-> log.debug msg.payload 

  async.waterfall [
    (next)->
      client.query stmt_fn, next

    (result, next)->
      client.query stmt_list_table, next
  ,
    (results, next)->
      async.mapSeries results.rows, (row, next)-> 
        client.query stmt_trigger.split("<table>").join("\"#{row.table_name}\""), next

      , next

  , (results, next)->
    client.query "LISTEN #{CHANNEL}", [], next

  ], (err)->
    done client if err