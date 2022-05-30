try {
    $ciEnc = [console]::InputEncoding
    $coEnc = [console]::OutputEncoding
    $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding        
    $Global:promptPrimary = &oh-my-posh print -p primary 
    $Global:promptSecondary = &oh-my-posh print -p secondary
    $Global:promptDebug = &oh-my-posh print -p debug
}
finally {
    [console]::InputEncoding = $ciEnc
    [console]::OutputEncoding = $coEnc
}
 
Set-PSReadLineKeyHandler -Key " " `
    -BriefDescription ValidatePrograms `
    -LongDescription "Validate typed program's existance in path variable" `
    -ScriptBlock {
    param($key, $arg)

    try {     
        
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")            
        $ast = $null; $tokens = $null ; $errors = $null; $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)  
        $cursorPosY = $host.UI.RawUI.CursorPosition.Y
        $token = $tokens[0]
        $scanY = $cursorPosY
        $completeBufStr = New-Object System.Text.StringBuilder
        $foundIndex = -1
        $offset = 0
        while ($foundIndex -eq -1) {
            $rec = New-Object System.Management.Automation.Host.Rectangle(0, $scanY, $host.ui.RawUI.BufferSize.Width, $scanY)
            $buf = $host.UI.RawUI.GetBufferContents($rec)     
            $lineInBuf = New-Object System.Text.StringBuilder
            $buf  | ForEach-Object { [void] $lineInBuf.Append($_.Character) }
            $line = $lineInBuf.ToString() 
          
            if ($line.StartsWith($Global:promptPrimary)) {
                $offset=  $Global:promptPrimary.Length
                $line = $line.Remove(0,$offset)               
            }
            elseif ($line.StartsWith($Global:promptSecondary)) {
                $offset=  $Global:promptSecondary.Length
                $line = $line.Remove(0, $offset)
            }
            elseif ($line.StartsWith($Global:promptDebug)) {
                $offset=  $Global:promptDebug.Length
                $line = $line.Remove(0,$offset)
            }                  
            $completeBufStr.Insert(0, $line.Trim())    
            $foundIndex = $completeBufStr.ToString().IndexOf($token.Text)
            if ($foundIndex -gt -1) {
                break
            }
            else {
                $scanY--
            }
        }
        $foundIndex +=$offset

        $tokenLength = ($token.Extent.EndOffset - $token.Extent.StartOffset)
        $finalRec = New-Object System.Management.Automation.Host.Rectangle($foundIndex, $scanY, ($foundIndex + $tokenLength), $scanY)            
        $finalBuf = $host.UI.RawUI.GetBufferContents($finalRec)
        $t = $finalBuf.GetValue(0, 0) 
        if ($t.ForegroundColor -eq "Red" -or $t.ForegroundColor -eq "Green") {
            return
        }
        $color = "Red"
        if ((Get-Command $token -ErrorAction SilentlyContinue) -or (Get-Command "$token.exe" -ErrorAction SilentlyContinue)) {
            $color = "Green"
        }    
        for ($xPosition = 0; $xPosition -lt $tokenLength; $xPosition++) {
            $bufferItem = $finalBuf.GetValue(0, $xPosition)      
            $bufferItem.ForegroundColor = $color          
            $finalBuf.SetValue($bufferItem, 0, $xPosition)         
        }
        $coords = New-Object System.Management.Automation.Host.Coordinates $foundIndex , ($scanY)
        $host.ui.RawUI.SetBufferContents($coords, $finalBuf)
    }
    catch {  }    
}