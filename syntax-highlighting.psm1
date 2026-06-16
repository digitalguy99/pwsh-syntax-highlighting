$script:ThrottleLimit = 50
$global:lastRender = Get-Date
$printableChars = [char[]] (0x20..0x7e + 0xa0..0xff)

# Combine normal keys with backspace/delete to trigger color resets
$allKeys = $printableChars + "Tab" + "Backspace" + "Delete"

$allKeys | ForEach-Object {
    Set-PSReadLineKeyHandler -Key $_ `
        -BriefDescription ValidatePrograms `
        -LongDescription "Validate typed program's existence in path variable" `
        -ScriptBlock {
            param($key, $arg)

            # 1. Force execution of native typing/deleting actions immediately
            if ($key.Key -eq [System.ConsoleKey]::Tab) {
                [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext($key)
            } elseif ($key.Key -eq [System.ConsoleKey]::Backspace) {
                [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key)
            } elseif ($key.Key -eq [System.ConsoleKey]::Delete) {
                [Microsoft.PowerShell.PSConsoleReadLine]::DeleteChar($key)
            } else {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($key.KeyChar)
            }

            # 
            if (((get-date) - $global:lastRender).TotalMilliseconds -le $script:ThrottleLimit) {
                return
            }

            # 2. Read live text string out of the prompt window buffer
            $lineString = $null; $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$lineString, [ref]$cursor)

            if ([string]::IsNullOrWhiteSpace($lineString)) {
                return
            }

            # Calculate accurate leading space padding metrics
            $trimmedLine = $lineString.TrimStart()
            $leadingSpacesCount = $lineString.Length - $trimmedLine.Length
            
            # FIX: Regex matching guarantees it extracts the true full word safely, even without spaces
            if ($trimmedLine -match '^([^\s()\[\]{}|;]+)') {
                $tokenText = $Matches[1]
            } else {
                return
            }

            # Skip checking symbols, comments, exit, and variables
            if ([string]::IsNullOrEmpty($tokenText) -or 
                $tokenText -like '$*' -or 
                $tokenText -like '#*' -or
                $tokenText -in (
                    'function', 'exit', 'filter', 'workflow', 'class', 'enum', 
                    'if', 'elseif', 'switch', 'foreach', 'from', 'for', 'while', 
                    'do', 'try', 'trap', 'throw', 'return', 'break', 'continue', 
                    'data', 'parallel', 'sequence', 'define'
                )
            ) {
                return
            }

            # 3. Locate precise prompt coordinates on screen
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0)
            $cursorPosX = $host.UI.RawUI.CursorPosition.X
            $cursorPosY = $host.UI.RawUI.CursorPosition.Y
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor)

            $tokenLength = $tokenText.Length

            # 4. Check system PATH for command presence
            $color = "Red"
            if (Get-Command $tokenText -ErrorAction Ignore) {
                $color = "Green"
            }

            # Handle cleanup state if a command was completely deleted
            if ($tokenLength -le 1 -and ($key.Key -eq [System.ConsoleKey]::Backspace -or $key.Key -eq [System.ConsoleKey]::Delete)) {
                $color = "White"
            }

            # Map the boundary vectors safely
            $sX = $cursorPosX + $leadingSpacesCount
            $Y = $cursorPosY
            $eX = ($sX + $tokenLength)
            
            $nextLine = $false
            $painted = 0
            $bufSize = $host.UI.RawUI.BufferSize.Width

            # 5. Core rendering engine loop
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
                    if ($bufferItem) {
                        $bufferItem.ForegroundColor = $color
                        $finalBuf.SetValue($bufferItem, 0, $xPosition)
                    }
                    $painted++
                }

                $coords = New-Object System.Management.Automation.Host.Coordinates $sX, $Y
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

function Set-SyntaxHighlightingThrottle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [int]$Milliseconds
    )
    
    # Update the module-scoped tracking variable
    $script:ThrottleLimit = $Milliseconds
    Write-Verbose "Syntax-highlighting throttle updated to ${Milliseconds}ms."
}

# Create a clean user-facing alias matching your desired command format
Set-Alias -Name syntax-highlighting -Value Set-SyntaxHighlightingThrottle