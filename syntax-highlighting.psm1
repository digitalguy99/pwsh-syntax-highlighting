$global:lastRender = Get-Date
$global:commandCache = @{}
$global:commandCacheExpiry = 0
$global:highlightedVariables = @{}   # remember variable names that have already been highlighted
$printableChars = [char[]] (0x20..0x7e + 0xa0..0xff)

$printableChars + "Tab" | ForEach-Object {
    Set-PSReadLineKeyHandler -Key $_ `
        -BriefDescription ValidatePrograms `
        -LongDescription "Validate typed program's existance in path variable" `
        -ScriptBlock {
        param($key, $arg)

        if ($key.Key -ne [System.ConsoleKey]::Tab) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($key.KeyChar)
        }
        else {
            [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext($key)
        }

        if (((Get-Date) - $global:lastRender).TotalMilliseconds -le 50) {
            return
        }

        $ast = $null; $tokens = $null ; $errors = $null; $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

        # Return if no tokens
        if ($null -eq $tokens -or $tokens.Count -eq 0) {
            return
        }

        $token = $tokens[0]

        # Skip single-character punctuation tokens so "(" (and similar) are not highlighted
        if ($null -eq $token) { return }
        if ($token.Text -match '^[\(\)\[\]\{\}]$') {
            return
        }

        # Skip comment tokens (anything that starts with '#')
        if ($token.Text.TrimStart().StartsWith('#')) {
            return
        }

        if ([string]::IsNullOrEmpty($token.Text.Trim()) -or $token.Text -match "\[|\]") {
            return
        }

        # If this is a variable token (starts with $) and we've already highlighted it, skip further processing
        if ($token.Text.StartsWith('$')) {
            if ($global:highlightedVariables.ContainsKey($token.Text)) {
                return
            }
        }

        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0)
        $cursorPosX = $host.UI.RawUI.CursorPosition.X
        $cursorPosY = $host.UI.RawUI.CursorPosition.Y
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor)

        $tokenLength = ($token.Extent.EndOffset - $token.Extent.StartOffset)

        # Check command cache and refresh if expired
        if ((Get-Date).Ticks -gt $global:commandCacheExpiry) {
            $global:commandCache = @{}
            $global:commandCacheExpiry = (Get-Date).AddSeconds(5).Ticks
        }

        # Determine color:
        # - For variables, use a variable color and mark them as highlighted
        # - For other tokens, use command detection with caching (original behavior)
        if ($token.Text.StartsWith('$')) {
            $color = "Yellow"   # variable color; change if you prefer another color
            # Record that this variable has now been highlighted so we don't re-highlight it
            $global:highlightedVariables[$token.Text] = $true
        }
        else {
            $color = "Red"
            if ($global:commandCache.ContainsKey($token.Text)) {
                $color = if ($global:commandCache[$token.Text]) { "Green" } else { "Red" }
            }
            else {
                $exists = $null -ne (Get-Command $token.Text -ErrorAction Ignore)
                $global:commandCache[$token.Text] = $exists
                $color = if ($exists) { "Green" } else { "Red" }
            }
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
                $sX = 0
                $Y++
                $nextLine = $false
            }
        }
        $global:lastRender = Get-Date
    }
}