# pwsh-syntax-highlighting
This project is inspired by the [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting "Fish shell like syntax highlighting for Zsh") project.

*Requirement: pwsh 5.1+*

This package provides syntax highlighting for PowerShell. 
It enables highlighting of commands whilst they are typed at a PowerShell prompt into an interactive terminal. 
This helps in reviewing commands before running them, particularly in catching syntax errors.

## Preview

![preview](https://urlzs.com/fiWmK)

## How to install

1. Run PowerShell as Administrator.

2. Execute the following command:

    ```pwsh
    Install-Module syntax-highlighting
    ```
 
3. Restart PowerShell and run:

   ```pwsh
   Import-Module syntax-highlighting
   ```
   
   or simply:
   
   ```pwsh
   echo "Import-Module syntax-highlighting" >> $profile
   ```
   
   so you don't have to import the module every time you open PowerShell.
   
 ## Limitations
 
- Command validation will only be executed after pressing the spacebar
- Second line commands will not be validated 
- Only works with Windows and doesn't work on macOS/Linux
- Doesn't fully support all oh-my-posh themes

## oh-my-posh support

<details>
    
| Theme  | Full Support |
| ------------- | ------------- |
| agnoster  | ✅  |
| agnosterplus  | ✅  |
| aliens  | ✅  |
| amro  | ✅  |
| atomic  | ✅  |
| atomicBit  | ✅  |
| avit  | ✅  |
| blueish  | ✅  |
| blue-owl  | ✅  |
| bubbles  | ✅  |
| bubblesextra  | ✅  |
| bubblesline  | ✅  |
| capr4n  | ❌  |
| cert  | ✅  |
| cinnamon  | ✅  |
| clean-detailed  | ✅  |
| cloud-native-azure  | ❌  |
| craver  | ✅  |
| darkblood  | ✅  |
| default  | ✅  |
| di4am0nd  | ❌  |
| dracula  | ✅  |
| emodipt  | ✅  |
| festivetech  | ✅  |
| fish  | ❌  |
| free-ukraine  | ❌  |
| gmay  | ✅  |
| grandpa-style  | ✅  |
| half-life  | ✅  |
| honukai  | ✅  |
| hotstick.minimal  | ✅  |
| hunk  | ✅  |
| huvix  | ✅  |
| if_tea  | ❌  |
| iterm2  | ✅  |
| jandedobbeleer  | ✅  |
| jblab_2021  | ✅  |
| jonnychipz  | ✅  |
| jtracey93  | ✅  |
| jv_sitecorian  | ✅  |
| kali  | ❌  |
| lambda  | ✅  |
| lambdageneration  | ✅  |
| larserikfinholt  | ✅  |
| M365Princess  | ✅  |
| marcduiker  | ✅  |
| markbull  | ✅  |
| material  | ✅  |
| microverse-power  | ✅  |
| mojada  | ✅  |
| montys  | ❌  |
| mt  | ✅  |
| negligible  | ✅  |
| night-owl  | ✅  |
| nordtron  | ❌  |
| nu4a  | ❌  |
| paradox  | ✅  |
| pararussel  | ✅  |
| patriksvensson  | ✅  |
| peru  | ❌  |
| pixelrobots  | ✅  |
| plague  | ✅  |
| powerlevel10k_classic  | ✅  |
| powerlevel10k_lean  | ✅  |
| powerlevel10k_modern  | ✅  |
| powerlevel10k_rainbow  | ✅  |
| powerline  | ❌  |
| probua.minimal  | ❌  |
| pure  | ✅  |
| remk  | ✅  |
| robbyrussel  | ✅  |
| rudolfs-dark  | ❌  |
| rudolfs-light  | ❌  |
| slim  | ✅  |
| slimfat  | ❌  |
| smoothie  | ✅  |
| sonicboom_dark  | ✅  |
| sonicboom_light  | ✅  |
| sorin  | ✅  |
| space  | ✅  |
| spaceship  | ✅  |
| star  | ✅  |
| stelbent.minimal  | ✅  |
| takuya  | ❌  |
| thecyberden  | ❌  |
| the-unnamed  | ❌  |
| tiwahu  | ❌  |
| tonybaloney  | ✅  |
| unicorn  | ✅  |
| velvet  | ❌  |
| wopian  | ✅  |
| xtoys  | ✅  |
| ys  | ✅  |
| zash  | ✅  |
    
</details>

### Solution

For those who are using themes that are not fully supported by the `syntax-highlighting` module, follow the instructions
below to use the workaround script:

1. If you have previously installed the `syntax-highlighting` module, uninstall it with command:

   ```pwsh
   Uninstall-Module syntax-highlighting
   ```
   
   and remove it from your $profile with command:
   
   ```pwsh
   Set-Content -Path $profile -Value (get-content -Path $profile | Select-String -Pattern 'cmd_validator.ps1' -NotMatch)
   ```
   
2. Clone the git repository onto your machine:

    ```pwsh
    git clone https://github.com/digitalguy99/pwsh-syntax-highlighting.git
    ```
    
3. Run the following command:
    
   ```pwsh
   echo (pwd).Path\pwsh-syntax-highlighting\cmd_validator.ps1 >> $profile
   ```

4. Restart PowerShell.

## Credits

<table>
  <tr>
    <td align="center"><a href="https://www.linkedin.com/in/rajeswarkhan/" target="_blank"><img src="https://media-exp1.licdn.com/dms/image/C4D03AQHgpVP7ohT_ZQ/profile-displayphoto-shrink_400_400/0/1516901471017?e=1659571200&v=beta&t=Ksn0EbeQUQcEf4goaH7cfmhrk9qW3yARCtExx0psTVI" width="100px;" alt=""/><br /><sub><b>Rajeswar Khan</b></sub></a><br /></td>
  </tr>
</table>
