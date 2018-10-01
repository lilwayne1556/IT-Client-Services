function Round($num, $precision){
    # Convert a numerical type to a String
    [String] $strNum = $num
    $decimal = $strNum.IndexOf(".")
    # Check if there is a decimal
    if($decimal -gt -1){
        # We do this workaround to get the number of decimals we want
        return $strNum.substring(0, ($decimal+$precision+$decimal))
    }

    return $num
}
