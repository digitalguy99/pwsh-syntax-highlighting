$global:lastRender = Get-Date  
$printableChars = [char[]] (0x20..0x7e + 0xa0..0xff)
$printableChars + "Tab" | ForEach-Object {
    Set-PSReadLineKeyHandler -Key $_ `
        -BriefDescription ValidatePrograms `
        -LongDescription "Validate typed program's existance in path variable" `
        -ScriptBlock {
        param($key, $arg)   

        if ( $key.Key -ne [System.ConsoleKey]::Tab) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($key.KeyChar)
        }
        else {
            [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext($key)
        } 

        if (((get-date) - $global:lastRender).TotalMilliseconds -le 50) {
            return
        }

        $ast = $null; $tokens = $null ; $errors = $null; $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)  
        $token = $tokens[0]
	  

        if ([string]::IsNullOrEmpty($token.Text.Trim()) -or $token.Text -match "\[|\]") {
            return
        }  

        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0)
        $cursorPosX = $host.UI.RawUI.CursorPosition.X
        $cursorPosY = $host.UI.RawUI.CursorPosition.Y
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor)

        $tokenLength = ($token.Extent.EndOffset - $token.Extent.StartOffset)
 
        $color = "Red"
	 if(Get-Command $token.Text -ErrorAction Ignore){
           $color = "Green" 
        } 
        $sX = $cursorPosX
        $Y = $cursorPosY
        $eX = ($cursorPosX + $tokenLength)
        $nextLine = $false

        $painted = 0
        $bufSize = $host.UI.RawUI.BufferSize.Width
        while ($painted -ne $tokenLength) {            
            $scanXEnd = $eX
            if ($eX -gt $bufSize) {
                $scanXEnd = $bufSize
                $eX = $eX - $bufSize
                $nextLine = $true
            } 
            $finalRec = New-Object System.Management.Automation.Host.Rectangle($sX, $Y, $scanXEnd, $Y)            
            $finalBuf = $host.UI.RawUI.GetBufferContents($finalRec)
            for ($xPosition = 0; $xPosition -lt ($scanXEnd - $sX); $xPosition++) {
                $bufferItem = $finalBuf.GetValue(0, $xPosition)      
                $bufferItem.ForegroundColor = $color          
                $finalBuf.SetValue($bufferItem, 0, $xPosition)   
                $painted++      
            }
            $coords = New-Object System.Management.Automation.Host.Coordinates $sX , $Y
            $host.ui.RawUI.SetBufferContents($coords, $finalBuf)
            if ($nextLine) {
                $sX=0
                $Y++
                $nextLine = $false
            }
        }
        $global:lastRender = get-date
    }
}