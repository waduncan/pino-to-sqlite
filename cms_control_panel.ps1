Import-Module PSSQLite
$database = ".\sqlite\test.db"


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$ControlPanelMain                   = New-Object system.Windows.Forms.Form
$ControlPanelMain.ClientSize        = New-Object System.Drawing.Point(800,800)
$ControlPanelMain.text              = "Log Query Tool"
$ControlPanelMain.TopMost           = $false

$QueryResultsTable                 = New-Object system.Windows.Forms.DataGridView
$QueryResultsTable.Width           = 700
$QueryResultsTable.height          = 200
$QueryResultsTable.location        = New-Object System.Drawing.Point(50,100)
$QueryResultsTable.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$QueryResultsTable.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$QueryResultsTable.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$QueryResultsTable.AutoResizeColumns([System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::AllCellsExceptHeader)




$QueryInputBox                    = New-Object system.Windows.Forms.TextBox 
$QueryInputBox.multiline          = $true
$QueryInputBox.width              = 700
$QueryInputBox.height             = 100
$QueryInputBox.location           = New-Object System.Drawing.Point(50,500)
$QueryInputBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',8)




$ExecuteBtn                     = New-Object system.Windows.Forms.Button
$ExecuteBtn.text                = "Execute"
$ExecuteBtn.width               = 150
$ExecuteBtn.height              = 30
$ExecuteBtn.location            = New-Object System.Drawing.Point(50,39)
$ExecuteBtn.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',8)



$default_query = "SELECT * FROM json_log limit 10;"

$QueryInputBox.Text = $default_query

$results = Invoke-SqliteQuery -DataSource $database -Query $default_query
$dataTable = $results | Out-DataTable

$QueryResultsTable.DataSource = $dataTable






$ControlPanelMain.controls.AddRange(@(
    $ExecuteBtn,
    $QueryInputBox,
    $QueryResultsTable
    ))

$ExecuteBtn.Add_Click({execute_query})

function formatRows {
    $rows = $QueryResultsTable.Rows
    foreach ($row in $rows) {
        if($row.Cells[0].Value -eq "ERROR"){
            $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::Red
        }
    }
}

function execute_query {
    $QueryResultsTable.DataSource = $null
    $query = $QueryInputBox.Text
    try{
        $results = Invoke-SqliteQuery -DataSource $database -Query $query -ErrorAction Stop
        $dataTable = $results | Out-DataTable
        $QueryResultsTable.DataSource = $dataTable
    }
    catch{
        $QueryResultsTable.DataSource = $null
        #message box error
        $msg = "Error: " + $_.Exception.Message
        [System.Windows.Forms.MessageBox]::Show($msg, 'Error', 'OK', 'Error')

    }
    $results = Invoke-SqliteQuery -DataSource $database -Query $query
    $dataTable = $results | Out-DataTable

    $QueryResultsTable.DataSource = $dataTable

}



$ControlPanelMain.ShowDialog()



