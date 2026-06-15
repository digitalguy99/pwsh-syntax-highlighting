$global:lastRender = Get-Date
# Cache variable to remember the last color used (prevents re-render flashing)
$global:lastAppliedColor = "Yellow" 
$printableChars = [char[]] (0x20..0x7e + 0xa0..0xff)

# 1. Clear previous handlers to prevent conflicts
$printableChars + "Tab" | ForEach-Object {
    Remove-PSReadLineKeyHandler -Key $_ -ErrorAction Ignore
}

# 2. Set Default Color to Yellow (Neutral/Waiting state)
Set-PSReadLineOption -Colors @{ "Command" = "$([char]0x1b)[93m" }

$printableChars + "Tab" | ForEach-Object {
    Set-PSReadLineKeyHandler -Key $_ `
        -BriefDescription ValidatePrograms `
        -LongDescription "Green if perfect, Yellow otherwise without screen flashing" `
        -ScriptBlock {
            param($key, $arg)

            # Insert key or handle Tab completion
            if ($key.Key -ne [System.ConsoleKey]::Tab) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($key.KeyChar)
            }
            else {
                [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext($key)
            }

            # 50ms Throttle
            # if (((Get-Date) - $global:lastRender).TotalMilliseconds -le 50) {
            #     return
            # }

            # Analyze the buffer
            $ast = $null; $tokens = $null; $errors = $null; $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

            if ($tokens.Count -gt 0) {
                $allCommandsValid = $true
                $hasCommand = $false

                foreach ($token in $tokens) {
                    if ($token.TokenServiceKind -eq 'Command' -or $token.Kind -eq 'Identifier') {
                        $cmdText = $token.Text.Trim()
                        # Ignore brackets/syntax chars
                        # if ($cmdText -match '\[|\]|\(|\)|\{|\}') { continue }
                        
                        $hasCommand = $true
                        if (-not (Get-Command $cmdText -ErrorAction Ignore)) {
                            $allCommandsValid = $false
                            break 
                        }
                    }
                }

                # STATE CACHE FILTER: Only update the engine if the color actually needs to change
                if ($hasCommand -and $allCommandsValid) {
                    if ($global:lastAppliedColor -ne "Green") {
                        Set-PSReadLineOption -Colors @{ "Command" = "$([char]0x1b)[32m" }
                        $global:lastAppliedColor = "Green"
                    }
                }
                else {
                    if ($global:lastAppliedColor -ne "Yellow") {
                        Set-PSReadLineOption -Colors @{ "Command" = "$([char]0x1b)[93m" }
                        $global:lastAppliedColor = "Yellow"
                    }
                }
            }

            $global:lastRender = Get-Date
        }
}