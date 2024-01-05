Import-Module PSSQLite
$database = ".\sqlite\test.db"


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$ControlPanelMain = New-Object system.Windows.Forms.Form
$ControlPanelMain.ClientSize = New-Object System.Drawing.Point(800, 800)
$ControlPanelMain.text = "Log Query Tool"
$ControlPanelMain.TopMost = $false

$RowDetailPopOut = New-Object system.Windows.Forms.Form
$RowDetailPopOut.ClientSize = New-Object System.Drawing.Point(500, 500)
$RowDetailPopOut.text = "Row Detail"
$RowDetailPopOut.TopMost = $false

$RowDetailTextBox = New-Object system.Windows.Forms.TextBox
$RowDetailTextBox.multiline = $true
$RowDetailTextBox.AutoSize = $true
$RowDetailTextBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$RowDetailTextBox.width = 500
$RowDetailTextBox.height = 500
$RowDetailTextBox.location = New-Object System.Drawing.Point(0, 0)
$RowDetailTextBox.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 8);




$QueryResultsTable = New-Object system.Windows.Forms.DataGridView
$QueryResultsTable.Width = 700
$QueryResultsTable.height = 200
$QueryResultsTable.location = New-Object System.Drawing.Point(50, 100)
$QueryResultsTable.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 8)
$QueryResultsTable.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$QueryResultsTable.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$QueryResultsTable.AutoResizeColumns([System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::AllCellsExceptHeader)
$QueryResultsTable.RowTemplate.DefaultCellStyle.WrapMode = [System.Windows.Forms.DataGridViewTriState]::True
$QueryResultsTable.RowTemplate.DefaultCellStyle.Alignment = [System.Windows.Forms.DataGridViewContentAlignment]::TopLeft


function PrettyPrintJson {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $json
    )
    $json | ConvertFrom-Json | ConvertTo-Json -Depth 100
}

#Add an event handler for the RowStateChanged event to handle row selection
$QueryResultsTable.add_RowStateChanged({
        param($sender, $e)
        if ($e.StateChanged -eq [System.Windows.Forms.DataGridViewElementStates]::Selected) {
            $row = $QueryResultsTable.SelectedRows[0]
            #$row_data = $row.DataBoundItem

            #cleaned up cell value, removed all tabs, newlines, and carriage returns, also replace single backslashes with 4 backslashes
            $err_stack = $row.Cells[13].Value -replace "`t|`n|`r", "" -replace "\\", "\\\\"
            write-host $err_stack

            #build JSON formatted string from $row 
            $row_data = "{"
            $row_data += "`"level`":`"" + $row.Cells[0].Value + "`","
            $row_data += "`"time`":`"" + $row.Cells[1].Value + "`","
            $row_data += "`"pid`":`"" + $row.Cells[2].Value + "`","
            $row_data += "`"reqId`":`"" + $row.Cells[3].Value + "`","
            $row_data += "`"req_method`":`"" + $row.Cells[4].Value + "`","
            $row_data += "`"req_url`":`"" + $row.Cells[5].Value + "`","
            $row_data += "`"req_hostname`":`"" + $row.Cells[6].Value + "`","
            $row_data += "`"req_remoteaddress`":`"" + $row.Cells[7].Value + "`","
            $row_data += "`"req_remoteport`":`"" + $row.Cells[8].Value + "`","
            $row_data += "`"res_status_code`":`"" + $row.Cells[9].Value + "`","
            $row_data += "`"err_type`":`"" + $row.Cells[11].Value + "`","
            $row_data += "`"err_message`":`"" + $row.Cells[12].Value + "`","
            # $row_data += "`"err_stack`":`"" + $row.Cells[13].Value + "`","
            $row_data += "`"err_stack`":`"" + $err_stack + "`","
            $row_data += "`"msg`":`"" + $row.Cells[14].Value + "`""
            $row_data += "}"
        
            $json_formatted = $row_data | convertfrom-json | ConvertTo-Json -Depth 100 
    
        
            $RowDetailPopOut.Controls.Clear()
            $RowDetailPopOut.Controls.Add($RowDetailTextBox)
            $RowDetailTextBox.Text = $json_formatted
            $RowDetailPopOut.ShowDialog()
        }
        else {
            $panel.Visible = $false
        }
    })









$QueryInputBox = New-Object system.Windows.Forms.TextBox 
$QueryInputBox.multiline = $true
$QueryInputBox.width = 700
$QueryInputBox.height = 100
$QueryInputBox.location = New-Object System.Drawing.Point(50, 500)
$QueryInputBox.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 8)




$ExecuteBtn = New-Object system.Windows.Forms.Button
$ExecuteBtn.text = "Execute Query"
$ExecuteBtn.width = 150
$ExecuteBtn.height = 30
$ExecuteBtn.location = New-Object System.Drawing.Point(50, 39)
$ExecuteBtn.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 8)

$FindErrorBtn = New-Object system.Windows.Forms.Button
$FindErrorBtn.text = "Find Errors"
$FindErrorBtn.width = 150
$FindErrorBtn.height = 30
$FindErrorBtn.location = New-Object System.Drawing.Point(300, 39)
$FindErrorBtn.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 8)




$default_query = "SELECT * FROM json_log limit 10;"
$find_errors_query = "SELECT * FROM json_log WHERE level = 50;"

$QueryInputBox.Text = $default_query







$ControlPanelMain.controls.AddRange(@(
        $ExecuteBtn,
        $QueryInputBox,
        $QueryResultsTable,
        $FindErrorBtn
    ))

$ExecuteBtn.Add_Click({ execute_query($QueryInputBox.Text) })
$FindErrorBtn.Add_Click({ findErrors })

function formatRows {

}
function findErrors() {
    $QueryInputBox.Text = $find_errors_query
    execute_query($QueryInputBox.Text)
}
function execute_query ($query) {
    $QueryResultsTable.DataSource = $null
    $query = $QueryInputBox.Text
    try {
        $results = Invoke-SqliteQuery -DataSource $database -Query $query -ErrorAction Stop
        $dataTable = $results | Out-DataTable
        $QueryResultsTable.DataSource = $dataTable

        
    }
    catch {
        $QueryResultsTable.DataSource = $null
        #message box error
        $msg = "Error: " + $_.Exception.Message
        [System.Windows.Forms.MessageBox]::Show($msg, 'Error', 'OK', 'Error')

    }
    finally {
        $results = Invoke-SqliteQuery -DataSource $database -Query $query

        $dataTable = $results | Out-DataTable

        $QueryResultsTable.DataSource = $dataTable

        #format row color to show red if level 50
        $QueryResultsTable.Rows | % {
            if ($_.Cells[0].Value -eq "50") {
                $_.DefaultCellStyle.BackColor = [System.Drawing.Color]::Red
            }
        }
    }
}



$ControlPanelMain.ShowDialog()



