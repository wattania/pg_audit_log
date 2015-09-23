SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type != 'VIEW'
ORDER BY table_schema,table_name;