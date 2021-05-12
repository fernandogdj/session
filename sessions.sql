SELECT SES.STATUS,
      to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'),nvl(ses.username,'ORACLE PROC')||' ('||ses.sid||')' || '-' || client_info USERNAME,
       SID, ses.module,
      ltrim(to_char(floor(SES.LAST_CALL_ET/3600), '09')) || ':'
       || ltrim(to_char(floor(mod(SES.LAST_CALL_ET, 3600)/60), '09')) || ':'
       || ltrim(to_char(mod(SES.LAST_CALL_ET, 60), '09'))    RUNT,  --sql.piece,
  (select sw.event "Wait Event" from   v$session_wait sw where  sw.wait_class not in ( 'Idle', 'Network') and sw.sid = SES.sid ) evento,
       SQL.HASH_VALUE,SQL.SQL_ID,REPLACE(SQL.SQL_TEXT,CHR(10),'') STMT,
  (select  sw.p1text ||' = '|| sw.p1 ||', '|| sw.p2text||' = '|| sw.p2 || ', ' || sw.p3text || ' = ' || sw.p3 from   v$session_wait sw where  sw.wait_class not in ( 'Idle', 'Network') and sw.sid = SES.sid) param,
       MACHINE
  FROM V$SESSION SES,  
       V$SQLtext_with_newlines SQL  
 where --SES.STATUS = 'ACTIVE' and
    SES.USERNAME is not null
   AND SES.SQL_ADDRESS    = SQL.ADDRESS(+)
   and SES.SQL_HASH_VALUE = SQL.HASH_VALUE(+)
   and Ses.AUDSID <> userenv('SESSIONID')
   AND SES.SID in (select distinct sw.sid "Sess|ID"
from   v$session_wait sw, v$session x
where    sw.wait_class not in ( 'Idle', 'Network')
  and  x.username is not null --not in  ( 'SYSTEM','SYS')
  and x.sid = sw.sid)
  AND (sql.piece = 0 or sql.piece is null)
 order by runt desc,client_info, 1,sql.piece;
