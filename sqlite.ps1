Import-Module PSSQLite

$database = ".\sqlite\test.db"

$query = "DROP TABLE IF EXISTS json_log; CREATE TABLE IF NOT EXISTS json_log (
    level TEXT,
    time INT, 
    pid INT, 
    reqId TEXT, 
    req_method TEXT, 
    req_url TEXT, 
    req_hostname TEXT, 
    req_remoteaddress TEXT, 
    req_remoteport TEXT, 
    res_status_code TEXT,
    err TEXT, 
    err_type TEXT,
    err_message TEXT,
    err_stack TEXT,
    msg TEXT 
    );";



Invoke-SqliteQuery -DataSource $database -Query $query





