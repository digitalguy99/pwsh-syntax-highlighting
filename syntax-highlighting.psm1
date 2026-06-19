$global:lastRender = Get-Date
$global:commandCache = @{}
$global:commandCacheExpiry = 0


# Initial default color
Set-PSReadLineOption -Colors @{ "Command" = "$([char]0x1b)[93m" }


function global:Invoke-Highlight {
   # 100ms Throttle
   if (((Get-Date) - $global:lastRender).TotalMilliseconds -le 100) {
       return
   }


   $ast = $null; $tokens = $null ; $errors = $null; $cursor = $null
   [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)


   if ($null -eq $tokens -or $tokens.Count -eq 0) {
       return
   }


   if ((Get-Date).Ticks -gt $global:commandCacheExpiry) {
       $global:commandCache = @{}
       $global:commandCacheExpiry = (Get-Date).AddSeconds(5).Ticks
   }


   $allCommandsValid = $true
   $hasCommand = $false


   foreach ($token in $tokens) {
       if ($token.TokenServiceKind -eq 'Command' -or $token.Kind -eq 'Identifier' -or $token.Kind -eq 'Generic') {
           $cmdText = $token.Text.Trim()
          
           if ($cmdText -eq "[]") {
               continue
           }
          
           $hasCommand = $true

           if ($global:commandCache.ContainsKey($cmdText)) {
               if (-not $global:commandCache[$cmdText]) {
                   $allCommandsValid = $false
                   break
               }
           }
           else {
               $exists = $null -ne (Get-Command $cmdText -ErrorAction Ignore)
               $global:commandCache[$cmdText] = $exists
               if (-not $exists) {
                   $allCommandsValid = $false
                   break
               }
           }
       }
   }


   # Set color BEFORE the insert happens in the handler
   if ($hasCommand -and $allCommandsValid) {
       Set-PSReadLineOption -Colors @{ "Command" = "$([char]0x1b)[92m" } # Green
   }
   else {
       Set-PSReadLineOption -Colors @{ "Command" = "$([char]0x1b)[93m" } # Yellow
   }


   $global:lastRender = Get-Date
}


# --- KEY HANDLERS ---


Set-PSReadLineKeyHandler -Key "Spacebar" `
   -BriefDescription ValidatePrograms `
   -LongDescription "Validate typed program's existence in path variable" `
   -ScriptBlock {
   param($key, $arg)
  
   # 1. CALCULATE COLOR FIRST
   Invoke-Highlight
  
   # 2. THEN INSERT THE SPACE (Render happens here with the new color)
   [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
}


Set-PSReadLineKeyHandler -Key "Tab" `
   -BriefDescription TabComplete `
   -LongDescription "Tab completion" `
   -ScriptBlock {
   param($key, $arg)
   # For Tab, we must complete first, otherwise we validate partial text
   Invoke-Highlight
   [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext($key)
}


Set-PSReadLineKeyHandler -Key "Enter" `
   -BriefDescription AcceptLine `
   -LongDescription "Accept the line" `
   -ScriptBlock {
   param($key, $arg)
   Invoke-Highlight -Force
   [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
   [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar()
   Start-Sleep -Milliseconds 1
   [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
   Set-PSReadLineOption -Colors @{ "Command" = "$([char]0x1b)[93m" }
}