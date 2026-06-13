$global:lastRender = Get-Date
$global:commandCache = @{}
$global:commandCacheExpiry = 0
$global:highlightedVariables = @{}

# Define the highlight function at module scope
function global:Invoke-Highlight {
    # Throttle rendering to avoid lag
    if (((Get-Date) - $global:lastRender).TotalMilliseconds -le 100) {
        return
    }

    $ast = $null; $tokens = $null ; $errors = $null; $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    # Return if no tokens
    if ($null -eq $tokens -or $tokens.Count -eq 0) {
        return
    }

    $token = $tokens[0]

    # Skip single-character punctuation tokens
    if ($null -eq $token) { return }
    if ($token.Text -match '^[\(\)\[\]\{\}]$') {
        return
    }

    # Skip comment tokens
    if ($token.Text.TrimStart().StartsWith('#')) {
        return
    }

    if ([string]::IsNullOrEmpty($token.Text.Trim()) -or $token.Text -match "\[|\]") {
        return
    }

    # Skip the exit command - do not validate or highlight it
    if ($token.Text -eq "exit") {
        return
    }

    # If this is a variable and we've already highlighted it, skip
    if ($token.Text.StartsWith('$')) {
        if ($global:highlightedVariables.ContainsKey($token.Text)) {
            return
        }
    }

    # Save cursor position
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

    # Determine color
    if ($token.Text.StartsWith('$')) {
        $color = "Yellow"
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

# Only bind to specific keys that actually trigger highlighting updates
Set-PSReadLineKeyHandler -Key "Spacebar" `
    -BriefDescription ValidatePrograms `
    -LongDescription "Validate typed program's existence in path variable" `
    -ScriptBlock {
    param($key, $arg)
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
    Invoke-Highlight
}

Set-PSReadLineKeyHandler -Key "Tab" `
    -BriefDescription TabComplete `
    -LongDescription "Tab completion" `
    -ScriptBlock {
    param($key, $arg)
    [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext($key)
    Invoke-Highlight
}

Set-PSReadLineKeyHandler -Key "Enter" `
    -BriefDescription AcceptLine `
    -LongDescription "Accept the line" `
    -ScriptBlock {
    param($key, $arg)
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}