import-module PSSQLite

$json_file = "C:\node\CMS2023Back\logs\trace.log"

$json_object = get-content $json_file

$database = ".\sqlite\test.db"

#clear out the table
$ClearTablequery = "DELETE FROM json_log;"
Invoke-SqliteQuery -DataSource $database -Query $ClearTablequery


$output = $json_object | ConvertFrom-Json 

#convert output to custom object
$pscustom = $output | % {
    $level = $_.level
    $time = $_.time
    $_pid = $_.pid
    $reqId = $_.reqId
    $req_method = $_.req.method
    $req_url = $_.req.url
    $req_hostname = $_.req.hostname
    $req_remoteaddress = $_.req.remoteAddress
    $req_remoteport = $_.req.remotePort
    $res_status_code = $_.res.statusCode
    $err = $_.err
    $err_type = $_.err.type
    $err_message = $_.err.message
    $err_stack = $_.err.stack
    $msg = $_.msg

    New-Object PSObject -Property @{
        level = $level
        time = $time
        pid = $_pid
        reqId = $reqId
        req_method = $req_method
        req_url = $req_url
        req_hostname = $req_hostname
        req_remoteaddress = $req_remoteaddress
        req_remoteport = $req_remoteport
        res_status_code = $res_status_code
        err = $err
        err_type = $err_type
        err_message = $err_message
        err_stack = $err_stack
        msg = $msg
    }
}

$custom_data_object = $pscustom | Out-DataTable

#insert into table via bulk insert
Invoke-SQLiteBulkCopy -DataTable $custom_data_object -DataSource $database -Table json_log -NotifyAfter 0 -Force




function select_all_logs {
    $query = "SELECT * FROM json_log;"
    Invoke-SqliteQuery -DataSource $database -Query $query
}   




