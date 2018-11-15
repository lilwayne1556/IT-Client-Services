function Separate-Owner-Field-Samanage($Owner){
    $Separation = $Owner.Split("~")
    return $Separation[1].Split('"')[1]
}