
$localPolicyPath
$groupEditorPath


function CreateInput() {
    $promptInput; $promptReturn
    $promptInput = Read-Host -Prompt "Will you run the Windows 10 master script? [Y/N]"

    if ($promptInput -eq "Yes" -or $promptInput -eq "Y") {

        Write-Host "Script will now run. `n`n`n" -ForegroundColor Green 
        Write-Warning "Do not turn off your machine, or close Powershell until the script is complete." 
        $promptInput = $true
    } else {
        $promptInput = $false
    }


    return $promptInput
}

function Watermark() {

    Write-Host "`n Script by BadguyB.A `n" 
    Write-Host "`n`n This script is designed for a competitive CyberSecurity competition, applicable for personal use but not advised.
    This script alters and works in Windows SecPol, and Users. Be sure to test and run in a virtual machine as to not cause damage.  `n`n" 
    Write-Host "`n Warning: " -ForegroundColor DarkRed
    Write-Host "`Recommend running each function (check box) singuarly." 

}


function CreateLog() {
   $desktopPath = [System.Environment]::GetFolderPath("Desktop")
   $folderPath = Join-Path -Path $desktopPath -ChildPath "Change-Log"
   $fileFullPath = Join-Path -Path $folderPath -ChildPath "SystemGuide.txt"

   New-Item -Path $fileFullPath -ItemType File -Force
   Set-Content -Path $fileFullPath -Value "With in this folder will contain all the changes made by the editor.`nAny and all changes will show up in this folder as a text file.`nHappy hunting."

  }

 
function SetAllAudits() {
    Write-Host "Setting Audits:" -ForegroundColor Gray
    try {
    
        auditpol /set /category:"Policy Change" /success:enable
        auditpol /set /category:"Policy Change" /failure:enable

        auditpol /set /category:"DS Access" /success:enable
        auditpol /set /category:"DS Access" /failure:enable

        auditpol /set /category:"Account Logon" /success:enable 
        auditpol /set /category:"Account Logon" /failure:enable

        auditpol /set /category:"System" /success:enable 
        auditpol /set /category:"System" /failure:enable

        auditpol /set /category:"Account Management" /success:enable
        auditpol /set /category:"Account Management" /failure:enable

        auditpol /set /category:"Logon/Logoff" /success:enable
        auditpol /set /category:"Logon/Logoff" /failure:enable

        auditpol /set /category:"Object Access" /success:enable
        auditpol /set /category:"Object Access" /failure:enable

        auditpol /set /category:"Privilege Use" /success:enable
        auditpol /set /category:"Privilege Use" /failure:enable

        auditpol /set /category:"Detailed Tracking" /success:enable
        auditpol /set /category:"Detailed Tracking" /failure:enable

    } catch {
        Write-Host ("Failed to set policy: " + $_) -ForegroundColor DarkRed
    } finally {
        Write-Host "Completed Audits. `n`n`n" -ForegroundColor Green 
    }
}

function SearchAndDestroyMedia() {
    Get-ChildItem -Path "C:\Users" -Include *.txt, *.mp4, *.mp3 -Recurse | Remove-Item -Force -Confirm:$false
    Write-Host "Media Removed." -ForegroundColor Green 
}

function SetPassword() {
    net accounts /UNIQUEPW:24 /MAXPWAGE:90 /MINPWAGE:60 /MINPWLEN:12 /lockoutthreshold:5

    secedit /export /cfg c:\secpol.cfg
    (GC C:\secpol.cfg) -Replace "PasswordComplexity = 0","PasswordComplexity = 1" | Out-File C:\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
    Remove-Item C:\secpol.cfg -Force

    $currentUserName = [System.Environment]::UserName
    $users = Get-LocalUser

    foreach ($user in $users) {
        if ($user.Name -ne $currentUserName) {
            $newPassword = "TestCyberPassword1#!" | ConvertTo-SecureString -AsPlainText -Force
            Set-LocalUser -Name $user.Name -Password $newPassword
        }
    }

}
function HandleUsers() {
    Write-Host "Doing user stuff"
}

