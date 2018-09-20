function Get-Filename($title, $filter){
    # https://gallery.technet.microsoft.com/scriptcenter/GUI-popup-FileOpenDialog-babd911d

    Start-Sleep -s 2
    $openFileDialog = New-Object windows.forms.openfiledialog
    $openFileDialog.initialDirectory = [System.IO.Directory]::GetCurrentDirectory()
    $openFileDialog.title = $title
    $openFileDialog.filter = $filter
    $results = $openFileDialog.ShowDialog()   # Display the Dialog / Wait for user response
    if($results -imatch "OK"){
        return $openFileDialog.filename
    }
    return $FALSE
}