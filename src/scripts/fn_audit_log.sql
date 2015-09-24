CREATE OR REPLACE FUNCTION fn_audit_log()
  RETURNS trigger AS
$BODY$
    
## python script here ###
import os, sys, time
import collections

USE_NOTIFY = True
NOTIFY_CHANNEL = "PG_LOG"

if not USE_NOTIFY:
  import logging
  LOG_FILENAME = os.path.join(os.getcwd(), 'plpython.log')
  logging.basicConfig(filename=LOG_FILENAME, level=logging.DEBUG)
  #logging.debug('============================================')
  #logging.debug('python version: %s' % sys.version)
  
class MyLogging:
  def __init__(self, td):
    self.td         = td
    self.table_name = td["table_name"]
    self.new        = td["new"]
    self.old        = td["old"]
    self.event      = td["event"]

  def timestamp(self):
    return time.strftime('[%Y-%m-%d %H:%M:%S]') + " [DEBUG] :"

  def init_ret(self, rec):
    return [
      #"%s %s TABLE %s -> " % (self.timestamp(), self.event, self.table_name),
      "%s -> %s (id %s) " % (self.event, self.table_name, rec['id'])
    ]

  def update_event(self):
    ret = self.init_ret(self.new) 
    for field in sorted(self.new.iterkeys()):
      new_value = self.new[field]
      old_value = self.old[field]

      if new_value or old_value:
        if not (new_value == old_value):
          ret.append("%s(%s => %s) " % (field, old_value, new_value))
    
    return "".join([str(x) for x in ret])
    
  def insert_event(self):
    ret = self.init_ret(self.new)
    for field in sorted(self.new.iterkeys()):
      value = self.new[field]
      if value and (str(field) != "id"):
        ret.append("%s(%s) " % (field, value ))

    return "".join([str(x) for x in ret])

  def delete_event(self):
    ret = self.init_ret(self.old) 
    for field in sorted(self.old.iterkeys()):
      value = self.old[field]
      if value and (str(field) != "id"):
        ret.append("%s(%s) " % (field, value))
      
    return "".join([str(x) for x in ret])

  def parse(self):
    if self.event == 'INSERT':
      return self.insert_event()

    elif self.event == 'UPDATE':
      return self.update_event()

    elif self.event == 'DELETE':
      return self.delete_event()

    else:
      return ""

payload = MyLogging(TD).parse()
if payload:
  if USE_NOTIFY:
    #logging.debug("=Notify=")
    payload = payload.replace("'", "''")
    plpy.execute("NOTIFY %s, '%s'" % (NOTIFY_CHANNEL, payload))
    #plpy.execute("NOTIFY PG_LOG, 'ss'")
  else:
    logging.debug(payload)
    
$BODY$
  LANGUAGE plpythonu VOLATILE
  COST 100;
ALTER FUNCTION fn_audit_log()
  OWNER TO aboss;