<# 
.NAME
    SBCU (Switch Bulk Configuration Utility
.AUTHOR
    Caleb Bartle
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#region GUI Configuration
$SBCU                            = New-Object system.Windows.Forms.Form
$SBCU.ClientSize                 = New-Object System.Drawing.Point(521,407)
$SBCU.text                       = "Switch Bulk Configuration Utility"
$SBCU.TopMost                    = $false
$SBCU.icon                       = ".\icon.ico"

$TxtBxRangeStart                 = New-Object system.Windows.Forms.TextBox
$TxtBxRangeStart.multiline       = $false
$TxtBxRangeStart.width           = 70
$TxtBxRangeStart.height          = 20
$TxtBxRangeStart.location        = New-Object System.Drawing.Point(2,81)
$TxtBxRangeStart.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LblPrtRange                     = New-Object system.Windows.Forms.Label
$LblPrtRange.text                = "Port Ranges:"
$LblPrtRange.AutoSize            = $true
$LblPrtRange.width               = 25
$LblPrtRange.height              = 10
$LblPrtRange.location            = New-Object System.Drawing.Point(7,54)
$LblPrtRange.Font                = New-Object System.Drawing.Font('Segoe UI',12)

$PnlTags                         = New-Object system.Windows.Forms.Panel
$PnlTags.height                  = 31
$PnlTags.width                   = 140
$PnlTags.location                = New-Object System.Drawing.Point(1,105)

$LblToolName                     = New-Object system.Windows.Forms.Label
$LblToolName.text                = "SBCU Status:"
$LblToolName.AutoSize            = $true
$LblToolName.width               = 25
$LblToolName.height              = 10
$LblToolName.location            = New-Object System.Drawing.Point(7,10)
$LblToolName.Font                = New-Object System.Drawing.Font('Segoe UI',13)

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "-"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(80,84)
$Label2.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$TxtBxRangeEnd                   = New-Object system.Windows.Forms.TextBox
$TxtBxRangeEnd.multiline         = $false
$TxtBxRangeEnd.width             = 82
$TxtBxRangeEnd.height            = 20
$TxtBxRangeEnd.location          = New-Object System.Drawing.Point(93,81)
$TxtBxRangeEnd.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$BtnSend                         = New-Object system.Windows.Forms.Button
$BtnSend.text                    = "Send Config"
$BtnSend.width                   = 127
$BtnSend.height                  = 59
$BtnSend.location                = New-Object System.Drawing.Point(385,346)
$BtnSend.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LblTag                          = New-Object system.Windows.Forms.Label
$LblTag.text                     = "Tags:"
$LblTag.AutoSize                 = $true
$LblTag.width                    = 25
$LblTag.height                   = 10
$LblTag.location                 = New-Object System.Drawing.Point(12,8)
$LblTag.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$TxtBxPortTags                   = New-Object system.Windows.Forms.TextBox
$TxtBxPortTags.multiline         = $false
$TxtBxPortTags.width             = 81
$TxtBxPortTags.height            = 20
$TxtBxPortTags.location          = New-Object System.Drawing.Point(51,5)
$TxtBxPortTags.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PnlEnabled                      = New-Object system.Windows.Forms.Panel
$PnlEnabled.height               = 39
$PnlEnabled.width                = 216
$PnlEnabled.location             = New-Object System.Drawing.Point(1,286)

$LblPortEnabled                  = New-Object system.Windows.Forms.Label
$LblPortEnabled.text             = "Enabled:"
$LblPortEnabled.AutoSize         = $true
$LblPortEnabled.width            = 25
$LblPortEnabled.height           = 10
$LblPortEnabled.location         = New-Object System.Drawing.Point(5,9)
$LblPortEnabled.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RadEnabled                      = New-Object system.Windows.Forms.RadioButton
$RadEnabled.text                 = "True"
$RadEnabled.AutoSize             = $true
$RadEnabled.width                = 104
$RadEnabled.height               = 10
$RadEnabled.location             = New-Object System.Drawing.Point(65,9)
$RadEnabled.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RadDisabled                     = New-Object system.Windows.Forms.RadioButton
$RadDisabled.text                = "False"
$RadDisabled.AutoSize            = $true
$RadDisabled.width               = 104
$RadDisabled.height              = 20
$RadDisabled.location            = New-Object System.Drawing.Point(116,9)
$RadDisabled.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PnlPoe                          = New-Object system.Windows.Forms.Panel
$PnlPoe.height                   = 33
$PnlPoe.width                    = 216
$PnlPoe.location                 = New-Object System.Drawing.Point(1,175)

$RadPoEDisable                   = New-Object system.Windows.Forms.RadioButton
$RadPoEDisable.text              = "False"
$RadPoEDisable.AutoSize          = $true
$RadPoEDisable.width             = 104
$RadPoEDisable.height            = 20
$RadPoEDisable.location          = New-Object System.Drawing.Point(110,12)
$RadPoEDisable.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RadPoEEnable                    = New-Object system.Windows.Forms.RadioButton
$RadPoEEnable.text               = "True"
$RadPoEEnable.AutoSize           = $true
$RadPoEEnable.width              = 104
$RadPoEEnable.height             = 10
$RadPoEEnable.location           = New-Object System.Drawing.Point(57,12)
$RadPoEEnable.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LblPOE                          = New-Object system.Windows.Forms.Label
$LblPOE.text                     = "PoE:"
$LblPOE.AutoSize                 = $true
$LblPOE.width                    = 25
$LblPOE.height                   = 10
$LblPOE.location                 = New-Object System.Drawing.Point(5,12)
$LblPOE.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PnlPortType                     = New-Object system.Windows.Forms.Panel
$PnlPortType.height              = 39
$PnlPortType.width               = 216
$PnlPortType.location            = New-Object System.Drawing.Point(1,247)

$RadAccess                       = New-Object system.Windows.Forms.RadioButton
$RadAccess.text                  = "Access"
$RadAccess.AutoSize              = $true
$RadAccess.width                 = 104
$RadAccess.height                = 20
$RadAccess.location              = New-Object System.Drawing.Point(107,12)
$RadAccess.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RadTrunk                        = New-Object system.Windows.Forms.RadioButton
$RadTrunk.text                   = "Trunk"
$RadTrunk.AutoSize               = $true
$RadTrunk.width                  = 104
$RadTrunk.height                 = 10
$RadTrunk.location               = New-Object System.Drawing.Point(49,12)
$RadTrunk.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LblType                         = New-Object system.Windows.Forms.Label
$LblType.text                    = "Type:"
$LblType.AutoSize                = $true
$LblType.width                   = 25
$LblType.height                  = 10
$LblType.location                = New-Object System.Drawing.Point(6,11)
$LblType.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PnlAllowed                      = New-Object system.Windows.Forms.Panel
$PnlAllowed.height               = 30
$PnlAllowed.width                = 126
$PnlAllowed.location             = New-Object System.Drawing.Point(144,105)

$LblAllowed                      = New-Object system.Windows.Forms.Label
$LblAllowed.text                 = "Allowed:"
$LblAllowed.AutoSize             = $true
$LblAllowed.width                = 25
$LblAllowed.height               = 10
$LblAllowed.location             = New-Object System.Drawing.Point(5,8)
$LblAllowed.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$TxtBxAllowedVLAN                = New-Object system.Windows.Forms.TextBox
$TxtBxAllowedVLAN.multiline      = $false
$TxtBxAllowedVLAN.text           = "all"
$TxtBxAllowedVLAN.width          = 59
$TxtBxAllowedVLAN.height         = 20
$TxtBxAllowedVLAN.location       = New-Object System.Drawing.Point(63,6)
$TxtBxAllowedVLAN.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LblNative                       = New-Object system.Windows.Forms.Label
$LblNative.text                  = "Native:"
$LblNative.AutoSize              = $true
$LblNative.width                 = 25
$LblNative.height                = 10
$LblNative.location              = New-Object System.Drawing.Point(7,10)
$LblNative.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PnlNative                       = New-Object system.Windows.Forms.Panel
$PnlNative.height                = 32
$PnlNative.width                 = 140
$PnlNative.location              = New-Object System.Drawing.Point(1,141)

$TxtBxNative                     = New-Object system.Windows.Forms.TextBox
$TxtBxNative.multiline           = $false
$TxtBxNative.text                = "1"
$TxtBxNative.width               = 77
$TxtBxNative.height              = 20
$TxtBxNative.location            = New-Object System.Drawing.Point(55,7)
$TxtBxNative.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PnlVoice                        = New-Object system.Windows.Forms.Panel
$PnlVoice.height                 = 31
$PnlVoice.width                  = 127
$PnlVoice.location               = New-Object System.Drawing.Point(143,141)

$LblVoice                        = New-Object system.Windows.Forms.Label
$LblVoice.text                   = "Voice:"
$LblVoice.AutoSize               = $true
$LblVoice.width                  = 25
$LblVoice.height                 = 10
$LblVoice.location               = New-Object System.Drawing.Point(9,8)
$LblVoice.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$TxtBxVoice                      = New-Object system.Windows.Forms.TextBox
$TxtBxVoice.multiline            = $false
$TxtBxVoice.text                 = "1"
$TxtBxVoice.width                = 59
$TxtBxVoice.height               = 20
$TxtBxVoice.location             = New-Object System.Drawing.Point(63,6)
$TxtBxVoice.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PnlSTPG                         = New-Object system.Windows.Forms.Panel
$PnlSTPG.height                  = 39
$PnlSTPG.width                   = 216
$PnlSTPG.location                = New-Object System.Drawing.Point(1,364)

$LblSTPG                         = New-Object system.Windows.Forms.Label
$LblSTPG.text                    = "stpGuard:"
$LblSTPG.AutoSize                = $true
$LblSTPG.width                   = 25
$LblSTPG.height                  = 10
$LblSTPG.location                = New-Object System.Drawing.Point(6,12)
$LblSTPG.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LblIsolation                    = New-Object system.Windows.Forms.Label
$LblIsolation.text               = "Isolation:"
$LblIsolation.AutoSize           = $true
$LblIsolation.width              = 25
$LblIsolation.height             = 10
$LblIsolation.location           = New-Object System.Drawing.Point(6,11)
$LblIsolation.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PnlIsolation                    = New-Object system.Windows.Forms.Panel
$PnlIsolation.height             = 39
$PnlIsolation.width              = 216
$PnlIsolation.location           = New-Object System.Drawing.Point(1,208)

$RadIsoFalse                     = New-Object system.Windows.Forms.RadioButton
$RadIsoFalse.text                = "False"
$RadIsoFalse.AutoSize            = $true
$RadIsoFalse.width               = 104
$RadIsoFalse.height              = 20
$RadIsoFalse.location            = New-Object System.Drawing.Point(114,11)
$RadIsoFalse.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RadIsoTrue                      = New-Object system.Windows.Forms.RadioButton
$RadIsoTrue.text                 = "True"
$RadIsoTrue.AutoSize             = $true
$RadIsoTrue.width                = 104
$RadIsoTrue.height               = 10
$RadIsoTrue.location             = New-Object System.Drawing.Point(66,11)
$RadIsoTrue.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PnlUDLD                         = New-Object system.Windows.Forms.Panel
$PnlUDLD.height                  = 39
$PnlUDLD.width                   = 216
$PnlUDLD.location                = New-Object System.Drawing.Point(1,325)

$LblUDLD                         = New-Object system.Windows.Forms.Label
$LblUDLD.text                    = "UDLD:"
$LblUDLD.AutoSize                = $true
$LblUDLD.width                   = 25
$LblUDLD.height                  = 10
$LblUDLD.location                = New-Object System.Drawing.Point(6,14)
$LblUDLD.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RadUDLDAlert                    = New-Object system.Windows.Forms.RadioButton
$RadUDLDAlert.text               = "Alrt"
$RadUDLDAlert.AutoSize           = $true
$RadUDLDAlert.width              = 104
$RadUDLDAlert.height             = 10
$RadUDLDAlert.location           = New-Object System.Drawing.Point(61,12)
$RadUDLDAlert.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RadUDLDEnforce                  = New-Object system.Windows.Forms.RadioButton
$RadUDLDEnforce.text             = "Enfor."
$RadUDLDEnforce.AutoSize         = $true
$RadUDLDEnforce.width            = 104
$RadUDLDEnforce.height           = 20
$RadUDLDEnforce.location         = New-Object System.Drawing.Point(105,12)
$RadUDLDEnforce.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ComboSTP                        = New-Object system.Windows.Forms.ComboBox
$ComboSTP.text                   = "Disabled"
$ComboSTP.width                  = 100
$ComboSTP.height                 = 20
@('disabled','root guard','bpdu guard','loop guard') | ForEach-Object {[void] $ComboSTP.Items.Add($_)}
$ComboSTP.location               = New-Object System.Drawing.Point(80,10)
$ComboSTP.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$TxtBxLog                        = New-Object system.Windows.Forms.TextBox
$TxtBxLog.Scrollbars          = "Vertical"
$TxtBxLog.multiline              = $true
$TxtBxLog.width                  = 238
$TxtBxLog.height                 = 233
$TxtBxLog.location               = New-Object System.Drawing.Point(273,110)
$TxtBxLog.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$TxtBxLog.BackColor              = [System.Drawing.ColorTranslator]::FromHtml("#e3e2e2")

$ComboSwitches                   = New-Object system.Windows.Forms.ComboBox
$ComboSwitches.width             = 236
$ComboSwitches.height            = 20
$ComboSwitches.location          = New-Object System.Drawing.Point(274,45)
$ComboSwitches.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ComboPorts                      = New-Object system.Windows.Forms.ComboBox
$ComboPorts.width                = 100
$ComboPorts.height               = 20
$ComboPorts.location             = New-Object System.Drawing.Point(413,85)
$ComboPorts.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LblSwitches                     = New-Object system.Windows.Forms.Label
$LblSwitches.text                = "Switches:"
$LblSwitches.AutoSize            = $true
$LblSwitches.width               = 25
$LblSwitches.height              = 10
$LblSwitches.location            = New-Object System.Drawing.Point(210,48)
$LblSwitches.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LblPorts                        = New-Object system.Windows.Forms.Label
$LblPorts.text                   = "Port:"
$LblPorts.AutoSize               = $true
$LblPorts.width                  = 25
$LblPorts.height                 = 10
$LblPorts.location               = New-Object System.Drawing.Point(374,86)
$LblPorts.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$BtnClear                        = New-Object system.Windows.Forms.Button
$BtnClear.text                   = "Clear All"
$BtnClear.width                  = 94
$BtnClear.height                 = 30
$BtnClear.location               = New-Object System.Drawing.Point(187,74)
$BtnClear.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$BtnUpdate                        = New-Object system.Windows.Forms.Button
$BtnUpdate.text                   = "Update Config"
$BtnUpdate.width                  = 108
$BtnUpdate.height                 = 58
$BtnUpdate.location               = New-Object System.Drawing.Point(273,346)
$BtnUpdate.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PnlResult                       = New-Object system.Windows.Forms.Panel
$PnlResult.height                = 34
$PnlResult.width                 = 377
$PnlResult.location              = New-Object System.Drawing.Point(134,3)

$TxtBxConfigInfo                 = New-Object system.Windows.Forms.TextBox
$TxtBxConfigInfo.multiline       = $false
$TxtBxConfigInfo.text            = "API Send Status Info"
$TxtBxConfigInfo.width           = 368
$TxtBxConfigInfo.height          = 20
$TxtBxConfigInfo.location        = New-Object System.Drawing.Point(5,8)
$TxtBxConfigInfo.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$TxtBxConfigInfo.enabled         = $false

$BtnPoERemove                    = New-Object system.Windows.Forms.Button
$BtnPoERemove.text               = "X"
$BtnPoERemove.width              = 32
$BtnPoERemove.height             = 30
$BtnPoERemove.location           = New-Object System.Drawing.Point(175,2)
$BtnPoERemove.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$BtnIsoRemove                    = New-Object system.Windows.Forms.Button
$BtnIsoRemove.text               = "X"
$BtnIsoRemove.width              = 32
$BtnIsoRemove.height             = 30
$BtnIsoRemove.location           = New-Object System.Drawing.Point(175,5)
$BtnIsoRemove.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$BtnTypeRemove                   = New-Object system.Windows.Forms.Button
$BtnTypeRemove.text              = "X"
$BtnTypeRemove.width             = 32
$BtnTypeRemove.height            = 30
$BtnTypeRemove.location          = New-Object System.Drawing.Point(175,5)
$BtnTypeRemove.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$BtnEnabledRemove                = New-Object system.Windows.Forms.Button
$BtnEnabledRemove.text           = "X"
$BtnEnabledRemove.width          = 32
$BtnEnabledRemove.height         = 30
$BtnEnabledRemove.location       = New-Object System.Drawing.Point(175,5)
$BtnEnabledRemove.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$BtnUDLDRemove                   = New-Object system.Windows.Forms.Button
$BtnUDLDRemove.text              = "X"
$BtnUDLDRemove.width             = 32
$BtnUDLDRemove.height            = 30
$BtnUDLDRemove.location          = New-Object System.Drawing.Point(175,5)
$BtnUDLDRemove.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$BtnSwitchSettings               = New-Object system.Windows.Forms.Button
$BtnSwitchSettings.text          = "Switch Settings"
$BtnSwitchSettings.width         = 93
$BtnSwitchSettings.height        = 35
$BtnSwitchSettings.location      = New-Object System.Drawing.Point(112,37)
$BtnSwitchSettings.Font          = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$SBCU.controls.AddRange(@($TxtBxRangeStart,$LblPrtRange,$PnlTags,$LblToolName,$Label2,$TxtBxRangeEnd,$BtnSend,$PnlEnabled,$PnlPoe,$PnlPortType,$PnlAllowed,$PnlNative,$PnlVoice,$PnlSTPG,$PnlIsolation,$PnlUDLD,$TxtBxLog,$ComboSwitches,$ComboPorts,$LblSwitches,$LblPorts,$BtnClear,$BtnUpdate,$PnlResult,$BtnSwitchSettings))
$PnlTags.controls.AddRange(@($LblTag,$TxtBxPortTags))
$PnlEnabled.controls.AddRange(@($LblPortEnabled,$RadEnabled,$RadDisabled,$BtnEnabledRemove))
$PnlPoe.controls.AddRange(@($RadPoEDisable,$RadPoEEnable,$LblPOE,$BtnPoERemove))
$PnlPortType.controls.AddRange(@($RadAccess,$RadTrunk,$LblType,$BtnTypeRemove))
$PnlAllowed.controls.AddRange(@($LblAllowed,$TxtBxAllowedVLAN))
$PnlNative.controls.AddRange(@($LblNative,$TxtBxNative))
$PnlVoice.controls.AddRange(@($LblVoice,$TxtBxVoice))
$PnlSTPG.controls.AddRange(@($LblSTPG,$ComboSTP))
$PnlIsolation.controls.AddRange(@($LblIsolation,$RadIsoFalse,$RadIsoTrue,$BtnIsoRemove))
$PnlUDLD.controls.AddRange(@($LblUDLD,$RadUDLDAlert,$RadUDLDEnforce,$BtnUDLDRemove))
$PnlResult.controls.AddRange(@($TxtBxConfigInfo))

#Set GUI Window Preferences
$SBCU.FormBorderStyle = 'Fixed3D'
$SBCU.MaximizeBox = $false
#End GUI Window Preferences
#endregion

#region Functions
Function Update-ConfigList {
$num = $switchport.number
$TxtBxLog.Text += 'Switchport: ' + $num + "`r`n"
if ($switchport.name -ne $null){
$TxtBxLog.Text += 'Name: ' + $switchport.name + "`r`n"
}
if ($switchport.tags -ne $null){
$TxtBxLog.Text += 'Tag: ' + $switchport.tags + "`r`n"
}
$TxtBxLog.Text += 'En: ' + $switchport.enabled + "`r`n"
$TxtBxLog.Text += 'PoE: ' + $switchport.poeEnabled + "`r`n"
$TxtBxLog.Text += 'Type: ' + $switchport.type + "`r`n"
$TxtBxLog.Text += 'Vlan: ' + $switchport.vlan + "`r`n"
if ($switchport.voiceVlan -ne $null){
$TxtBxLog.Text += 'Voice: ' + $switchport.voiceVlan + "`r`n"
}
$TxtBxLog.Text += 'AllowedVlan: ' + $switchport.allowedVlans + "`r`n"
$TxtBxLog.Text += 'Isolation: ' + $switchport.isolationEnabled + "`r`n"
$TxtBxLog.Text += 'RSTP: ' + $switchport.rstpEnabled + "`r`n"
$TxtBxLog.Text += 'STPGuard: ' + $switchport.stpGuard + "`r`n"
$TxtBxLog.Text += 'Negotation: ' + $switchport.linkNegotiation + "`r`n"
if ($switchport.portScheduleId -ne $null){
$TxtBxLog.Text += 'Schedule: ' + $switchport.portScheduleId + "`r`n"
}
$TxtBxLog.Text += 'UDLD: ' + $switchport.udld + "`r`n"
if ($switchport.accessPolicyNumber -ne $null){
$TxtBxLog.Text +=+ 'Policy Num: ' + $switchport.accessPolicyNumber + "`r`n"
}
if ($switchport.accessPolicyNumber -ne $null){
$TxtBxLog.Text +=+ 'MAC WL: ' + $switchport.macWhitelist + "`r`n"
}
if ($switchport.stickyMacWhitelist -ne $null){
$TxtBxLog.Text +=+ 'Sticky WL: ' + $switchport.stickyMacWhitelist + "`r`n"
}
if ($switchport.stickyMacWhitelistLimit -ne $null){
$TxtBxLog.Text +=+ 'Sticky WL Lim:  ' + $switchport.stickyMacWhitelistLimit + "`r`n"
}
$TxtBxLog.Text += '-----------------' + "`r`n"
}
#endregion

#Write your logic code here
#region Startup
$num = 0
foreach ($switchport in $Global:Switchconfig){
$num += 1
Update-ConfigList
}
#Build our PortComboBox Items
$ComboPorts.Items.Clear()
foreach ($switchport in $Global:Switchconfig.number){$ComboPorts.Items.AddRange(($Switchport))}
$ComboPorts.Items.AddRange(('All'))

#region Get-SwitchesOnStartup
#Grab our network ID for the new network
$GetNetworkID = $BaseURL + '/organizations/' + $OrgID + '/networks'
$request = Invoke-RestMethod -Method GET -Uri $GetNetworkID -Headers $headers
$NetworkID = ($request | Where-Object {$_.name -eq $Global:SwitchNetImport}).id

#Get the devices from the network, pass them into a variable
$GetNetDevices = $BaseURL + '/networks/' + $NetworkID + '/devices'
$Global:NetDevices = Invoke-RestMethod -Method GET -Uri $GetNetDevices -Headers $headers

foreach ($NetSwitch in $NetDevices){
if ($NetSwitch.model -match "MS"){$ComboSwitches.Items.AddRange(($NetSwitch.name + '-' + '(' + $NetSwitch.serial + ')' ))}
}
#endregion

#endregion

$TxtBxLog.Add_MouseHover({

})

$ComboPorts.Add_TextChanged({  
if ($ComboPorts.Text -ne "All"){
$TxtBxLog.Text = ''
    foreach ($switchport in $Global:Switchconfig | Where-Object {$_.number -like $ComboPorts.Text}){Update-ConfigList}
}
if ($ComboPorts.Text -eq "All"){
$TxtBxLog.Text = ''
    foreach ($switchport in $Global:Switchconfig){Update-ConfigList}
}

})

#region ActionButtons

#Commit Configuration
$BtnSend.Add_Click({
$TxtBxConfigInfo.enabled = $true
$TxtBxConfigInfo.ForeColor       = [System.Drawing.ColorTranslator]::FromHtml("")
$TxtBxConfigInfo.Text = 'Sending our Switch API Configuration now.'
#Send our Configuration
foreach ($switchport in $Global:switchconfig){

if ($switchport.vlan -ne ""){
    $body += @{
            "vlan" = $switchport.vlan
              }
}
if ($switchport.name -ne $null){
    $body += @{
            "name" = $switchport.name
              }
}
if (($switchport.tags -ne "") -and ($switchport.tags -ne $null)){
    $body += @{
            "tags" = $switchport.tags
              }
}
if ($switchport.enabled -ne ""){
    $body += @{
            "enabled" = $switchport.enabled
              }
}
if ($switchport.poeEnabled -ne ""){
    $body += @{
            "poeEnabled" = $switchport.poeEnabled
              }
}
if ($switchport.type -ne ""){
    $body += @{
            "type" = $switchport.type
              }
}
if ($switchport.allowedVlans -ne ""){
    $body += @{
            "allowedVlans" = $switchport.allowedVlans
              }
}
if ($switchport.rstpEnabled -ne ""){
    $body += @{
            "rstpEnabled" = $switchport.rstpEnabled
              }
}
if ($switchport.udld -ne ""){
    $body += @{
            "udld" = $switchport.udld
              }
}
if ($switchport.stpGuard -ne ""){
    $body += @{
            "stpGuard" = $switchport.stpGuard
              }
}
if (($switchport.voiceVlan -ne "") -and ($switchport.voiceVlan -ne $null)){
    $body += @{
            "voiceVlan" = $switchport.voiceVlan
              }
}
if ($switchport.isolationEnabled -ne ""){
    $body += @{
            "isolationEnabled" = $switchport.isolationEnabled
              }
}

 $actions +=@(
     @{
        "resource" = '/devices/' + $CurDevSerial + '/switchPorts/' + $switchport.number
        "operation" = "update" 
        "body" = $body          
      }      
        
      )

#Do we need to set body back to null? Yep.
$body = $null
}


$ActionBatch = @{
    "confirmed" = $true
    "synchronous" = $false
    "actions" =@(
        $actions    
    )
} 

#Send Batch Action via POST

$ActBatchURI = $BaseURL + '/organizations/' + $OrgID + '/actionBatches/'
$result = Invoke-RestMethod -Method POST -Uri $ActBatchURI -Headers $headers -Body ($ActionBatch | ConvertTo-Json -Depth 3)

$TxtBxConfigInfo.ForeColor       = [System.Drawing.ColorTranslator]::FromHtml("#7ed321")
$TxtBxConfigInfo.Text = 'Switch API Configuration Sent!'
})

#Update Contextuals and switchconfig information
$BtnUpdate.Add_Click({
foreach ($switchport in $Global:switchconfig){
	#Main Update loop
	if (($switchport.number -ge $TxtBxRangeStart.Text) -and ($switchport.number -le $TxtBxRangeEnd.Text)){
		#Tags
		if ($TxtBxPortTags.Text -ne $null){$Global:switchconfig[($switchport.number -1)].tags = $TxtBxPortTags.Text}
		#Allowed VLANs
		if ($TxtBxAllowedVLAN.Text -ne $null){$Global:switchconfig[($switchport.number -1)].allowedVlans = $TxtBxAllowedVLAN.Text}
		#Enabled T/F
		if ($RadEnabled.Checked -eq $true){$Global:switchconfig[($switchport.number -1)].enabled = $true}
		if ($RadDisabled.Checked -eq $true){$Global:switchconfig[($switchport.number -1)].enabled = $false}
		#PoE
		if ($RadPoEEnable.Checked -eq $true){$Global:switchconfig[($switchport.number -1)].poeEnabled = $true}
		if ($RadPoEDisable.Checked -eq $true){$Global:switchconfig[($switchport.number -1)].poeEnabled = $false}
		#Type
		if ($RadTrunk.Checked -eq $true){$Global:switchconfig[($switchport.number -1)].type = "trunk"}
		if ($RadAccess.Checked -eq $true){$Global:switchconfig[($switchport.number -1)].type = "access"}
		#Native VLAN
		if ($TxtBxNative.Text -ne $null){$Global:switchconfig[($switchport.number -1)].vlan = $TxtBxNative.Text}
		#Voice VLAN
		if ($TxtBxVoice.Text -ne $null){$Global:switchconfig[($switchport.number -1)].voiceVlan = $TxtBxVoice.Text}
		#RSTPGuard
		$Global:switchconfig[($switchport.number -1)].stpGuard = $ComboSTP.Text
		#Port Isolation
		if ($RadIsoTrue.Checked -eq $true){$Global:switchconfig[($switchport.number -1)].isolationEnabled = $true}
		if ($RadIsoFalse.Checked -eq $true){$Global:switchconfig[($switchport.number -1)].isolationEnabled = $false}
		#UDLD
		if ($RadUDLDAlert.Checked -eq $true){$Global:switchconfig[($switchport.number -1)].udld = "Alert only"}
		if ($RadUDLDEnforce.Checked -eq $true){$Global:switchconfig[($switchport.number -1)].udld = "Enforce"}
	}
}

#Clear out Logging info, then re-create it
$TxtBxLog.Text = ''
$num = 0
foreach ($switchport in $Global:Switchconfig){
$num += 1
Update-ConfigList
}

})

#Load config from the device
$ComboSwitches.Add_TextChanged({
$Global:Switchconfig = ''
if ($ComboSwitches.Text -match ($Global:NetDevices | Where-Object {$_.model -match "MS"}).serial){
   foreach ($Device in $Global:NetDevices){
        if ($ComboSwitches.Text -match $Device.serial){
            $GetSwitchConfig = $BaseURL + '/devices/' + $Device.serial + '/switchPorts'
            $Global:Switchconfig = Invoke-RestMethod -Method GET -Uri $GetSwitchConfig -Headers $headers
            #Set up a restore variable
            $Global:ConfigRestore = $Global:Switchconfig
            #Set a variable equal to the serial of the device that was imported
            $Global:CurDevSerial = $Device.serial
        }
    }
#Clear out Logging info, then re-create it
$TxtBxLog.Text = ''
$num = 0
foreach ($switchport in $Global:Switchconfig){
Update-ConfigList
}

#Build our PortComboBox Items
$ComboPorts.Items.Clear()
foreach ($switchport in $Global:Switchconfig.number){$ComboPorts.Items.AddRange(($Switchport))}
$ComboPorts.Items.AddRange(('All'))
}

})

#Wipe all settings and stored config
$BtnClear.Add_Click({
#Set all of our options to $null out
$TxtBxRangeStart.Text = ""
$TxtBxRangeEnd.Text = ""
$TxtBxPortTags.Text = ""
$TxtBxAllowedVLAN.Text = ""
$RadEnabled.Checked = $false
$RadDisabled.Checked = $false
$RadPoEEnable.Checked = $false
$RadPoEDisable.Checked = $false
$RadAccess.Checked = $false
$RadTrunk.Checked = $false
$TxtBxNative.Text = ""
$TxtBxVoice.Text = ""
$ComboSTP.Text = ""
$RadIsoFalse.Checked = $false
$RadIsoTrue.Checked = $false
$RadUDLDAlert.Checked = $false
$RadUDLDEnforce.Checked = $false
#Restore all of our configuration changes since opening the tool
$Global:Switchconfig = $Global:ConfigRestore

#Re-create our combobox information
#Clear out Logging info, then re-create it
$TxtBxLog.Text = ''
$num = 0
foreach ($switchport in $Global:Switchconfig){
Update-ConfigList
}

#Build our PortComboBox Items
$ComboPorts.Items.Clear()
foreach ($switchport in $Global:Switchconfig.number){$ComboPorts.Items.AddRange(($Switchport))}
$ComboPorts.Items.AddRange(('All'))

})

#BtnRemovalWipes
$BtnPoERemove.Add_Click({
$RadPoEEnable.Checked = $false
$RadPoEDisable.Checked = $false
})
$BtnIsoRemove.Add_Click({
$RadIsoTrue.Checked = $false
$RadIsoFalse.Checked = $false
})
$BtnTypeRemove.Add_Click({
$RadTrunk.Checked = $false
$RadAccess.Checked = $false
})
$BtnEnabledRemove.Add_Click({
$RadEnabled.Checked = $false
$RadDisabled.Checked = $false
})
$BtnUDLDRemove.Add_Click({
$RadUDLDAlert.Checked = $false
$RadUDLDEnforce.Checked = $false
})

#endregion
[void]$SBCU.ShowDialog()