function SetUpFirewall() {

    $firewallService = Get-Service -Name MpsSvc
    $firewallProfiles = Get-NetFirewallProfile

    if ($firewallService.Status -eq 'Stopped') {
        Start-Service -Name MpsSvc
        Write-Host "Windows Firewall service has been started. `n" -ForegroundColor Green 
    } else {
        Write-Host "Windows Firewall service is already running. `n" -ForegroundColor Green 
    }

    foreach ($profile in $firewallProfiles) {
        if ($profile.Enabled -eq 'False') {
            Set-NetFirewallProfile -Name $profile.Name -Enabled True
            Write-Host "$($profile.Name) profile has been enabled."
        } else {
            Write-Host "$($profile.Name) profile is already enabled."
        }
    }

}

function ManageServices() {
    Set-ExecutionPolicy RemoteSigned -Force
    $services = @(
        "TermService", "FTPSVC", "TlntSvr", "SNMP", "SNMP Trap", "RemoteRegistry"; 
    )
    
    foreach ($serviceName in $services) {
        if ($serviceName.StartsWith("#")) {
            Write-Host "Ignoring commented service: $serviceName"
            continue
        }
    
        if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
            Write-Host "Service $serviceName exists. Disabling service..."
            REG ADD HKLM\SYSTEM\CurrentControlSet\Services\$serviceName /v Start /f /t REG_DWORD /d 4
            Stop-Service $serviceName -Force
            $process = Get-Process -Name $serviceName -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "Process with PID $($process.Id) exists. Killing process..."
                Stop-Process -Id $process.Id -Force
            }
            Set-Content stop $serviceName
        } else {
            Write-Host "Service $serviceName does not exist."
        }
    }
    Set-ExecutionPolicy Restricted -Force

}

function SetLocalPol() {
    Write-Host "Setting local policies"
}

Watermark;
if (CreateInput -eq true) {
    Write-Host "Beginning script. `n`n`n" -ForegroundColor Green 
    CreateLog

    $functionNames = @("Destroy media", "Set all audits", "Set passowrds", "Handle all users", "Set up firewall", "Manage services", "Set local policies")
    $functionDescriptions = @("Description for Function 1", "Description for Function 2", "Description for Function 3", "Description for Function 4", "Description for Function 5", "Description for Function 6", "Description for Function 7")

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Select Functions to Run'
    $form.Size = New-Object System.Drawing.Size(300,400) 

    $y = 10
    $checkboxes = @()
    
    for ($i = 0; $i -lt $functionNames.Length; $i++) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Location = New-Object System.Drawing.Point(10, $y)
        $checkbox.Size = New-Object System.Drawing.Size(280, 20)
        $checkbox.Text = $functionNames[$i]
        $form.Controls.Add($checkbox)
        $checkboxes += $checkbox
    
        $labelY = $y + 20
        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Point(30, $labelY)
        $label.Size = New-Object System.Drawing.Size(260, 20)
        $label.Text = $functionDescriptions[$i]
        $form.Controls.Add($label)
    
        $y += 50
    }
    
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point(10, $y)
    $button.Size = New-Object System.Drawing.Size(75, 23)
    $button.Text = 'Start'
    $button.Add_Click({
        if ($checkboxes[0].Checked) { SearchAndDestroyMedia }
        if ($checkboxes[1].Checked) { SetAllAudits }
        if ($checkboxes[2].Checked) { SetPassword }
        if ($checkboxes[3].Checked) { HandleUsers }
        if ($checkboxes[4].Checked) { SetUpFirewall }
        if ($checkboxes[5].Checked) { ManageServices }
        if ($checkboxes[6].Checked) { SetLocalPol }
    })
    $form.Controls.Add($button)
    $form.ShowDialog()
}
else 
{
    Write-Warning "Script will not run, returning."
    Write-Host Script End
}