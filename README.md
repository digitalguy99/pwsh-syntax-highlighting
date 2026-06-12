# pwsh-syntax-highlighting
This project is inspired by the [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting "Fish shell like syntax highlighting for Zsh") project.

*Requirement: pwsh 5.1+*

This package provides syntax highlighting for PowerShell. 
It enables highlighting of commands whilst they are typed at a PowerShell prompt into an interactive terminal. 
This helps in reviewing commands before running them, particularly in catching syntax errors.

## Preview

https://github.com/user-attachments/assets/83cc42aa-e234-44b8-b0a3-251138afe71d

## How to install

1. Run PowerShell as Administrator.

2. Execute the following command:

    ```pwsh
    Install-Module syntax-highlighting
    ```
 
3. Run the following and restart PowerShell:
   
   ```pwsh
   echo "Import-Module syntax-highlighting" >> $profile
   ```
   
   so you don't have to import the module every time you open PowerShell.

## How to update

```pwsh
Update-Module syntax-highlighting
```

 ## Limitations
 
- Commands after a semicolon and second line commands will not be validated 
- Only works with Windows and doesn't work on macOS/Linux

## Credits

<table>
  <tr>
    <td align="center"><a href="https://www.linkedin.com/in/rajeswarkhan/" target="_blank"><img src="https://media.licdn.com/dms/image/v2/D5603AQGxj1n8CA384g/profile-displayphoto-crop_800_800/B56Zoj0EeuJwAM-/0/1761537444218?e=1782950400&v=beta&t=uw3VbJpqs8ot05wxvRzwEydSYX19hDkLptA_hgPinTA" width="100px;" alt=""/><br /><sub><b>Rajeswar Khan</b></sub></a><br /></td>
  </tr>
</table>