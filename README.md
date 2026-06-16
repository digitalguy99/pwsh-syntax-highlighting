# pwsh-syntax-highlighting
This project is inspired by the [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting "Fish shell like syntax highlighting for Zsh") project.

*Requirement: pwsh 5.1+*

This package provides syntax highlighting for PowerShell(especially on Mac/Linux). 
It enables highlighting of commands whilst they are typed at a PowerShell prompt into an interactive terminal. 
This helps in reviewing commands before running them, particularly in catching syntax errors.

## Preview

https://github.com/user-attachments/assets/83cc42aa-e234-44b8-b0a3-251138afe71d

## How to install

Execute the following command:

```pwsh
($content = irm 'https://raw.githubusercontent.com/digitalguy99/pwsh-syntax-highlighting/refs/heads/feature/xplat-compatible/syntax-highlighting.psm1') | Out-File ($path = "$HOME/syntax-highlighting.ps1"); iex $content; Add-Content $profile ". '$path'"
```
 
## Uninstall

Run the following:
```pwsh
($f = 'syntax-highlighting'); (gc $profile) | ? { $_ -notmatch $f } | sc $profile; rm -r -fo "$HOME/$f.ps1"
```

## How to update

Run the following:
```pwsh
($content = irm 'https://raw.githubusercontent.com/digitalguy99/pwsh-syntax-highlighting/refs/heads/feature/xplat-compatible/syntax-highlighting.psm1') | Out-File ($path = "$HOME/syntax-highlighting.ps1"); iex $content
```

## Limitations
 
- Commands will only validate(change in color) after the <kbd>space</kbd>/<kbd>return</kbd> key is entered
- Commands will not be colored red when they are not valid, they will simply remain the default color set by `PSReadLine`
- When more than 1 command is entered, only when both commands are valid will they both be colored green

## Credits

<table>
  <tr>
    <td align="center"><a href="https://www.linkedin.com/in/rajeswarkhan/" target="_blank"><img src="https://media.licdn.com/dms/image/v2/D5603AQGxj1n8CA384g/profile-displayphoto-crop_800_800/B56Zoj0EeuJwAM-/0/1761537444218?e=1782950400&v=beta&t=uw3VbJpqs8ot05wxvRzwEydSYX19hDkLptA_hgPinTA" width="100px;" alt=""/><br /><sub><b>Rajeswar Khan</b></sub></a><br /></td>
  </tr>
</table>