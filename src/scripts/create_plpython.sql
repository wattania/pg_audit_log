CREATE OR REPLACE FUNCTION create_language_plpython()
RETURNS BOOLEAN AS $$
    CREATE LANGUAGE plpythonu;
    SELECT TRUE;
$$ LANGUAGE SQL;

SELECT CASE WHEN NOT
    (
        SELECT  TRUE AS exists
        FROM    pg_language
        WHERE   lanname = 'plpythonu'
        UNION
        SELECT  FALSE AS exists
        ORDER BY exists DESC
        LIMIT 1
    )
THEN
    create_language_plpython()
ELSE
    FALSE
END AS plpgsql_created;

DROP FUNCTION create_language_plpython();