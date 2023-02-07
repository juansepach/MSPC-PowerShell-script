Function Get-CSVFileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

Get-ChildItem $PSScriptRoot *.ps1 | 
  ForEach-Object {
    . $_.FullName
  }
Export-ModuleMember -Function Convert-CSV, Get-CSVDelimiter, Get-CSVFileName
