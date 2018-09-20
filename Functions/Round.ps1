function Round($num, $precision){
    # Convert a numerical type to a String
    $strNum = [string] $num
    $decimal = $strNum.IndexOf(".")
    
    # Check if there is a decimal
    if($decimal -gt -1){
        # We add 1 as we want to return the decimal with the number of precision
        return $strNum.substring(0, $decimal+$precision+1)
    }

    return strNum
}
