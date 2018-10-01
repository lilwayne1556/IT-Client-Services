function Get-Filename($title, $filter){
    # https://gallery.technet.microsoft.com/scriptcenter/GUI-popup-FileOpenDialog-babd911d

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.initialDirectory = [System.IO.Directory]::GetCurrentDirectory()
    $openFileDialog.title = $title
    $openFileDialog.filter = $filter
    $results = $openFileDialog.ShowDialog()   # Display the Dialog / Wait for user response
    if($results -imatch "OK"){
        return $openFileDialog.filename
    }
    return $FALSE
}
