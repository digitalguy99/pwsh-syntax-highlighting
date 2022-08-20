Write-Verbose "`n->> Loading the module"

function Reset-SyntaxHighlightingCache() {
    Write-Verbose "`n->> Feeding the commands cache"
    $CurrentCommands=(Get-Command * | Select-Object Name).Name
    [System.Environment]::SetEnvironmentVariable($SyntaxHighlightCacheVariable, $CurrentCommands, "User")
}

$SyntaxHighlightCacheVariable="SyntaxHighlightCache"
$CommandsCache=[System.Environment]::GetEnvironmentVariable($SyntaxHighlightCacheVariable, "User")
if(!$CommandsCache) {
    Reset-SyntaxHighlightingCache
} else {
    Write-Verbose "`n->> SyntaxHighlightCacheVariable already set"
}

Set-PSReadLineKeyHandler -Chord Spacebar `
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
        while ($foundIndex -eq -1) {
            $rec = New-Object System.Management.Automation.Host.Rectangle(0, $scanY, $host.ui.RawUI.BufferSize.Width, $scanY)
            $buf = $host.UI.RawUI.GetBufferContents($rec)     
            $lineInBuf = New-Object System.Text.StringBuilder
            $buf  | ForEach-Object { [void] $lineInBuf.Append($_.Character) }
            $completeBufStr.Insert(0, $lineInBuf.ToString().Trim())       
            $foundIndex = $completeBufStr.ToString().IndexOf($token.Text)
            if ($foundIndex -gt 0) {
                break
            }
            else {
                $scanY--
            }
        }

        $tokenLength = ($token.Extent.EndOffset - $token.Extent.StartOffset)
        $finalRec = New-Object System.Management.Automation.Host.Rectangle($foundIndex, $scanY, ($foundIndex + $tokenLength), $scanY)            
        $finalBuf = $host.UI.RawUI.GetBufferContents($finalRec)
        $t = $finalBuf.GetValue(0, 0) 
        if ($t.ForegroundColor -eq "Red" -or $t.ForegroundColor -eq "Green") {
            return
        }
        $color = "Red"
        if ( [System.Environment]::GetEnvironmentVariable($SyntaxHighlightCacheVariable, "User").Split(" ") -match "^$token(.exe|.bat|.ps1|)$" ) {
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
    catch {}
}
