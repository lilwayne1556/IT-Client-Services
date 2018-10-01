Function Get-Folder($Title){
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $Title

    if($foldername.ShowDialog() -eq "OK"){
        return $foldername.SelectedPath
    }
    return $FALSE
}
