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
   
 ## Limitations
 
- Commands after a semicolon and second line commands will not be validated 
- Only works with Windows and doesn't work on macOS/Linux
- Doesn't validate commands that begin with a "#" well

## Credits

<table>
  <tr>
    <td align="center"><a href="https://www.linkedin.com/in/rajeswarkhan/" target="_blank"><img src="https://media.licdn.com/dms/image/v2/C4D03AQHgpVP7ohT_ZQ/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1516901476072?e=1731542400&v=beta&t=yj5Mo6Hq43u_XXf48CAqelbYeZZJaxpudQFk9vXxmHo" width="100px;" alt=""/><br /><sub><b>Rajeswar Khan</b></sub></a><br /></td>
  </tr>
</table>
