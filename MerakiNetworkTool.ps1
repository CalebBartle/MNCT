<#
.NAME
    Meraki Network Configuration Tool
.DESCRIPTION
    This tool is used to build highly customizable Meraki Networks in a quick fashion in comparison to creating them manually or through a template
.NOTES
    Written and created by Caleb Bartle. Various Modules modeled from are also used: https://github.com/sanderkl/PSMeraki/tree/master/PSMeraki/Public.
#>
#region ISE Debugger
function Set-Debugging{
    if ($ChkBxDebug.Checked -eq $false){
       Get-PSBreakpoint -Variable break | Disable-PSBreakpoint
    }
    if ($Global:break -eq $true){
        Get-PSBreakpoint -Variable break | Enable-PSBreakpoint
        Set-PSBreakpoint -Variable break -Mode Read -Script $pscommandpath
        Add-Type -AssemblyName System.Windows.Forms
    }
    }
    function Get-CurrentLine {
        Write-Host 'ERROR FOUND ON LINE:' $Myinvocation.ScriptlineNumber
    }
    function ParseErrorForResponseBody($Error) {
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            if ($Error.Exception.Response) {  
                $Reader = New-Object System.IO.StreamReader($Error.Exception.Response.GetResponseStream())
                $Reader.BaseStream.Position = 0
                $Reader.DiscardBufferedData()
                $ResponseBody = $Reader.ReadToEnd()
                if ($ResponseBody.StartsWith('{')) {
                    $ResponseBody = $ResponseBody | ConvertFrom-Json
                }
                return $ResponseBody
            }
        }
        else {
            return $Error.ErrorDetails.Message
        }
    }
    #endregion
#region Logging Color
#Error Logging colors for the textbox
function Set-ColoredLine {
    param( 
        [Parameter(Mandatory = $true, Position = 0)]
        [System.Windows.Forms.RichTextBox]$box,
        [Parameter(Mandatory = $true, Position = 1)]
        [System.Drawing.Color]$color,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]$text
    )
    $box.SelectionStart = $box.TextLength
    $box.SelectionLength = 0
    $box.SelectionColor = $color
    $box.AppendText($text)
    $box.AppendText([Environment]::NewLine)
}
#endregion
    
[System.Windows.Forms.Application]::EnableVisualStyles()
#region GUI Configuration
$MerakiNetworkConfigurationTool       = New-Object system.Windows.Forms.Form
$MerakiNetworkConfigurationTool.ClientSize  = New-Object System.Drawing.Point(1607,695)
$MerakiNetworkConfigurationTool.text  = "Meraki Network Configuration Tool V1.9.5 (Beta)"
$MerakiNetworkConfigurationTool.TopMost  = $false
$MerakiNetworkConfigurationTool.icon  = "$pwd\icon.ico"
$MerakiNetworkConfigurationTool.BackColor  = [System.Drawing.ColorTranslator]::FromHtml("#626161")
#Set GUI Window Preferences
$MerakiNetworkConfigurationTool.FormBorderStyle = 'Fixed3D'
$MerakiNetworkConfigurationTool.MaximizeBox = $false
#End GUI Window Preferences
    
#region Network/VLAN Information

$BtnNetClear                     = New-Object system.Windows.Forms.Button
$BtnNetClear.text                = "X"
$BtnNetClear.width               = 25
$BtnNetClear.height              = 25
$BtnNetClear.location            = New-Object System.Drawing.Point(466,6)
$BtnNetClear.Font                = New-Object System.Drawing.Font('Segoe UI',10)
    
$LblNetID                        = New-Object system.Windows.Forms.Label
$LblNetID.text                   = "ID:"
$LblNetID.AutoSize               = $true
$LblNetID.width                  = 25
$LblNetID.height                 = 10
$LblNetID.location               = New-Object System.Drawing.Point(5,61)
$LblNetID.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$LblNetCidr                      = New-Object system.Windows.Forms.Label
$LblNetCidr.text                 = "Cidr"
$LblNetCidr.AutoSize             = $true
$LblNetCidr.width                = 25
$LblNetCidr.height               = 10
$LblNetCidr.location             = New-Object System.Drawing.Point(193,61)
$LblNetCidr.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$Label20                         = New-Object system.Windows.Forms.Label
$Label20.text                    = "Organization"
$Label20.AutoSize                = $true
$Label20.width                   = 25
$Label20.height                  = 10
$Label20.location                = New-Object System.Drawing.Point(219,7)
$Label20.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtNetworkName                  = New-Object system.Windows.Forms.ComboBox
$TxtNetworkName.text             = "Test"
$TxtNetworkName.width            = 216
$TxtNetworkName.height           = 20
$TxtNetworkName.location         = New-Object System.Drawing.Point(1,29)
$TxtNetworkName.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$PnlNetInfo                          = New-Object system.Windows.Forms.Panel
$PnlNetInfo.height                   = 201
$PnlNetInfo.width                    = 497
$PnlNetInfo.location                 = New-Object System.Drawing.Point(3,4)
$PnlNetInfo.BackColor                = [System.Drawing.ColorTranslator]::FromHtml("#cecece")
    
$lblNetworkNameInfo              = New-Object system.Windows.Forms.Label
$lblNetworkNameInfo.text                     = "Network Name"
$lblNetworkNameInfo.AutoSize                 = $true
$lblNetworkNameInfo.width                    = 25
$lblNetworkNameInfo.height                   = 10
$lblNetworkNameInfo.location                 = New-Object System.Drawing.Point(5,5)
$lblNetworkNameInfo.Font                     = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxNet2Range                  = New-Object system.Windows.Forms.TextBox
$TxtBxNet2Range.multiline        = $false
$TxtBxNet2Range.text             = "192.168.5.0"
$TxtBxNet2Range.width            = 127
$TxtBxNet2Range.height           = 20
$TxtBxNet2Range.location         = New-Object System.Drawing.Point(59,122)
$TxtBxNet2Range.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Subnet:"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(65,58)
$Label2.Font                     = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxNet1Range                  = New-Object system.Windows.Forms.TextBox
$TxtBxNet1Range.multiline        = $false
$TxtBxNet1Range.text             = "192.168.0.0"
$TxtBxNet1Range.width            = 125
$TxtBxNet1Range.height           = 20
$TxtBxNet1Range.location         = New-Object System.Drawing.Point(60,81)
$TxtBxNet1Range.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBx1VLANName                  = New-Object system.Windows.Forms.TextBox
$TxtBx1VLANName.multiline        = $false
$TxtBx1VLANName.text             = "VLAN_Name"
$TxtBx1VLANName.width            = 88
$TxtBx1VLANName.height           = 20
$TxtBx1VLANName.location         = New-Object System.Drawing.Point(236,81)
$TxtBx1VLANName.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$LblVlanName1                    = New-Object system.Windows.Forms.Label
$LblVlanName1.text               = "VLAN Name"
$LblVlanName1.AutoSize           = $true
$LblVlanName1.width              = 25
$LblVlanName1.height             = 10
$LblVlanName1.location           = New-Object System.Drawing.Point(241,60)
$LblVlanName1.Font               = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBx2VLANName                  = New-Object system.Windows.Forms.TextBox
$TxtBx2VLANName.multiline        = $false
$TxtBx2VLANName.text             = "VLAN_Name_2"
$TxtBx2VLANName.width            = 88
$TxtBx2VLANName.height           = 20
$TxtBx2VLANName.location         = New-Object System.Drawing.Point(236,122)
$TxtBx2VLANName.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxNet3Range                  = New-Object system.Windows.Forms.TextBox
$TxtBxNet3Range.multiline        = $false
$TxtBxNet3Range.text             = "192.168.6.0"
$TxtBxNet3Range.width            = 128
$TxtBxNet3Range.height           = 20
$TxtBxNet3Range.location         = New-Object System.Drawing.Point(59,169)
$TxtBxNet3Range.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBx3VLANName                  = New-Object system.Windows.Forms.TextBox
$TxtBx3VLANName.multiline        = $false
$TxtBx3VLANName.text             = "VLAN_Name_3"
$TxtBx3VLANName.width            = 88
$TxtBx3VLANName.height           = 20
$TxtBx3VLANName.location         = New-Object System.Drawing.Point(236,169)
$TxtBx3VLANName.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$Chk1VLANVPN                     = New-Object system.Windows.Forms.CheckBox
$Chk1VLANVPN.text                = "VPN?"
$Chk1VLANVPN.AutoSize            = $false
$Chk1VLANVPN.width               = 51
$Chk1VLANVPN.height              = 20
$Chk1VLANVPN.location            = New-Object System.Drawing.Point(431,84)
$Chk1VLANVPN.Font                = New-Object System.Drawing.Font('Segoe UI',10)
    
$Chk2VLANVPN                     = New-Object system.Windows.Forms.CheckBox
$Chk2VLANVPN.text                = "VPN?"
$Chk2VLANVPN.AutoSize            = $false
$Chk2VLANVPN.width               = 51
$Chk2VLANVPN.height              = 20
$Chk2VLANVPN.location            = New-Object System.Drawing.Point(431,127)
$Chk2VLANVPN.Font                = New-Object System.Drawing.Font('Segoe UI',10)
    
$Chk3VLANVPN                     = New-Object system.Windows.Forms.CheckBox
$Chk3VLANVPN.text                = "VPN?"
$Chk3VLANVPN.AutoSize            = $false
$Chk3VLANVPN.width               = 51
$Chk3VLANVPN.height              = 20
$Chk3VLANVPN.location            = New-Object System.Drawing.Point(431,173)
$Chk3VLANVPN.Font                = New-Object System.Drawing.Font('Segoe UI',10)
    
$ComboOrgName                    = New-Object system.Windows.Forms.ComboBox
$ComboOrgName.width              = 100
$ComboOrgName.height             = 20
$ComboOrgName.location           = New-Object System.Drawing.Point(219,29)
$ComboOrgName.Font               = New-Object System.Drawing.Font('Segoe UI',10)
    
$V1VLAN                          = New-Object system.Windows.Forms.TextBox
$V1VLAN.multiline                = $false
$V1VLAN.text                     = "1"
$V1VLAN.width                    = 55
$V1VLAN.height                   = 20
$V1VLAN.location                 = New-Object System.Drawing.Point(1,81)
$V1VLAN.Font                     = New-Object System.Drawing.Font('Segoe UI',10)
    
$V2VLAN                          = New-Object system.Windows.Forms.TextBox
$V2VLAN.multiline                = $false
$V2VLAN.text                     = "2"
$V2VLAN.width                    = 55
$V2VLAN.height                   = 20
$V2VLAN.location                 = New-Object System.Drawing.Point(1,122)
$V2VLAN.Font                     = New-Object System.Drawing.Font('Segoe UI',10)
    
$V3VLAN                          = New-Object system.Windows.Forms.TextBox
$V3VLAN.multiline                = $false
$V3VLAN.text                     = "3"
$V3VLAN.width                    = 55
$V3VLAN.height                   = 20
$V3VLAN.location                 = New-Object System.Drawing.Point(1,169)
$V3VLAN.Font                     = New-Object System.Drawing.Font('Segoe UI',10)
    
$lblTimeZone                     = New-Object system.Windows.Forms.Label
$lblTimeZone.text                = "Network Time Zone"
$lblTimeZone.AutoSize            = $true
$lblTimeZone.width               = 25
$lblTimeZone.height              = 10
$lblTimeZone.location            = New-Object System.Drawing.Point(333,5)
$lblTimeZone.Font                = New-Object System.Drawing.Font('Segoe UI',10)
    
$ComboTimeZone                   = New-Object system.Windows.Forms.ComboBox
$ComboTimeZone.text              = "America/Chicago"
$ComboTimeZone.width             = 129
$ComboTimeZone.height            = 20
@('America/Chicago','America/New_York','America/Los_Angeles','US/Central','US/Eastern','US/Pacific','US/Arizona') | ForEach-Object {[void] $ComboTimeZone.Items.Add($_)}
$ComboTimeZone.location          = New-Object System.Drawing.Point(330,29)
$ComboTimeZone.Font              = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtCIDR3                        = New-Object system.Windows.Forms.TextBox
$TxtCIDR3.multiline              = $false
$TxtCIDR3.text                   = "/24"
$TxtCIDR3.width                  = 43
$TxtCIDR3.height                 = 20
$TxtCIDR3.location               = New-Object System.Drawing.Point(188,169)
$TxtCIDR3.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtCIDR2                        = New-Object system.Windows.Forms.TextBox
$TxtCIDR2.multiline              = $false
$TxtCIDR2.text                   = "/24"
$TxtCIDR2.width                  = 43
$TxtCIDR2.height                 = 20
$TxtCIDR2.location               = New-Object System.Drawing.Point(188,122)
$TxtCIDR2.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtCIDR1                        = New-Object system.Windows.Forms.TextBox
$TxtCIDR1.multiline              = $false
$TxtCIDR1.text                   = "/24"
$TxtCIDR1.width                  = 43
$TxtCIDR1.height                 = 20
$TxtCIDR1.location               = New-Object System.Drawing.Point(188,81)
$TxtCIDR1.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtAppIP1                       = New-Object system.Windows.Forms.TextBox
$TxtAppIP1.multiline             = $false
$TxtAppIP1.text                  = "192.168.0.1"
$TxtAppIP1.width                 = 94
$TxtAppIP1.height                = 20
$TxtAppIP1.location              = New-Object System.Drawing.Point(329,81)
$TxtAppIP1.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$LblApplianceIP1                 = New-Object system.Windows.Forms.Label
$LblApplianceIP1.text            = "Appliance IP:"
$LblApplianceIP1.AutoSize        = $true
$LblApplianceIP1.width           = 25
$LblApplianceIP1.height          = 10
$LblApplianceIP1.location        = New-Object System.Drawing.Point(332,60)
$LblApplianceIP1.Font            = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtAppIP2                       = New-Object system.Windows.Forms.TextBox
$TxtAppIP2.multiline             = $false
$TxtAppIP2.text                  = "192.168.5.1"
$TxtAppIP2.width                 = 94
$TxtAppIP2.height                = 20
$TxtAppIP2.location              = New-Object System.Drawing.Point(329,124)
$TxtAppIP2.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtAppIP3                       = New-Object system.Windows.Forms.TextBox
$TxtAppIP3.multiline             = $false
$TxtAppIP3.text                  = "192.168.6.1"
$TxtAppIP3.width                 = 94
$TxtAppIP3.height                = 20
$TxtAppIP3.location              = New-Object System.Drawing.Point(329,169)
$TxtAppIP3.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
#endregion
    
#region SSID Information
$BtnClearSSID                    = New-Object system.Windows.Forms.Button
$BtnClearSSID.text               = "X"
$BtnClearSSID.width              = 25
$BtnClearSSID.height             = 25
$BtnClearSSID.location           = New-Object System.Drawing.Point(466,3)
$BtnClearSSID.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
    
$PnlWireless                     = New-Object system.Windows.Forms.Panel
$PnlWireless.height              = 107
$PnlWireless.width               = 495
$PnlWireless.location            = New-Object System.Drawing.Point(3,208)
$PnlWireless.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#cecece")
    
$Label8                          = New-Object system.Windows.Forms.Label
$Label8.text                     = "SSID/Wireless"
$Label8.AutoSize                 = $true
$Label8.width                    = 25
$Label8.height                   = 10
$Label8.location                 = New-Object System.Drawing.Point(366,7)
$Label8.Font                     = New-Object System.Drawing.Font('Segoe UI',10)
    
$LblSSIDInfo                          = New-Object system.Windows.Forms.Label
$LblSSIDInfo.text                     = 'Y=Open' + "`r`n" + 'N=PSK'
$LblSSIDInfo.AutoSize                 = $true
$LblSSIDInfo.width                    = 25
$LblSSIDInfo.height                   = 25
$LblSSIDInfo.location                 = New-Object System.Drawing.Point(437,30)
$LblSSIDInfo.Font                     = New-Object System.Drawing.Font('Segoe UI',10)
    
$Label11                         = New-Object system.Windows.Forms.Label
$Label11.text                    = "SSID Name"
$Label11.AutoSize                = $true
$Label11.width                   = 25
$Label11.height                  = 10
$Label11.location                = New-Object System.Drawing.Point(13,7)
$Label11.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
    
$Label12                         = New-Object system.Windows.Forms.Label
$Label12.text                    = "SSID PSK (Enter N=NoPWD)"
$Label12.AutoSize                = $true
$Label12.width                   = 25
$Label12.height                  = 10
$Label12.location                = New-Object System.Drawing.Point(215,9)
$Label12.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
    
$SSIDN                          = New-Object system.Windows.Forms.TextBox
$SSIDN.text                     = "Wireless Network Name"
$SSIDN.width                    = 197
$SSIDN.height                   = 65
$SSIDN.location                 = New-Object System.Drawing.Point(13,30)
$SSIDN.Font                     = New-Object System.Drawing.Font('Segoe UI',10)
$SSIDN.multiline                = $true
$SSIDN.WordWrap                 = $false
$SSIDN.Scrollbars               = "Horizontal"
    
$SSIDPSK                        = New-Object system.Windows.Forms.TextBox
$SSIDPSK.width                  = 154
$SSIDPSK.height                 = 65
$SSIDPSK.location               = New-Object System.Drawing.Point(216,30)
$SSIDPSK.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
$SSIDPSK.multiline                = $true
$SSIDPSK.WordWrap                 = $false
$SSIDPSK.Scrollbars               = "Horizontal"
    
$SSIDType                        = New-Object system.Windows.Forms.TextBox
$SSIDType.width                  = 65
$SSIDType.height                 = 65
$SSIDType.location               = New-Object System.Drawing.Point(371,30)
$SSIDType.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
$SSIDType.multiline              = $true
$SSIDType.WordWrap               = $false
$SSIDType.Scrollbars             = "Horizontal"
#endregion
    
#region Firewall Configuration
$BtnFWRules                      = New-Object system.Windows.Forms.Button
$BtnFWRules.text                 = "Upload L3FW Rules"
$BtnFWRules.width                = 150
$BtnFWRules.height               = 23
$BtnFWRules.location             = New-Object System.Drawing.Point(764,261)
$BtnFWRules.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
$BtnFWRules.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("#c1c1c1")
    
$BtnFW7Rules                     = New-Object system.Windows.Forms.Button
$BtnFW7Rules.text                = "Upload L7FW Rules"
$BtnFW7Rules.width               = 150
$BtnFW7Rules.height              = 23
$BtnFW7Rules.location            = New-Object System.Drawing.Point(923,261)
$BtnFW7Rules.Font                = New-Object System.Drawing.Font('Segoe UI',10)
$BtnFW7Rules.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("#c1c1c1")
#endregion
    
#region Device Assignment
$PnlDeviceAssignment             = New-Object system.Windows.Forms.Panel
$PnlDeviceAssignment.height                   = 205
$PnlDeviceAssignment.width                    = 495
$PnlDeviceAssignment.location                 = New-Object System.Drawing.Point(0,319)
$PnlDeviceAssignment.BackColor                = [System.Drawing.ColorTranslator]::FromHtml("#cecece")
$PnlDeviceAssignment.HorizontalScroll.Maximum = 100
$PnlDeviceAssignment.AutoScroll = $true
$PnlDeviceAssignment.VerticalScroll.Visible = $false
    
$LblDevAddress                  = New-Object system.Windows.Forms.Label
$LblDevAddress.text             = "Device Address:"
$LblDevAddress.AutoSize         = $true
$LblDevAddress.width            = 25
$LblDevAddress.height           = 10
$LblDevAddress.location         = New-Object System.Drawing.Point(298,0)
$LblDevAddress.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxDevAddress                 = New-Object system.Windows.Forms.TextBox
$TxtBxDevAddress.multiline       = $true
$TxtBxDevAddress.WordWrap        = $false
$TxtBxDevAddress.width           = 101
$TxtBxDevAddress.height          = 152
$TxtBxDevAddress.enabled         = $true
$TxtBxDevAddress.location        = New-Object System.Drawing.Point(298,23)
$TxtBxDevAddress.Font            = New-Object System.Drawing.Font('Segoe UI',10)
$TxtBxDevAddress.Scrollbars      = "Horizontal"
    
$LblDevModel                  = New-Object system.Windows.Forms.Label
$LblDevModel.text             = "Device Model:"
$LblDevModel.AutoSize         = $true
$LblDevModel.width            = 25
$LblDevModel.height           = 10
$LblDevModel.location         = New-Object System.Drawing.Point(400,0)
$LblDevModel.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxDevModel                 = New-Object system.Windows.Forms.TextBox
$TxtBxDevModel.multiline       = $true
$TxtBxDevModel.WordWrap        = $false
$TxtBxDevModel.width           = 101
$TxtBxDevModel.height          = 152
$TxtBxDevModel.enabled         = $true
$TxtBxDevModel.location        = New-Object System.Drawing.Point(400,23)
$TxtBxDevModel.Font            = New-Object System.Drawing.Font('Segoe UI',10)
$TxtBxDevModel.Scrollbars      = "Horizontal"
    
$LblDevName                  = New-Object system.Windows.Forms.Label
$LblDevName.text             = "Device Name:"
$LblDevName.AutoSize         = $true
$LblDevName.width            = 25
$LblDevName.height           = 10
$LblDevName.location         = New-Object System.Drawing.Point(502,0)
$LblDevName.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxDevName                 = New-Object system.Windows.Forms.TextBox
$TxtBxDevName.multiline       = $true
$TxtBxDevName.WordWrap        = $false
$TxtBxDevName.width           = 101
$TxtBxDevName.height          = 152
$TxtBxDevName.enabled         = $true
$TxtBxDevName.location        = New-Object System.Drawing.Point(502,23)
$TxtBxDevName.Font            = New-Object System.Drawing.Font('Segoe UI',10)
$TxtBxDevName.Scrollbars      = "Horizontal"
    
$Label14                         = New-Object system.Windows.Forms.Label
$Label14.text                    = "Device Serial:"
$Label14.AutoSize                = $true
$Label14.width                   = 25
$Label14.height                  = 10
$Label14.location                = New-Object System.Drawing.Point(0,0)
$Label14.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxSD                        = New-Object system.Windows.Forms.TextBox
$TxtBxSD.width                  = 112
$TxtBxSD.height                 = 152
$TxtBxSD.location               = New-Object System.Drawing.Point(0,23)
$TxtBxSD.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
$TxtBxSD.multiline              = $true
$TxtBxSD.WordWrap               = $false
$TxtBxSD.Scrollbars             = "Horizontal"
    
$LblDeviceNotes                  = New-Object system.Windows.Forms.Label
$LblDeviceNotes.text             = "Notes:"
$LblDeviceNotes.AutoSize         = $true
$LblDeviceNotes.width            = 25
$LblDeviceNotes.height           = 10
$LblDeviceNotes.location         = New-Object System.Drawing.Point(112,0)
$LblDeviceNotes.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxDN                        = New-Object system.Windows.Forms.TextBox
$TxtBxDN.width                  = 92
$TxtBxDN.height                 = 152
$TxtBxDN.location               = New-Object System.Drawing.Point(112,23)
$TxtBxDN.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
$TxtBxDN.multiline              = $true
$TxtBxDN.WordWrap               = $false
$TxtBxDN.Scrollbars             = "Horizontal"
    
$LblDeviceTags                  = New-Object system.Windows.Forms.Label
$LblDeviceTags.text             = "Device Tags:"
$LblDeviceTags.AutoSize         = $true
$LblDeviceTags.width            = 25
$LblDeviceTags.height           = 10
$LblDeviceTags.location         = New-Object System.Drawing.Point(205,0)
$LblDeviceTags.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxDevTag                    = New-Object system.Windows.Forms.TextBox
$TxtBxDevTag.width              = 92
$TxtBxDevTag.height             = 152
$TxtBxDevTag.location           = New-Object System.Drawing.Point(205,23)
$TxtBxDevTag.Font               = New-Object System.Drawing.Font('Segoe UI',10)
$TxtBxDevTag.multiline          = $true
$TxtBxDevTag.WordWrap           = $false
$TxtBxDevTag.Scrollbars         = "Horizontal"
#endregion
    
#region DNS Configuration
$BtnClearDNS                     = New-Object system.Windows.Forms.Button
$BtnClearDNS.text                = "X"
$BtnClearDNS.width               = 25
$BtnClearDNS.height              = 25
$BtnClearDNS.location            = New-Object System.Drawing.Point(219,2)
$BtnClearDNS.Font                = New-Object System.Drawing.Font('Segoe UI',10)
    
$Label19                         = New-Object system.Windows.Forms.Label
$Label19.text                    = "DNS Configuration"
$Label19.AutoSize                = $true
$Label19.width                   = 25
$Label19.height                  = 10
$Label19.location                = New-Object System.Drawing.Point(60,9)
$Label19.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
    
$PnlDNSDHCPConf                  = New-Object system.Windows.Forms.Panel
$PnlDNSDHCPConf.height           = 222
$PnlDNSDHCPConf.width            = 249
$PnlDNSDHCPConf.location         = New-Object System.Drawing.Point(503,4)
$PnlDNSDHCPConf.BackColor        = [System.Drawing.ColorTranslator]::FromHtml("#cecece")
    
$ChkPDNS1                        = New-Object system.Windows.Forms.CheckBox
$ChkPDNS1.text                   = "ProxyDNS?"
$ChkPDNS1.AutoSize               = $false
$ChkPDNS1.width                  = 95
$ChkPDNS1.height                 = 20
$ChkPDNS1.location               = New-Object System.Drawing.Point(5,37)
$ChkPDNS1.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$ChkIDNS1                        = New-Object system.Windows.Forms.CheckBox
$ChkIDNS1.text                   = "InternalDNS?"
$ChkIDNS1.AutoSize               = $false
$ChkIDNS1.width                  = 112
$ChkIDNS1.height                 = 20
$ChkIDNS1.location               = New-Object System.Drawing.Point(117,37)
$ChkIDNS1.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxNS1                        = New-Object system.Windows.Forms.TextBox
$TxtBxNS1.multiline              = $false
$TxtBxNS1.text                   = "8.8.8.8"
$TxtBxNS1.width                  = 118
$TxtBxNS1.height                 = 20
$TxtBxNS1.location               = New-Object System.Drawing.Point(7,80)
$TxtBxNS1.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$ChkPDNS2                        = New-Object system.Windows.Forms.CheckBox
$ChkPDNS2.text                   = "ProxyDNS?"
$ChkPDNS2.AutoSize               = $false
$ChkPDNS2.width                  = 102
$ChkPDNS2.height                 = 20
$ChkPDNS2.location               = New-Object System.Drawing.Point(5,109)
$ChkPDNS2.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$ChkIDNS2                        = New-Object system.Windows.Forms.CheckBox
$ChkIDNS2.text                   = "InternalDNS?"
$ChkIDNS2.AutoSize               = $false
$ChkIDNS2.width                  = 112
$ChkIDNS2.height                 = 20
$ChkIDNS2.location               = New-Object System.Drawing.Point(115,108)
$ChkIDNS2.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$ChkIDNS3                        = New-Object system.Windows.Forms.CheckBox
$ChkIDNS3.text                   = "InternalDNS?"
$ChkIDNS3.AutoSize               = $false
$ChkIDNS3.width                  = 112
$ChkIDNS3.height                 = 20
$ChkIDNS3.location               = New-Object System.Drawing.Point(115,173)
$ChkIDNS3.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$ChkPDNS3                        = New-Object system.Windows.Forms.CheckBox
$ChkPDNS3.text                   = "ProxyDNS?"
$ChkPDNS3.AutoSize               = $false
$ChkPDNS3.width                  = 95
$ChkPDNS3.height                 = 20
$ChkPDNS3.location               = New-Object System.Drawing.Point(8,173)
$ChkPDNS3.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$Label25                         = New-Object system.Windows.Forms.Label
$Label25.text                    = "Specify Name Servers:"
$Label25.AutoSize                = $true
$Label25.width                   = 25
$Label25.height                  = 10
$Label25.location                = New-Object System.Drawing.Point(50,58)
$Label25.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxNS2                        = New-Object system.Windows.Forms.TextBox
$TxtBxNS2.multiline              = $false
$TxtBxNS2.text                   = "8.8.8.8"
$TxtBxNS2.width                  = 119
$TxtBxNS2.height                 = 20
$TxtBxNS2.location               = New-Object System.Drawing.Point(6,134)
$TxtBxNS2.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxNS3                        = New-Object system.Windows.Forms.TextBox
$TxtBxNS3.multiline              = $false
$TxtBxNS3.text                   = "8.8.8.8"
$TxtBxNS3.width                  = 121
$TxtBxNS3.height                 = 20
$TxtBxNS3.location               = New-Object System.Drawing.Point(4,198)
$TxtBxNS3.Font                   = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxNS12                       = New-Object system.Windows.Forms.TextBox
$TxtBxNS12.multiline             = $false
$TxtBxNS12.text                  = "8.8.8.8"
$TxtBxNS12.width                 = 118
$TxtBxNS12.height                = 20
$TxtBxNS12.location              = New-Object System.Drawing.Point(128,80)
$TxtBxNS12.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxNS22                       = New-Object system.Windows.Forms.TextBox
$TxtBxNS22.multiline             = $false
$TxtBxNS22.text                  = "8.8.8.8"
$TxtBxNS22.width                 = 118
$TxtBxNS22.height                = 20
$TxtBxNS22.location              = New-Object System.Drawing.Point(127,134)
$TxtBxNS22.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxNS33                       = New-Object system.Windows.Forms.TextBox
$TxtBxNS33.multiline             = $false
$TxtBxNS33.text                  = "8.8.8.8"
$TxtBxNS33.width                 = 117
$TxtBxNS33.height                = 20
$TxtBxNS33.location              = New-Object System.Drawing.Point(128,198)
$TxtBxNS33.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
#endregion
    
#region API Information
    
$PnlAPIInfo                          = New-Object system.Windows.Forms.Panel
$PnlAPIInfo.height                   = 57
$PnlAPIInfo.width                    = 304
$PnlAPIInfo.location                 = New-Object System.Drawing.Point(0,528)
$PnlAPIInfo.BackColor                = [System.Drawing.ColorTranslator]::FromHtml("#cecece")
    
$lblAPIKey                       = New-Object system.Windows.Forms.Label
$lblAPIKey.text                  = "API Key:"
$lblAPIKey.AutoSize              = $true
$lblAPIKey.width                 = 25
$lblAPIKey.height                = 10
$lblAPIKey.location              = New-Object System.Drawing.Point(10,6)
$lblAPIKey.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxAPIKey                     = New-Object system.Windows.Forms.TextBox
$TxtBxAPIKey.multiline           = $false
$TxtBxAPIKey.text                = ""
$TxtBxAPIKey.width               = 291
$TxtBxAPIKey.height              = 20
$TxtBxAPIKey.location            = New-Object System.Drawing.Point(7,30)
$TxtBxAPIKey.Font                = New-Object System.Drawing.Font('Segoe UI',10)
$TxtBxAPIKey.PasswordChar        = ""
    
$BtnGenerateKey                  = New-Object system.Windows.Forms.Button
$BtnGenerateKey.text             = "Gen. Secure Key"
$BtnGenerateKey.width            = 127
$BtnGenerateKey.height           = 22
$BtnGenerateKey.location         = New-Object System.Drawing.Point(173,3)
$BtnGenerateKey.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$BtnDeleteKey                    = New-Object system.Windows.Forms.Button
$BtnDeleteKey.text               = "Delete Key"
$BtnDeleteKey.width              = 84
$BtnDeleteKey.height             = 22
$BtnDeleteKey.location           = New-Object System.Drawing.Point(88,3)
$BtnDeleteKey.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
    
#endregion
    
#region Network Setting Info
    
$PnlNetworkSettings              = New-Object system.Windows.Forms.Panel
$PnlNetworkSettings.height       = 258
$PnlNetworkSettings.width        = 322
$PnlNetworkSettings.location     = New-Object System.Drawing.Point(759,4)
$PnlNetworkSettings.BackColor    = [System.Drawing.ColorTranslator]::FromHtml("#cecece")
    
$TxtBxFWRules                    = New-Object system.Windows.Forms.TextBox
$TxtBxFwRules.Scrollbars         = "Vertical"
$TxtBxFWRules.multiline          = $true
$TxtBxFWRules.width              = 319
$TxtBxFWRules.height             = 224
$TxtBxFWRules.enabled            = $true
$TxtBxFWRules.location           = New-Object System.Drawing.Point(1,30)
$TxtBxFWRules.Font               = New-Object System.Drawing.Font('Segoe UI',10)
$TxtBxFWRules.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("#cedcdc")
    
$LblFWRules                      = New-Object system.Windows.Forms.Label
$LblFWRules.text                 = "Firewall Rule Names:"
$LblFWRules.AutoSize             = $true
$LblFWRules.width                = 25
$LblFWRules.height               = 10
$LblFWRules.location             = New-Object System.Drawing.Point(7,7)
$LblFWRules.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$BtnClearFWRules           = New-Object system.Windows.Forms.Button
$BtnClearFWRules.text      = "Clear FW Rules"
$BtnClearFWRules.width     = 179
$BtnClearFWRules.height    = 26
$BtnClearFWRules.location  = New-Object System.Drawing.Point(156,2)
$BtnClearFWRules.Font      = New-Object System.Drawing.Font('Segoe UI',10)
$BtnClearFWRules.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
#endregion
    
#region NetworkTags
    
$PnlNetTag                          = New-Object system.Windows.Forms.Panel
$PnlNetTag.height                   = 49
$PnlNetTag.width                    = 304
$PnlNetTag.location                 = New-Object System.Drawing.Point(0,586)
$PnlNetTag.BackColor                = [System.Drawing.ColorTranslator]::FromHtml("#cecece")
    
$TxtBxNetTag                     = New-Object system.Windows.Forms.TextBox
$TxtBxNetTag.multiline           = $false
$TxtBxNetTag.text                = "Tag"
$TxtBxNetTag.width               = 257
$TxtBxNetTag.height              = 20
$TxtBxNetTag.location            = New-Object System.Drawing.Point(43,15)
$TxtBxNetTag.Font                = New-Object System.Drawing.Font('Segoe UI',10)
    
$LblNetworkTag                   = New-Object system.Windows.Forms.Label
$LblNetworkTag.text              = "Tags:"
$LblNetworkTag.AutoSize          = $true
$LblNetworkTag.width             = 25
$LblNetworkTag.height            = 10
$LblNetworkTag.location          = New-Object System.Drawing.Point(7,19)
$LblNetworkTag.Font              = New-Object System.Drawing.Font('Segoe UI',10)
    
#endregion
    
#region GUI Buttons
$BtnUpdateRouteTable             = New-Object system.Windows.Forms.Button
$BtnUpdateRouteTable.text        = "Update Route Table"
$BtnUpdateRouteTable.width       = 190
$BtnUpdateRouteTable.height      = 20
$BtnUpdateRouteTable.location    = New-Object System.Drawing.Point(311,616)
$BtnUpdateRouteTable.Font        = New-Object System.Drawing.Font('Segoe UI',10)
$BtnUpdateRouteTable.BackColor   = [System.Drawing.ColorTranslator]::FromHtml("#dadada")

$BtnGetOrganizations             = New-Object system.Windows.Forms.Button
$BtnGetOrganizations.text             = "Import Organizations"
$BtnGetOrganizations.width            = 188
$BtnGetOrganizations.height           = 20
$BtnGetOrganizations.location         = New-Object System.Drawing.Point(311,556)
$BtnGetOrganizations.Font             = New-Object System.Drawing.Font('Segoe UI',10)
$BtnGetOrganizations.BackColor        = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")

$BtnRmNetDevice                  = New-Object system.Windows.Forms.Button
$BtnRmNetDevice.text             = "Remove Network Devices"
$BtnRmNetDevice.width                   = 188
$BtnRmNetDevice.height                  = 20
$BtnRmNetDevice.location                = New-Object System.Drawing.Point(311,576)
$BtnRmNetDevice.Font             = New-Object System.Drawing.Font('Segoe UI',10)
$BtnRmNetDevice.BackColor        = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnCreateNetwork                = New-Object system.Windows.Forms.Button
$BtnCreateNetwork.text           = "Create Network"
$BtnCreateNetwork.width          = 189
$BtnCreateNetwork.height         = 55
$BtnCreateNetwork.location       = New-Object System.Drawing.Point(312,637)
$BtnCreateNetwork.Font           = New-Object System.Drawing.Font('Segoe UI',10)
$BtnCreateNetwork.BackColor      = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnSubnetAvailibility           = New-Object system.Windows.Forms.Button
$BtnSubnetAvailibility.text      = "Check Subnet Availibility"
$BtnSubnetAvailibility.width     = 188
$BtnSubnetAvailibility.height    = 20
$BtnSubnetAvailibility.location  = New-Object System.Drawing.Point(312,596)
$BtnSubnetAvailibility.Font      = New-Object System.Drawing.Font('Segoe UI',10)
$BtnSubnetAvailibility.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnAPIBuilder                         = New-Object system.Windows.Forms.Button
$BtnAPIBuilder.text                    = "API Builder"
$BtnAPIBuilder.width                   = 140
$BtnAPIBuilder.height                  = 44
$BtnAPIBuilder.location                = New-Object System.Drawing.Point(3,529)
$BtnAPIBuilder.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
$BtnAPIBuilder.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnSBCU                               = New-Object system.Windows.Forms.Button
$BtnSBCU.text                          = "SBCU"
$BtnSBCU.width                         = 142
$BtnSBCU.height                        = 44
$BtnSBCU.location                      = New-Object System.Drawing.Point(146,529)
$BtnSBCU.Font                          = New-Object System.Drawing.Font('Segoe UI',10)
$BtnSBCU.BackColor                     = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnUpdateNetworkConfig          = New-Object system.Windows.Forms.Button
$BtnUpdateNetworkConfig.text     = "Update Network Configuration"
$BtnUpdateNetworkConfig.width    = 289
$BtnUpdateNetworkConfig.height   = 45
$BtnUpdateNetworkConfig.location  = New-Object System.Drawing.Point(0,648)
$BtnUpdateNetworkConfig.Font     = New-Object System.Drawing.Font('Segoe UI',10)
    
$BtnUpdateAppPorts                    = New-Object system.Windows.Forms.Button
$BtnUpdateAppPorts.text               = "Update App. Ports"
$BtnUpdateAppPorts.width                   = 109
$BtnUpdateAppPorts.height                  = 46
$BtnUpdateAppPorts.location                = New-Object System.Drawing.Point(0,250)
$BtnUpdateAppPorts.Font               = New-Object System.Drawing.Font('Segoe UI',10)
$BtnUpdateAppPorts.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
#endregion
    
#region File Import GUI
$PnlDevTypes                          = New-Object system.Windows.Forms.Panel
$PnlDevTypes.height                   = 75
$PnlDevTypes.width                    = 283
$PnlDevTypes.location                 = New-Object System.Drawing.Point(3,576)
$PnlDevTypes.AutoScroll               = $true
$PnlDevTypes.BackColor                = [System.Drawing.ColorTranslator]::FromHtml("#cecece")
#endregion
    
#region Import GUI
$BtnNetworkConfImport            = New-Object system.Windows.Forms.Button
$BtnNetworkConfImport.text       = "Import from File"
$BtnNetworkConfImport.width      = 118
$BtnNetworkConfImport.height     = 19
$BtnNetworkConfImport.location   = New-Object System.Drawing.Point(169,1)
$BtnNetworkConfImport.Font       = New-Object System.Drawing.Font('Segoe UI',10)
    
$PnlImport                       = New-Object system.Windows.Forms.Panel
$PnlImport.height                = 690
$PnlImport.width                 = 289
$PnlImport.location              = New-Object System.Drawing.Point(1082,4)
$PnlImport.BackColor             = [System.Drawing.ColorTranslator]::FromHtml("#dcdada")
    
$LblImportOverview               = New-Object system.Windows.Forms.Label
$LblImportOverview.text          = "Network Import Selections"
$LblImportOverview.AutoSize      = $true
$LblImportOverview.width         = 25
$LblImportOverview.height        = 10
$LblImportOverview.location      = New-Object System.Drawing.Point(0,5)
$LblImportOverview.Font          = New-Object System.Drawing.Font('Segoe UI',10)
    
$BtnTagImport                    = New-Object system.Windows.Forms.Button
$BtnTagImport.text               = "Import Tags"
$BtnTagImport.width              = 133
$BtnTagImport.height             = 23
$BtnTagImport.location           = New-Object System.Drawing.Point(146,53)
$BtnTagImport.Font               = New-Object System.Drawing.Font('Segoe UI',10)
$BtnTagImport.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnTimezoneImport                    = New-Object system.Windows.Forms.Button
$BtnTimezoneImport.text               = "Import T/Z"
$BtnTimezoneImport.width              = 133
$BtnTimezoneImport.height             = 23
$BtnTimezoneImport.location           = New-Object System.Drawing.Point(146,76)
$BtnTimezoneImport.Font               = New-Object System.Drawing.Font('Segoe UI',10)
$BtnTimezoneImport.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$TxBxNetNameImport               = New-Object system.Windows.Forms.ComboBox
$TxBxNetNameImport.width         = 208
$TxBxNetNameImport.height        = 20
$TxBxNetNameImport.location      = New-Object System.Drawing.Point(0,28)
$TxBxNetNameImport.Font          = New-Object System.Drawing.Font('Segoe UI',10)
    
$ComboOrgImport                  = New-Object system.Windows.Forms.ComboBox
$ComboOrgImport.width            = 71
$ComboOrgImport.height           = 20
$ComboOrgImport.location         = New-Object System.Drawing.Point(210,28)
$ComboOrgImport.Font             = New-Object System.Drawing.Font('Segoe UI',10)
    
$BtnFWImport                     = New-Object system.Windows.Forms.Button
$BtnFWImport.text                = "Import L3FW Rules"
$BtnFWImport.width               = 137
$BtnFWImport.height              = 23
$BtnFWImport.location            = New-Object System.Drawing.Point(5,53)
$BtnFWImport.Font                = New-Object System.Drawing.Font('Segoe UI',10)
$BtnFWImport.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnFW7Import                     = New-Object system.Windows.Forms.Button
$BtnFW7Import.text                = "Import L7FW Rules"
$BtnFW7Import.width               = 137
$BtnFW7Import.height              = 23
$BtnFW7Import.location            = New-Object System.Drawing.Point(5,77)
$BtnFW7Import.Font                = New-Object System.Drawing.Font('Segoe UI',10)
$BtnFW7Import.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnImportLoc                    = New-Object system.Windows.Forms.Button
$BtnImportLoc.text               = "Import Location"
$BtnImportLoc.width              = 136
$BtnImportLoc.height             = 23
$BtnImportLoc.location           = New-Object System.Drawing.Point(5,151)
$BtnImportLoc.Font               = New-Object System.Drawing.Font('Segoe UI',10)
$BtnImportLoc.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnImportIDS                    = New-Object system.Windows.Forms.Button
$BtnImportIDS.text               = "Import IDS"
$BtnImportIDS.width              = 136
$BtnImportIDS.height             = 23
$BtnImportIDS.location           = New-Object System.Drawing.Point(5,175)
$BtnImportIDS.Font               = New-Object System.Drawing.Font('Segoe UI',10)
$BtnImportIDS.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnImportAll                    = New-Object system.Windows.Forms.Button
$BtnImportAll.text               = "Import All"
$BtnImportAll.width              = 136
$BtnImportAll.height             = 23
$BtnImportAll.location           = New-Object System.Drawing.Point(5,199)
$BtnImportAll.Font               = New-Object System.Drawing.Font('Segoe UI',10)
$BtnImportAll.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnExportAll                    = New-Object system.Windows.Forms.Button
$BtnExportAll.text               = "Export All"
$BtnExportAll.width              = 136
$BtnExportAll.height             = 23
$BtnExportAll.location           = New-Object System.Drawing.Point(145,199)
$BtnExportAll.Font               = New-Object System.Drawing.Font('Segoe UI',10)
$BtnExportAll.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnImportVLAN                   = New-Object system.Windows.Forms.Button
$BtnImportVLAN.text               = "Import VLAN/DHCP"
$BtnImportVLAN.width              = 133
$BtnImportVLAN.height             = 23
$BtnImportVLAN.location           = New-Object System.Drawing.Point(146,175)
$BtnImportVLAN.Font               = New-Object System.Drawing.Font('Segoe UI',10)
$BtnImportVLAN.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnImportTRS                         = New-Object system.Windows.Forms.Button
$BtnImportTRS.text                    = "Import TRS"
$BtnImportTRS.width                   = 133
$BtnImportTRS.height                  = 23
$BtnImportTRS.location                = New-Object System.Drawing.Point(146,103)
$BtnImportTRS.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
$BtnImportTRS.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnImportTP                         = New-Object system.Windows.Forms.Button
$BtnImportTP.text                    = "Import Threat Protect"
$BtnImportTP.width                   = 133
$BtnImportTP.height                  = 35
$BtnImportTP.location                = New-Object System.Drawing.Point(146,127)
$BtnImportTP.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
$BtnImportTP.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnImportCFilter                         = New-Object system.Windows.Forms.Button
$BtnImportCFilter.text                    = "Import C. Filtering"
$BtnImportCFilter.width                   = 136
$BtnImportCFilter.height                  = 23
$BtnImportCFilter.location                = New-Object System.Drawing.Point(5,103)
$BtnImportCFilter.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
$BtnImportCFilter.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
    
$BtnImportDT                         = New-Object system.Windows.Forms.Button
$BtnImportDT.text                    = "Import Devices/Types"
$BtnImportDT.width                   = 136
$BtnImportDT.height                  = 23
$BtnImportDT.location                = New-Object System.Drawing.Point(5,127)
$BtnImportDT.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
$BtnImportDT.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#d2d1d1")
#endregion
    
#region Update Option GUI
$RadNameFront                    = New-Object system.Windows.Forms.RadioButton
$RadNameFront.text               = "F"
$RadNameFront.AutoSize           = $true
$RadNameFront.width              = 104
$RadNameFront.height             = 20
$RadNameFront.location           = New-Object System.Drawing.Point(10,5)
$RadNameFront.Font               = New-Object System.Drawing.Font('Segoe UI',10)
    
$RadNameEnd                      = New-Object system.Windows.Forms.RadioButton
$RadNameEnd.text                 = "E"
$RadNameEnd.AutoSize             = $true
$RadNameEnd.width                = 104
$RadNameEnd.height               = 20
$RadNameEnd.location             = New-Object System.Drawing.Point(57,5)
$RadNameEnd.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxNameChange                    = New-Object system.Windows.Forms.TextBox
$TxtBxNameChange.multiline          = $false
$TxtBxNameChange.width                  = 100
$TxtBxNameChange.height                 = 20
$TxtBxNameChange.location               = New-Object System.Drawing.Point(73,9)
$TxtBxNameChange.Font               = New-Object System.Drawing.Font('Segoe UI',10)
    
$RadNameOverwrite                    = New-Object system.Windows.Forms.RadioButton
$RadNameOverwrite.text               = "O"
$RadNameOverwrite.AutoSize           = $true
$RadNameOverwrite.width              = 104
$RadNameOverwrite.height             = 20
$RadNameOverwrite.location           = New-Object System.Drawing.Point(7,48)
$RadNameOverwrite.Font               = New-Object System.Drawing.Font('Segoe UI',8)
    
$RadNameAppend                       = New-Object system.Windows.Forms.RadioButton
$RadNameAppend.text                  = "A"
$RadNameAppend.AutoSize              = $true
$RadNameAppend.width              = 104
$RadNameAppend.height             = 20
$RadNameAppend.location           = New-Object System.Drawing.Point(45,48)
$RadNameAppend.Font                  = New-Object System.Drawing.Font('Segoe UI',8)
    
$optAppliance                       = New-Object system.Windows.Forms.CheckBox
$optAppliance.text                  = "appliance"
$optAppliance.AutoSize              = $false
$optAppliance.width                 = 95
$optAppliance.height                = 20
$optAppliance.location              = New-Object System.Drawing.Point(8,8)
$optAppliance.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optSwitch                       = New-Object system.Windows.Forms.CheckBox
$optSwitch.text                  = "switch"
$optSwitch.AutoSize              = $false
$optSwitch.width                 = 68
$optSwitch.height                = 20
$optSwitch.location              = New-Object System.Drawing.Point(103,8)
$optSwitch.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optWireless                       = New-Object system.Windows.Forms.CheckBox
$optWireless.text                  = "wireless"
$optWireless.AutoSize              = $false
$optWireless.width                 = 95
$optWireless.height                = 20
$optWireless.location              = New-Object System.Drawing.Point(8,33)
$optWireless.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optCG                       = New-Object system.Windows.Forms.CheckBox
$optCG.text                  = "cellularGateway"
$optCG.AutoSize              = $false
$optCG.width                 = 162
$optCG.height                = 20
$optCG.location              = New-Object System.Drawing.Point(103,33)
$optCG.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optCam                       = New-Object system.Windows.Forms.CheckBox
$optCam.text                  = "camera"
$optCam.AutoSize              = $false
$optCam.width                 = 79
$optCam.height                = 20
$optCam.location              = New-Object System.Drawing.Point(189,8)
$optCam.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optVLANs                      = New-Object system.Windows.Forms.CheckBox
$optVLANs.text                  = "VLANs"
$optVLANs.AutoSize              = $false
$optVLANs.width                 = 90
$optVLANs.height                = 14
$optVLANs.location              = New-Object System.Drawing.Point(6,7)
$optVLANs.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optVNameOnly                      = New-Object system.Windows.Forms.CheckBox
$optVNameOnly.text                  = "VNameOnly?"
$optVNameOnly.AutoSize              = $false
$optVNameOnly.width                 = 100
$optVNameOnly.height                = 14
$optVNameOnly.location              = New-Object System.Drawing.Point(6,32)
$optVNameOnly.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optIDS                      = New-Object system.Windows.Forms.CheckBox
$optIDS.text                  = "IDS"
$optIDS.AutoSize              = $false
$optIDS.width                 = 46
$optIDS.height                = 14
$optIDS.location              = New-Object System.Drawing.Point(102,29)
$optIDS.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optSSID                       = New-Object system.Windows.Forms.CheckBox
$optSSID.text                  = "SSID"
$optSSID.AutoSize              = $false
$optSSID.width                 = 60
$optSSID.height                = 14
$optSSID.location              = New-Object System.Drawing.Point(102,10)
$optSSID.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optNTag                       = New-Object system.Windows.Forms.CheckBox
$optNTag.text                  = "Yes"
$optNTag.AutoSize              = $false
$optNTag.width                 = 90
$optNTag.height                = 15
$optNTag.location              = New-Object System.Drawing.Point(48,8)
$optNTag.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optFWR                       = New-Object system.Windows.Forms.CheckBox
$optFWR.text                  = "L3FW Rules"
$optFWR.AutoSize              = $false
$optFWR.width                 = 100
$optFWR.height                = 13
$optFWR.location              = New-Object System.Drawing.Point(0,32)
$optFWR.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optFWRTop                       = New-Object system.Windows.Forms.RadioButton
$optFWRTop.text                  = "Top"
$optFWRTop.AutoSize              = $false
$optFWRTop.width                 = 29
$optFWRTop.height                = 20
$optFWRTop.location              = New-Object System.Drawing.Point(0,56)
$optFWRTop.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optFWRBottom                       = New-Object system.Windows.Forms.RadioButton
$optFWRBottom.text                  = "Btm"
$optFWRBottom.AutoSize              = $false
$optFWRBottom.width                 = 34
$optFWRBottom.height                = 20
$optFWRBottom.location              = New-Object System.Drawing.Point(31,56)
$optFWRBottom.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optFWRRemove                       = New-Object system.Windows.Forms.RadioButton
$optFWRRemove.text                  = "R"
$optFWRRemove.AutoSize              = $false
$optFWRRemove.width                 = 34
$optFWRRemove.height                = 20
$optFWRRemove.location              = New-Object System.Drawing.Point(66,56)
$optFWRRemove.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optCustomAPI                       = New-Object system.Windows.Forms.CheckBox
$optCustomAPI.text                  = "API?"
$optCustomAPI.AutoSize              = $false
$optCustomAPI.width                 = 55
$optCustomAPI.height                = 15
$optCustomAPI.location              = New-Object System.Drawing.Point(0,85)
$optCustomAPI.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optDevTags                      = New-Object system.Windows.Forms.CheckBox
$optDevTags.text                 = "Device Tags"
$optDevTags.AutoSize             = $false
$optDevTags.width                = 101
$optDevTags.height               = 13
$optDevTags.location             = New-Object System.Drawing.Point(0,71)
$optDevTags.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$optDevAddress                      = New-Object system.Windows.Forms.CheckBox
$optDevAddress.text                 = "Device Adr"
$optDevAddress.AutoSize             = $false
$optDevAddress.width                = 101
$optDevAddress.height               = 13
$optDevAddress.location             = New-Object System.Drawing.Point(0,58)
$optDevAddress.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$optDevices                      = New-Object system.Windows.Forms.CheckBox
$optDevices.text                 = "Devices"
$optDevices.AutoSize             = $false
$optDevices.width                = 119
$optDevices.height               = 14
$optDevices.location             = New-Object System.Drawing.Point(0,13)
$optDevices.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$optDeviceName                      = New-Object system.Windows.Forms.CheckBox
$optDeviceName.text                 = "Device Name"
$optDeviceName.AutoSize             = $false
$optDeviceName.width                = 119
$optDeviceName.height               = 14
$optDeviceName.location             = New-Object System.Drawing.Point(0,28)
$optDeviceName.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$optDevNote                      = New-Object system.Windows.Forms.CheckBox
$optDevNote.text                 = "Device Notes"
$optDevNote.AutoSize             = $false
$optDevNote.width                = 101
$optDevNote.height               = 13
$optDevNote.location             = New-Object System.Drawing.Point(0,42)
$optDevNote.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$optAlerts                      = New-Object system.Windows.Forms.CheckBox
$optAlerts.text                 = "Alerts"
$optAlerts.AutoSize             = $false
$optAlerts.width                = 60
$optAlerts.height               = 15
$optAlerts.location             = New-Object System.Drawing.Point(102,36)
$optAlerts.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$optSyslog                      = New-Object system.Windows.Forms.CheckBox
$optSyslog.text                 = "Syslog"
$optSyslog.AutoSize             = $false
$optSyslog.width                = 100
$optSyslog.height               = 15
$optSyslog.location             = New-Object System.Drawing.Point(102,104)
$optSyslog.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$optLoc                      = New-Object system.Windows.Forms.CheckBox
$optLoc.text                 = "Location"
$optLoc.AutoSize             = $false
$optLoc.width                = 130
$optLoc.height               = 13
$optLoc.location             = New-Object System.Drawing.Point(102,62)
$optLoc.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$optCFilter                      = New-Object system.Windows.Forms.CheckBox
$optCFilter.text                 = "C. Filter"
$optCFilter.AutoSize             = $false
$optCFilter.width                 = 100
$optCFilter.height                = 15
$optCFilter.location              = New-Object System.Drawing.Point(102,53)
$optCFilter.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$optL7FWR                       = New-Object system.Windows.Forms.CheckBox
$optL7FWR.text                  = "L7FW Rules"
$optL7FWR.AutoSize              = $false
$optL7FWR.width                 = 100
$optL7FWR.height                = 16
$optL7FWR.location              = New-Object System.Drawing.Point(0,8)
$optL7FWR.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$optTRS                      = New-Object system.Windows.Forms.CheckBox
$optTRS.text                 = "TRS"
$optTRS.AutoSize             = $false
$optTRS.width                = 100
$optTRS.height               = 15
$optTRS.location             = New-Object System.Drawing.Point(102,80)
$optTRS.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$optTProt                      = New-Object system.Windows.Forms.CheckBox
$optTProt.text                 = "Threat Prot."
$optTProt.AutoSize             = $false
$optTProt.width                 = 100
$optTProt.height                = 14
$optTProt.location              = New-Object System.Drawing.Point(102,4)
$optTProt.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$optNName                       = New-Object system.Windows.Forms.CheckBox
$optNName.text                  = "Name:"
$optNName.AutoSize              = $false
$optNName.width                 = 70
$optNName.height                = 20
$optNName.location              = New-Object System.Drawing.Point(2,10)
$optNName.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$RadTagOverwrite                 = New-Object system.Windows.Forms.RadioButton
$RadTagOverwrite.text            = "O"
$RadTagOverwrite.AutoSize        = $true
$RadTagOverwrite.width           = 104
$RadTagOverwrite.height          = 20
$RadTagOverwrite.location        = New-Object System.Drawing.Point(10,34)
$RadTagOverwrite.Font            = New-Object System.Drawing.Font('Segoe UI',8)
    
$RadTagAppend                    = New-Object system.Windows.Forms.RadioButton
$RadTagAppend.text               = "A"
$RadTagAppend.AutoSize           = $true
$RadTagAppend.width              = 104
$RadTagAppend.height             = 20
$RadTagAppend.location           = New-Object System.Drawing.Point(51,34)
$RadTagAppend.Font               = New-Object System.Drawing.Font('Segoe UI',8)
    
$NTagOptSubnet                   = New-Object system.Windows.Forms.CheckBox
$NTagOptSubnet.text              = "Subnet?"
$NTagOptSubnet.AutoSize          = $false
$NTagOptSubnet.width             = 130
$NTagOptSubnet.height            = 14
$NTagOptSubnet.location          = New-Object System.Drawing.Point(0,60)
$NTagOptSubnet.Font              = New-Object System.Drawing.Font('Segoe UI',10)
    
$PnlNameChange                   = New-Object system.Windows.Forms.Panel
$PnlNameChange.height            = 80
$PnlNameChange.width             = 176
$PnlNameChange.location          = New-Object System.Drawing.Point(110,237)
$PnlNameChange.BackColor         = [System.Drawing.ColorTranslator]::FromHtml("#e3e1e1")
    
$PnlNameOpt                      = New-Object system.Windows.Forms.Panel
$PnlNameOpt.height               = 29
$PnlNameOpt.width                = 100
$PnlNameOpt.location             = New-Object System.Drawing.Point(73,47)
$PnlNameOpt.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("#9f9d9d")
    
$PnlUpdateSec                    = New-Object system.Windows.Forms.Panel
$PnlUpdateSec.height             = 119
$PnlUpdateSec.width              = 193
$PnlUpdateSec.location           = New-Object System.Drawing.Point(-1,317)
$PnlUpdateSec.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("#c6c6c6")
    
$LblSecurity                     = New-Object system.Windows.Forms.Label
$LblSecurity.text                = "Security"
$LblSecurity.AutoSize            = $true
$LblSecurity.width               = 25
$LblSecurity.height              = 10
$LblSecurity.location            = New-Object System.Drawing.Point(6,8)
$LblSecurity.Font                = New-Object System.Drawing.Font('Segoe UI',12)
    
$PnlFWUpdate                     = New-Object system.Windows.Forms.Panel
$PnlFWUpdate.height              = 78
$PnlFWUpdate.width               = 101
$PnlFWUpdate.location            = New-Object System.Drawing.Point(1,30)
$PnlFWUpdate.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#bcbaba")
    
$PnlTags                         = New-Object system.Windows.Forms.Panel
$PnlTags.height                  = 76
$PnlTags.width                   = 94
$PnlTags.location                = New-Object System.Drawing.Point(193,319)
    
$LblTaggingInfo                  = New-Object system.Windows.Forms.Label
$LblTaggingInfo.text             = "Tags"
$LblTaggingInfo.AutoSize         = $true
$LblTaggingInfo.width            = 25
$LblTaggingInfo.height           = 10
$LblTaggingInfo.location         = New-Object System.Drawing.Point(6,7)
$LblTaggingInfo.Font             = New-Object System.Drawing.Font('Segoe UI',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    
#endregion
    
#region Bulk Network Update GUI
$PnlNetImport                    = New-Object system.Windows.Forms.Panel
$PnlNetImport.height             = 481
$PnlNetImport.width              = 232
$PnlNetImport.location           = New-Object System.Drawing.Point(1373,211)
$PnlNetImport.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("#e1dede")
    
$TxtBxNetList                    = New-Object system.Windows.Forms.TextBox
$TxtBxNetList.multiline          = $true
$TxtBxNetList.width              = 229
$TxtBxNetList.height             = 183
$TxtBxNetList.location           = New-Object System.Drawing.Point(1,81)
$TxtBxNetList.Font               = New-Object System.Drawing.Font('Segoe UI',10)
$TxtBxNetList.Scrollbars         = "Vertical"
    
$TxtBxNetListApply               = New-Object system.Windows.Forms.TextBox
$TxtBxNetListApply.multiline     = $true
$TxtBxNetListApply.width         = 229
$TxtBxNetListApply.height        = 183
$TxtBxNetListApply.location      = New-Object System.Drawing.Point(1,293)
$TxtBxNetListApply.Font          = New-Object System.Drawing.Font('Segoe UI',10)
$TxtBxNetListApply.Scrollbars    = "Vertical"
    
$lblNetList                      = New-Object system.Windows.Forms.Label
$lblNetList.text                 = "Network Update Selection List"
$lblNetList.AutoSize             = $true
$lblNetList.width                = 25
$lblNetList.height               = 10
$lblNetList.location             = New-Object System.Drawing.Point(26,60)
$lblNetList.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$lblUpdateNetList                = New-Object system.Windows.Forms.Label
$lblUpdateNetList.text           = "Update Networks:"
$lblUpdateNetList.AutoSize       = $true
$lblUpdateNetList.width          = 25
$lblUpdateNetList.height         = 10
$lblUpdateNetList.location       = New-Object System.Drawing.Point(102,272)
$lblUpdateNetList.Font           = New-Object System.Drawing.Font('Segoe UI',10)
    
$ChkUpdateList                   = New-Object system.Windows.Forms.CheckBox
$ChkUpdateList.text              = "Update"
$ChkUpdateList.AutoSize          = $false
$ChkUpdateList.width             = 74
$ChkUpdateList.height            = 14
$ChkUpdateList.location          = New-Object System.Drawing.Point(7,272)
$ChkUpdateList.Font              = New-Object System.Drawing.Font('Segoe UI',10)
    
$lblBulkNetUpdate                = New-Object system.Windows.Forms.Label
$lblBulkNetUpdate.text           = "Bulk Network Update"
$lblBulkNetUpdate.AutoSize       = $true
$lblBulkNetUpdate.width          = 25
$lblBulkNetUpdate.height         = 10
$lblBulkNetUpdate.location       = New-Object System.Drawing.Point(17,16)
$lblBulkNetUpdate.Font           = New-Object System.Drawing.Font('Segoe UI',16)
#endregion
    
#region FIP Import GUI
    
$PnlFIPImport                    = New-Object system.Windows.Forms.Panel
$PnlFIPImport.height             = 59
$PnlFIPImport.width              = 303
$PnlFIPImport.location           = New-Object System.Drawing.Point(6,634)
$PnlFIPImport.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("#c3bdbd")
    
$BtnImportFIPs                   = New-Object system.Windows.Forms.Button
$BtnImportFIPs.text              = "Import"
$BtnImportFIPs.width             = 71
$BtnImportFIPs.height            = 48
$BtnImportFIPs.location          = New-Object System.Drawing.Point(77,6)
$BtnImportFIPs.Font              = New-Object System.Drawing.Font('Segoe UI',10)
    
$BtnUpdateFIPs                   = New-Object system.Windows.Forms.Button
$BtnUpdateFIPs.text              = "Update FIPs"
$BtnUpdateFIPs.width             = 142
$BtnUpdateFIPs.height            = 47
$BtnUpdateFIPs.location          = New-Object System.Drawing.Point(152,6)
$BtnUpdateFIPs.Font              = New-Object System.Drawing.Font('Segoe UI',10)
    
$lblVLANID                       = New-Object system.Windows.Forms.Label
$lblVLANID.text                  = "VlanId:"
$lblVLANID.AutoSize              = $true
$lblVLANID.width                 = 25
$lblVLANID.height                = 10
$lblVLANID.location              = New-Object System.Drawing.Point(18,10)
$lblVLANID.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxVlanID                     = New-Object system.Windows.Forms.TextBox
$TxtBxVlanID.multiline           = $false
$TxtBxVlanID.width               = 69
$TxtBxVlanID.height              = 20
$TxtBxVlanID.location            = New-Object System.Drawing.Point(5,33)
$TxtBxVlanID.Font                = New-Object System.Drawing.Font('Segoe UI',10)
    
#endregion
    
#region Task Scheduler
$PnlTaskSched                    = New-Object system.Windows.Forms.Panel
$PnlTaskSched.height             = 210
$PnlTaskSched.width              = 234
$PnlTaskSched.location           = New-Object System.Drawing.Point(1371,0)
$PnlTaskSched.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("#dcdcdc")
    
$LblTaskSched                    = New-Object system.Windows.Forms.Label
$LblTaskSched.text               = "Task Scheduler"
$LblTaskSched.AutoSize           = $true
$LblTaskSched.width              = 25
$LblTaskSched.height             = 10
$LblTaskSched.location           = New-Object System.Drawing.Point(6,7)
$LblTaskSched.Font               = New-Object System.Drawing.Font('Segoe UI',12)
    
$optTSEnabled                    = New-Object system.Windows.Forms.CheckBox
$optTSEnabled.text               = "Enable"
$optTSEnabled.AutoSize           = $false
$optTSEnabled.width              = 70
$optTSEnabled.height             = 17
$optTSEnabled.location           = New-Object System.Drawing.Point(140,11)
$optTSEnabled.Font               = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxHours                      = New-Object system.Windows.Forms.TextBox
$TxtBxHours.multiline            = $false
$TxtBxHours.width                = 47
$TxtBxHours.height               = 20
$TxtBxHours.location             = New-Object System.Drawing.Point(74,67)
$TxtBxHours.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$BtnCreateTask                   = New-Object system.Windows.Forms.Button
$BtnCreateTask.text              = "Schedule"
$BtnCreateTask.width             = 93
$BtnCreateTask.height            = 29
$BtnCreateTask.location          = New-Object System.Drawing.Point(0,180)
$BtnCreateTask.Font              = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxTaskname                   = New-Object system.Windows.Forms.Combobox
$TxtBxTaskname.width             = 183
$TxtBxTaskname.height            = 20
$TxtBxTaskname.location          = New-Object System.Drawing.Point(50,42)
$TxtBxTaskname.Font              = New-Object System.Drawing.Font('Segoe UI',10)
$TaskItems = Get-ChildItem -Path '.\TaskScheduler\'
$TxtBxTaskname.Items.AddRange(($TaskItems.Name | Sort-Object))
    
$lblTSInfo                       = New-Object system.Windows.Forms.Label
$lblTSInfo.text                  = "Every: (hr)"
$lblTSInfo.AutoSize              = $true
$lblTSInfo.width                 = 25
$lblTSInfo.height                = 10
$lblTSInfo.location              = New-Object System.Drawing.Point(6,71)
$lblTSInfo.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$LblMins                         = New-Object system.Windows.Forms.Label
$LblMins.text                    = "(min)"
$LblMins.AutoSize                = $true
$LblMins.width                   = 25
$LblMins.height                  = 10
$LblMins.location                = New-Object System.Drawing.Point(128,71)
$LblMins.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxMins                       = New-Object system.Windows.Forms.TextBox
$TxtBxMins.multiline             = $false
$TxtBxMins.width                 = 47
$TxtBxMins.height                = 20
$TxtBxMins.location              = New-Object System.Drawing.Point(166,67)
$TxtBxMins.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$BtnBuildTask                    = New-Object system.Windows.Forms.Button
$BtnBuildTask.text               = "Build Task"
$BtnBuildTask.width              = 93
$BtnBuildTask.height             = 30
$BtnBuildTask.location           = New-Object System.Drawing.Point(0,119)
$BtnBuildTask.Font               = New-Object System.Drawing.Font('Segoe UI',10)
    
$BtnActTasks                     = New-Object system.Windows.Forms.Button
$BtnActTasks.text                = "Tasks"
$BtnActTasks.width               = 93
$BtnActTasks.height              = 30
$BtnActTasks.location            = New-Object System.Drawing.Point(0,150)
$BtnActTasks.Font                = New-Object System.Drawing.Font('Segoe UI',10)
    
$ChkBxHTML                       = New-Object system.Windows.Forms.CheckBox
$ChkBxHTML.text                  = "HTML"
$ChkBxHTML.AutoSize              = $false
$ChkBxHTML.width                 = 65
$ChkBxHTML.height                = 20
$ChkBxHTML.location              = New-Object System.Drawing.Point(100,126)
$ChkBxHTML.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$ChkBxEmail                      = New-Object system.Windows.Forms.CheckBox
$ChkBxEmail.text                 = "Email"
$ChkBxEmail.AutoSize             = $false
$ChkBxEmail.width                = 65
$ChkBxEmail.height               = 20
$ChkBxEmail.location             = New-Object System.Drawing.Point(100,158)
$ChkBxEmail.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$TxtBxScriptName                 = New-Object system.Windows.Forms.TextBox
$TxtBxScriptName.multiline       = $false
$TxtBxScriptName.text            = "script.ps1"
$TxtBxScriptName.width           = 100
$TxtBxScriptName.height          = 20
$TxtBxScriptName.location        = New-Object System.Drawing.Point(43,94)
$TxtBxScriptName.Font            = New-Object System.Drawing.Font('Segoe UI',10)
    
$lblScript                       = New-Object system.Windows.Forms.Label
$lblScript.text                  = "script:"
$lblScript.AutoSize              = $true
$lblScript.width                 = 25
$lblScript.height                = 10
$lblScript.location              = New-Object System.Drawing.Point(5,96)
$lblScript.Font                  = New-Object System.Drawing.Font('Segoe UI',10)
    
$LblTaskName                     = New-Object system.Windows.Forms.Label
$LblTaskName.text                = "Task:"
$LblTaskName.AutoSize            = $true
$LblTaskName.width               = 25
$LblTaskName.height              = 10
$LblTaskName.location            = New-Object System.Drawing.Point(6,46)
$LblTaskName.Font                = New-Object System.Drawing.Font('Segoe UI',10)
    
$ComboTasks                      = New-Object system.Windows.Forms.ComboBox
$ComboTasks.width                = 131
$ComboTasks.height               = 20
$ComboTasks.location             = New-Object System.Drawing.Point(98,185)
$ComboTasks.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
    
$BtnKillTask                     = New-Object system.Windows.Forms.Button
$BtnKillTask.text                = "Kill"
$BtnKillTask.width               = 60
$BtnKillTask.height              = 18
$BtnKillTask.location            = New-Object System.Drawing.Point(169,164)
$BtnKillTask.Font                = New-Object System.Drawing.Font('Segoe UI',10)
#endregion
    
#region Information GUI
$TxtBxOutput                     = New-Object system.Windows.Forms.RichTextBox 
$TxtBxOutput.Scrollbars          = "Vertical"
$TxtBxOutput.multiline           = $true
$TxtBxOutput.width               = 579
$TxtBxOutput.height              = 411
$TxtBxOutput.location            = New-Object System.Drawing.Point(502,282)
$TxtBxOutput.Font                = New-Object System.Drawing.Font('Segoe UI',10)
$TxtBxOutput.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#dcdbdb")
    
$LblNetTagName                   = New-Object system.Windows.Forms.Label
$LblNetTagName.text              = "Network Name:"
$LblNetTagName.AutoSize          = $true
$LblNetTagName.width             = 25
$LblNetTagName.height            = 10
$LblNetTagName.location          = New-Object System.Drawing.Point(13,7)
$LblNetTagName.Font              = New-Object System.Drawing.Font('Segoe UI',10)
    
$Label17                         = New-Object system.Windows.Forms.Label
$Label17.text                    = "Organization:"
$Label17.AutoSize                = $true
$Label17.width                   = 25
$Label17.height                  = 10
$Label17.location                = New-Object System.Drawing.Point(183,7)
$Label17.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
#endregion
    
#region GUI Panels
$Panel5                          = New-Object system.Windows.Forms.Panel
$Panel5.height                   = 224
$Panel5.width                    = 281
$Panel5.location                 = New-Object System.Drawing.Point(5,23)
$Panel5.BackColor                = [System.Drawing.ColorTranslator]::FromHtml("#cecece")
    
$PnlNetwork                      = New-Object system.Windows.Forms.Panel
$PnlNetwork.height               = 84
$PnlNetwork.width                = 193
$PnlNetwork.location             = New-Object System.Drawing.Point(-1,445)
$PnlNetwork.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("#c6c6c6")
    
$LblNetwork                      = New-Object system.Windows.Forms.Label
$LblNetwork.text                 = "Network"
$LblNetwork.AutoSize             = $true
$LblNetwork.width                = 25
$LblNetwork.height               = 10
$LblNetwork.location             = New-Object System.Drawing.Point(6,7)
$LblNetwork.Font                 = New-Object System.Drawing.Font('Segoe UI',12)
    
$PnlNetworkVlan                  = New-Object system.Windows.Forms.Panel
$PnlNetworkVlan.height           = 54
$PnlNetworkVlan.width            = 101
$PnlNetworkVlan.location         = New-Object System.Drawing.Point(1,24)
$PnlNetworkVlan.BackColor        = [System.Drawing.ColorTranslator]::FromHtml("#cdcdcd")
    
$PanelMisc                       = New-Object system.Windows.Forms.Panel
$PanelMisc.height                = 132
$PanelMisc.width                 = 92
$PanelMisc.location              = New-Object System.Drawing.Point(194,397)
$PanelMisc.BackColor             = [System.Drawing.ColorTranslator]::FromHtml("#c6c6c6")
#endregion
    
#region Log Options
$PnlLogOptions                   = New-Object system.Windows.Forms.Panel
$PnlLogOptions.height            = 55
$PnlLogOptions.width             = 256
$PnlLogOptions.location          = New-Object System.Drawing.Point(500,226)
$PnlLogOptions.BackColor         = [System.Drawing.ColorTranslator]::FromHtml("#cbcaca")
    
$ChkVerbose                      = New-Object system.Windows.Forms.CheckBox
$ChkVerbose.text                 = "Verbose"
$ChkVerbose.AutoSize             = $false
$ChkVerbose.width                = 74
$ChkVerbose.height               = 13
$ChkVerbose.location             = New-Object System.Drawing.Point(8,9)
$ChkVerbose.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
#Default it to checked
$ChkVerbose.Checked              = $true
    
$lblProcStatus                   = New-Object system.Windows.Forms.Label
$lblProcStatus.text              = "Status: Not Running."
$lblProcStatus.AutoSize          = $false
$lblProcStatus.width             = 238
$lblProcStatus.height            = 15
$lblProcStatus.location          = New-Object System.Drawing.Point(9,33)
$lblProcStatus.Font              = New-Object System.Drawing.Font('Segoe UI',10)
    
$BtnLogs                         = New-Object system.Windows.Forms.Button
$BtnLogs.text                    = "Logs"
$BtnLogs.width                   = 78
$BtnLogs.height                  = 22
$BtnLogs.location                = New-Object System.Drawing.Point(86,3)
$BtnLogs.Font                    = New-Object System.Drawing.Font('Segoe UI',10)
    
$ChkBxDebug                      = New-Object system.Windows.Forms.CheckBox
$ChkBxDebug.text                 = "Debug"
$ChkBxDebug.AutoSize             = $false
$ChkBxDebug.width                = 71
$ChkBxDebug.height               = 20
$ChkBxDebug.location             = New-Object System.Drawing.Point(174,9)
$ChkBxDebug.Font                 = New-Object System.Drawing.Font('Segoe UI',10)
$ChkBxDebug.Checked              = $true
    
#endregion
    
#region Object Controls
$PnlImport.controls.AddRange(@($BtnUpdateNetworkConfig,$Panel5,$LblImportOverview,$BtnUpdateAppPorts,$PnlNameChange,$PnlUpdateSec,$PnlTags,$PanelMisc,$PnlNetwork,$BtnAPIBuilder,$BtnSBCU,$BtnNetworkConfImport,$PnlDevTypes))
$MerakiNetworkConfigurationTool.controls.AddRange(@($PnlNetInfo,$PnlWireless,$PnlDeviceAssignment,$BtnCreateNetwork,$PnlDNSDHCPConf,$TxtBxOutput,$PnlNetTag,$BtnSubnetAvailibility,$PnlAPIInfo,$PnlNetworkSettings,$PnlImport,$BtnRmNetDevice,$PnlNetImport,$BtnUpdateRouteTable,$PnlFIPImport,$PnlTaskSched,$PnlLogOptions,$BtnFWRules,$BtnFW7Rules,$BtnGetOrganizations))
$PnlNetInfo.controls.AddRange(@($lblNetworkNameInfo,$TxtBxNet2Range,$Label2,$TxtBxNet1Range,$TxtBx1VLANName,$LblVlanName1,$TxtBx2VLANName,$TxtBxNet3Range,$TxtBx3VLANName,$Chk1VLANVPN,$Chk2VLANVPN,$Chk3VLANVPN,$ComboOrgName,$Label20,$TxtNetworkName,$V1VLAN,$V2VLAN,$V3VLAN,$lblTimeZone,$ComboTimeZone,$TxtCIDR3,$TxtCIDR2,$TxtCIDR1,$TxtAppIP1,$LblApplianceIP1,$TxtAppIP2,$TxtAppIP3,$LblNetID,$LblNetCidr,$BtnNetClear))
$PnlWireless.controls.AddRange(@($SSIDType,$Label8,$Label11,$SSIDN,$SSIDPSK,$Label12,$BtnClearSSID,$LblSSIDInfo))
$PnlDeviceAssignment.controls.AddRange(@($Label14,$TxtBxSD,$LblDeviceNotes,$TxtBxDN,$TxtBxDevTag,$LblDeviceTags,$TxtBxDevAddress,$TxtBxDevModel,$TxtBxDevName,$LblDevAddress,$LblDevModel,$LblDevName))
$PnlDNSDHCPConf.controls.AddRange(@($Label19,$ChkPDNS1,$ChkIDNS1,$TxtBxNS1,$ChkPDNS2,$ChkIDNS2,$ChkIDNS3,$ChkPDNS3,$Label25,$TxtBxNS2,$TxtBxNS3,$TxtBxNS12,$TxtBxNS22,$TxtBxNS33,$BtnClearDNS))
$PnlNetTag.controls.AddRange(@($TxtBxNetTag,$LblNetworkTag))
$PnlAPIInfo.controls.AddRange(@($lblAPIKey,$TxtBxAPIKey,$BtnGenerateKey,$BtnDeleteKey))
$PnlNetworkSettings.controls.AddRange(@($TxtBxFWRules,$LblFWRules,$BtnClearFWRules))
$Panel5.controls.AddRange(@($BtnTagImport,$TxBxNetNameImport,$ComboOrgImport,$LblNetTagName,$BtnFWImport,$BtnImportLoc,$BtnImportIDS,$BtnImportAll,$BtnExportAll,$BtnImportCFilter,$BtnImportDT,$BtnImportTP,$BtnImportTRS,$Label17,$BtnImportVLAN,$BtnFW7Import,$BtnTimezoneImport))
$PnlDevTypes.controls.AddRange(@($optAppliance,$optSwitch,$optWireless,$optCG,$optCam))
$PnlNetImport.controls.AddRange(@($TxtBxNetList, $TxtBxNetListApply,$lblNetList, $lblUpdateNetList, $ChkUpdateList,$lblBulkNetUpdate))
$PnlFIPImport.controls.AddRange(@($TxtBxVlanID,$BtnImportFIPs,$BtnUpdateFIPs,$lblVLANID))
$PnlNameChange.controls.AddRange(@($PnlNameOpt,$optNName,$TxtBxNameChange,$RadNameOverwrite,$RadNameAppend))
$PnlNameOpt.controls.AddRange(@($RadNameFront,$RadNameEnd))
$PnlUpdateSec.controls.AddRange(@($LblSecurity,$optTProt,$optIDS,$optCFilter,$optTRS,$optSyslog,$PnlFWUpdate))
$PnlFWUpdate.controls.AddRange(@($optL7FWR,$optFWR,$optFWRTop,$optFWRBottom,$optFWRRemove))
$PnlTags.controls.AddRange(@($LblTaggingInfo,$optNTag,$RadTagOverwrite,$RadTagAppend,$NTagOptSubnet))
$PnlNetwork.controls.AddRange(@($LblNetwork,$PnlNetworkVlan,$optSSID,$optAlerts,$optLoc))
$PnlNetworkVlan.controls.AddRange(@($optVLANs,$optVNameOnly))
$PanelMisc.controls.AddRange(@($optDevices,$optDevNote,$optCustomAPI,$optDevTags,$optDevAddress,$optDeviceName))
$PnlTaskSched.controls.AddRange(@($LblTaskSched,$optTSEnabled,$TxtBxHours,$BtnCreateTask,$TxtBxTaskname,$lblTSInfo,$LblMins,$TxtBxMins,$BtnBuildTask,$BtnActTasks,$ChkBxHTML,$ChkBxEmail,$TxtBxScriptName,$lblScript,$LblTaskName,$ComboTasks,$BtnKillTask))
$PnlLogOptions.controls.AddRange(@($ChkVerbose,$lblProcStatus,$BtnLogs,$ChkBxDebug))
#endregion
#endregion
    
#region First Launch Configuration
#Set our Default Debugging
if ($ChkBxDebug.Checked -eq $false){
    $Global:break = $false
    Set-Debugging
}
if ($ChkBxDebug.Checked -eq $true){
    $Global:break = $true
    Set-Debugging
}
    
Set-ColoredLine $TxtBxOutput Green ('Welcome to ' + $MerakiNetworkConfigurationTool.text + "`r`n")
if (Test-Path .\API\API-Key.xml){
#Set up our APIKey:
$CredLoc = Import-CliXml -Path .\API\API-Key.xml
#Decrypt0r
$TxtBxAPIKey.text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($CredLoc))
}
    if ($TxtBxAPIKey.text -ne ''){
    Set-ColoredLine $TxtBxOutput Black 'API Key was successfully loaded!'
    }
    if ($TxtBxAPIKey.text -eq ''){
    Set-ColoredLine $TxtBxOutput Black 'API Key could not be found. Please check that the API-Key file exists and try again!'
    $Key = Read-Host -AsSecureString
    
    if (Test-Path .\API\API-Key.xml){
        Remove-Item .\API\API-Key.xml
    }
    if ($null -ne $Key){
        $Key | Export-Clixml -Path ".\API\API-Key.xml"
        $KeyLoc = Import-CliXml -Path ".\API\API-Key.xml"
    }
    #Decrypt0r
    if (Test-Path ".\API\API-Key.xml"){
    Set-ColoredLine $TxtBxOutput Black "Secure API Key was successfully created. Please close MNCT completely to re-establish the key correctly."
    }
    }
    #API KEY
    $APIKey = $TxtBxAPIKey.Text
    #Default URI
    $BaseURL = 'https://api.meraki.com/api/v0'
    #HEADERS
    $headers = @{
        "X-Cisco-Meraki-API-Key" = $APIKey
        'Content-Type'           = 'application/json'
    }

$OrgNum = 1
if (Test-Path .\Organizations\$OrgNum.txt){
    Set-ColoredLine $TxtBxOutput Green ('Organization have been detected. Organizations have now been imported into MNCT.' + "`r`n")
#region Organization Import
###########ORG IMPORT COMBOBOX##########
#Build out our Org Combo Box
$ComboOrgImport.Items.Clear()
While ((Test-Path .\Organizations\$OrgNum.txt) -eq $true){
$ComboOrgImport.Items.AddRange((((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name))
$OrgNum += 1
}
#Set our default as the first Item entry
$ComboOrgImport.Text = $ComboOrgImport.Items[2]
###########ORG IMPORT COMBOBOX##########
    
######Grab our first launch defaults for Org Import Information####
#Org selection process
$OrgNum = 1
foreach ($Organization in $ComboOrgImport.Items){
    if ($ComboOrgImport.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name){
        $Global:OrgID = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).id
        $Global:BaseURL = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).url
    } 
    if (!($ComboOrgImport.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name)){
    $OrgNum += 1
    }
}
    
#Grab our network ID for the new network
$GetNetNameImportIndex = $BaseURL + '/organizations/' + $OrgID + '/networks'
$request = Invoke-RestMethod -Method GET -Uri $GetNetNameImportIndex -Headers $headers
$NetworkImportIndex = ($request).Name
$TxBxNetNameImport.Items.Clear()
$TxBxNetNameImport.Items.AddRange(($NetworkImportIndex | Sort-Object))
    ####End Import Network List Info
    
#Set our bulk Import Networks List up after capture
$NetListImports = ($NetworkNameIndex | Sort-Object)
$TxtBxNetList.Text = ''
foreach ($NetListImports in $NetListImports){
$TxtBxNetList.Text = $TxtBxNetList.Text + $NetListImports
$TxtBxNetList.Text += "`r`n"
}
#endregion
    
#region Default Organization Info
###########ORG COMBOBOX##########
#Build out our Org Combo Box
$OrgNum = 1
$ComboOrgName.Items.Clear()
While ((Test-Path .\Organizations\$OrgNum.txt) -eq $true){
$ComboOrgName.Items.AddRange((((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name))
$OrgNum += 1
}
#Set our default as the first Item entry
$ComboOrgName.Text = $ComboOrgName.Items[2]
###########ORG COMBOBOX##########
    
######Grab our first launch defaults for Org Information####
#Org selection process
$OrgNum = 1
foreach ($Organization in $ComboOrgName.Items){
    if ($ComboOrgName.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name){
        $Global:OrgID = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).id
        $Global:BaseURL = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).url
    } 
    if (!($ComboOrgName.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name)){
    $OrgNum += 1
    }
}
    
#Grab our network ID for the new network
$GetNetNameIndex = $BaseURL + '/organizations/' + $OrgID + '/networks'
$request = Invoke-RestMethod -Method GET -Uri $GetNetNameIndex -Headers $headers
$NetworkNameIndex = ($request).Name
$TxtNetworkName.Items.Clear()
$TxtNetworkName.Items.AddRange(($NetworkNameIndex | Sort-Object))
#End Grab of net list Info
    
#endregion
}

if (!(Test-Path .\Organizations\$OrgNum.txt)){
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('No Organization have been detected as imported. Please select Import Organization and then re-launch MNCT.' + "`r`n")

}

#Default Firewall rule information
$TxtBxFWRules.Text = 'No Firewall Rules have been imported into MNCT. Please import firewall rules to apply during update or creation of networks.'
    
#Build out our List of networks for bulk updates
$NetListImports = ($NetworkNameIndex | Sort-Object)
$TxtBxNetList.Text = ''
foreach ($NetListImports in $NetListImports){
$TxtBxNetList.Text = $TxtBxNetList.Text + $NetListImports
$TxtBxNetList.Text += "`r`n"
}
    
#Set our Update apply list as disabled until Update is checked
$TxtBxNetListApply.enabled = $false
    
#Uncheck both the overwrite and append on startup, set our name change txtbx disabled
if ($optNName.Checked -eq $false){
$RadNameOverwrite.Checked = $false
$RadNameAppend.Checked = $false
$TxtBxNameChange.enabled = $false
$RadNameOverwrite.enabled = $false
$RadNameAppend.enabled = $false
$RadNameEnd.enabled = $false
$RadNameFront.enabled = $false
}
    
#Set the L3 Top and Bottom options as disabled until it's selected
$optFWRTop.enabled = $false
$optFWRBottom.enabled = $false
$optFWRRemove.enabled = $false
    
#Set our Main Runspace (MNCT)'s name in the Runspace List
$Runspaces = Get-RunSpace
if ($Runspaces.Id -eq 1){
    $Runspaces.Name = "Meraki Network Configuration Tool"
}
$Runspaces = $null
    
#Update ComboTasks with current task information
$RSpaces = Get-Runspace
foreach ($Task in $RSpaces){
        try
        {
        $ComboTasks.Items.AddRange(((($Task | Where-Object {$_.id -ne 1}).Name | Sort-Object)))
        }
        catch 
        {}
}
    
#region GUI option Defaults
$optAppliance.Checked = $true
$optWireless.Checked = $true
#endregion
    
#Update the total amount of networks in the default Org selected
$lblNetworkNameInfo.Text = "Network Name (" + $TxtNetworkName.Items.Count + " Total)"
#Update the total amount of networks in the default Org selected for import
$LblNetTagName.Text = "Network Name (" + $TxBxNetNameImport.Items.Count + " Total)"
    
    
    
#endregion
    
############FUNCTIONS###################
#region Functions
#region SetOrgVersion
function Set-Orgv0{
#Org selection process
$OrgNum = 1
foreach ($Organization in $ComboOrgName.Items){
    if ($ComboOrgName.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name){
        $Global:OrgID = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).id
        $Global:BaseURL = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).url
    } 
    if (!($ComboOrgName.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name)){
    $OrgNum += 1
    }
}
    
#Set our Global OrgURL Values
$global:orgURI = $BaseURL
$global:orgBaseURI = $BaseURL
}
function Set-Orgv1{
#Org selection process
$OrgNum = 1
foreach ($Organization in $ComboOrgName.Items){
    if ($ComboOrgName.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name){
        $Global:OrgID = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).id
        $Global:BaseURL = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).urlv1
    } 
    if (!($ComboOrgName.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name)){
    $OrgNum += 1
    }
}
#Set our Global OrgURL Values
$global:orgURI = $BaseURL
$global:orgBaseURI = $BaseURL
    
}
function Set-OrgImportv0{
#Org selection process
$OrgNum = 1
foreach ($Organization in $ComboOrgImport.Items){
    if ($ComboOrgImport.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name){
        $Global:OrgID = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).id
        $Global:BaseURL = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).url
    } 
    if (!($ComboOrgImport.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name)){
    $OrgNum += 1
    }
}
#Set our Global OrgURL Values
$global:orgURI = $BaseURL
$global:orgBaseURI = $BaseURL
    
}
function Set-OrgImportv1{
#Org selection process
$OrgNum = 1
foreach ($Organization in $ComboOrgImport.Items){
    if ($ComboOrgImport.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name){
        $Global:OrgID = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).id
        $Global:BaseURL = ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).urlv1
    } 
    if (!($ComboOrgImport.text -eq ((Get-Content .\Organizations\$OrgNum.txt) | ConvertFrom-Json).name)){
    $OrgNum += 1
    }
}
#Set our Global OrgURL Values
$global:orgURI = $BaseURL
$global:orgBaseURI = $BaseURL
}
#endregion
#region Function NetworkID
function Get-NetworkID {
    if($ChkUpdateList.Checked -eq $false){
        try{
            #Grab our network ID for the new network
            $GetNetworkID = $BaseURL + '/organizations/' + $OrgID + '/networks'
            $request = Invoke-RestMethod -Method GET -Uri $GetNetworkID -Headers $headers
            $Global:NetworkID = ($request | Where-Object {$_.name -eq $TxtNetworkName.Text}).id
        }
        catch{
            $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
    }
    if($ChkUpdateList.Checked -eq $true){
        try{
            $Global:NetworkID = ($NetworkList | Where-Object {$_.name -eq $NetBulkImportList}).id
            }
        catch{
            $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
    }
}
function Get-NetworkImportID {
    try{
        #Grab the network ID of the selected network
        $GetNetworkID = $BaseURL + '/organizations/' + $OrgID + '/networks'
        $request = Invoke-RestMethod -Method GET -Uri $GetNetworkID -Headers $headers
        $Global:NetworkID = ($request | Where-Object {$_.name -eq $TxBxNetNameImport.Text}).id
    }
    catch{
            $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
    }
    
}
#endregion
function PreNetCreationChecks{
#Set our Continue variable to true until we've ran through all of our pre-flight checks and passed with flying colors
$Global:Continue = $true
Set-ColoredLine $TxtBxOutput Black ('Beginning Network Pre-Creation checks.' + "`r`n")
$WarningCount = 0
    
#Check and verify that there is not an existing network with the same name in this ORG.
$GetExistingNetwork = $BaseURL + '/organizations/' + $OrgID + '/networks'
$request = Invoke-RestMethod -Method GET -Uri $GetExistingNetwork -Headers $headers
$ExNetworkID = ($request | Where-Object {$_.name -eq $TxtNetworkName.Text}).Name
if($ExNetworkID -eq $TxtNetworkName.Text){'Cant have same name'
    $WarningCount += 1
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('You cannot add the same network name as an existing network into this Organization. Please change and try again.' + "`r`n")
    $Global:Continue = $false
}
#End Existing Network name checks
    
###First, check if PDNS or IDNS is select for each network that has any sign of entries
######################################DNS CHECKS
#Checks for VLAN 1 entries if both are false or if both are true
if($ChkPDNS1.Checked + $ChkIDNS1.Checked -eq $false){
    if($V1VLAN.Text -ne ''){
    $WarningCount += 1
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('You must select ProxyDNS or Internal DNS for VLAN: ' + $V1VLAN.Text + ' before continuing.' + "`r`n")
    $Global:Continue = $false
    }
}
if($ChkPDNS1.Checked -and $ChkIDNS1.Checked -eq $true){
    if($V1VLAN.Text -ne ''){
    $WarningCount += 1
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('You can only select one DNS option for VLAN: ' + $V1VLAN.Text + ' before continuing.' + "`r`n")
    $Global:Continue = $false
    }
}
    
#Checks for VLAN 2 entries if both are false or if both are true
if($ChkPDNS2.Checked + $ChkIDNS2.Checked -eq $false){
    if($V2VLAN.Text -ne ''){
    $WarningCount += 1
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('You must select ProxyDNS or Internal DNS for VLAN: ' + $V2VLAN.Text + ' before continuing.' + "`r`n")
    $Global:Continue = $false
    }
}
if($ChkPDNS2.Checked -and $ChkIDNS2.Checked -eq $true){
    if($V2VLAN.Text -ne ''){
    $WarningCount += 1
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('You can only select one DNS option for VLAN: ' + $V2VLAN.Text + ' before continuing.' + "`r`n")
    $Global:Continue = $false
    }
}
    
#Checks for VLAN 3 entries if both are false or if both are true
if($ChkPDNS3.Checked + $ChkIDNS3.Checked -eq $false){
    if($V3VLAN.Text -ne ''){
    $WarningCount += 1
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('You must select ProxyDNS or Internal DNS for VLAN: ' + $V3VLAN.Text + ' before continuing.' + "`r`n")
    $Global:Continue = $false
    }
}
if($ChkPDNS3.Checked -and $ChkIDNS3.Checked -eq $true){
    if($V3VLAN.Text -ne ''){
    $WarningCount += 1
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('You can only select one DNS option for VLAN: ' + $V3VLAN.Text + ' before continuingtinuing.' + "`r`n")
    $Global:Continue = $false
    }
}
    
######################################END DNS Checking
    
############SSID CHECKS###############
#Checks that there isnt a PSK and Open config on the SSID, various failsafes
    
#Check if wireless device type is added and SSID fields are detected
if(($optWireless.Checked -eq $false) -and ($null -ne $SSIDN.Text)){
    $WarningCount += 1
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("You cannot create an SSID without adding the wireless device type" + "`r`n")
    $Global:Continue = $false
}
    
Validate-SSIDs
    
############END SSID CHECKS###########
    
##########WARN FOR NO SERIAL BEFORE NOTE ENTRY###########
if ($TxtBxSD.Text -eq ''){
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: Device notes will not be added due to no clarified S/N on the entry.' + "`r`n")
}
    
    
############END WARNING###################
    
########VPN SAFEGUARDS###################
#This is used to prevent any vpn conflicts from occuring before the network is created even if the create network button was pressed past CSA warnings
if (Test-Path -Path ('.\RouteTable.txt')){
$Routetable = (Get-Content ('.\RouteTable.txt'))
    
$Subnet1 = $TxtBxNet1Range.Text + $TxtCidr1.Text
$Subnet2 = $TxtBxNet2Range.Text + $TxtCidr2.Text
$Subnet3 = $TxtBxNet3Range.Text + $TxtCidr3.Text
    
#Check the first VLAN entry submission
if ($Chk1VLANVPN.Checked -eq $true){
if (!([string]::IsNullOrWhitespace($Subnet1))){
if ($Routetable | Select-String -Pattern $Subnet1){
$WarningCount += 1
Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
Set-ColoredLine $TxtBxOutput DarkGoldenrod ('THIS ROUTE:' + $Subnet1 + "`r`n" + 'IS IN USE IN THE VPN, ALLOWING USE IN THE VPN TUNNEL WILL CAUSE ADDRESSING CONFLICT.' + "`r`n" + "`r`n")
$Global:Continue = $false
}
}
}
    
    
#Check the second VLAN entry submission
if ($Chk2VLANVPN.Checked -eq $true){
if (!([string]::IsNullOrWhitespace($Subnet2))){
if  ($Routetable |Select-String -Pattern $Subnet2){
$WarningCount += 1
Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
Set-ColoredLine $TxtBxOutput DarkGoldenrod ('THIS ROUTE:'  + $Subnet2 + "`r`n" +  'IS IN USE IN THE VPN, ALLOWING USE IN THE VPN TUNNEL WILL CAUSE ADDRESSING CONFLICT.' + "`r`n" + "`r`n")
$Global:Continue = $false
}
}
}
    
#Check the third VLAN entry submission
if ($Chk3VLANVPN.Checked -eq $true){
if (!([string]::IsNullOrWhitespace($Subnet3))){
if ($Routetable |Select-String -Pattern $Subnet3){
$WarningCount += 1
Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
Set-ColoredLine $TxtBxOutput DarkGoldenrod ('THIS ROUTE:' + $Subnet3 + "`r`n" + 'IS IN USE IN THE VPN, ALLOWING USE IN THE VPN TUNNEL WILL CAUSE ADDRESSING CONFLICT.' + "`r`n" + "`r`n")
$Global:Continue = $false
}
}
}
    
}
    
##########END VPN SAFEGUARDS#############
    
    
########Device Type Safeguard############
if($optAppliance.Checked + $optSwitch.Checked + $optWireless.Checked + $optCG.Checked + $optCam.Checked -eq $false){
    $WarningCount += 1
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('At least one Device type must be selected under Network Device Types before continuing' + "`r`n")
    $Global:Continue = $false
}
    
############Device Type Safeguard########
if ($Global:Continue -eq $false){
Set-ColoredLine $TxtBxOutput Red ('Network Creation Failed.' + "`r`n" +  'Please remediate the above ' + $WarningCount + ' warnings before trying to create the network again.')
}
if ($Global:Continue -eq $true){
Set-ColoredLine $TxtBxOutput Green ('Prerequisite test complete!' + ' Now Creating Network.' + "`r`n")
}
}
function Update-MNCTStatus{
    Param (
        [bool]$Running
    )
if ($Running -eq $true){
$lblProcStatus.ForeColor      = [System.Drawing.ColorTranslator]::FromHtml("#67cd3c")
$lblProcStatus.text           = "Status: Running, please wait."
}
if ($Running -eq $false){
$lblProcStatus.ForeColor      = [System.Drawing.ColorTranslator]::FromHtml("#000000")
$lblProcStatus.text           = "Status: Not Running."
}
}
function Import-Folder($initialDirectory) {
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowserDialog.RootFolder = "MyComputer"
    $FolderBrowserDialog.SelectedPath = ($pwd.path + '\' + 'NetworkExports\')
    if ($initialDirectory) { $FolderBrowserDialog.SelectedPath = $initialDirectory }
    [void] $FolderBrowserDialog.ShowDialog()
    Set-ColoredLine $TxtBxOutput Green ("Importing Network Configuration information from: " + $FolderBrowserDialog.SelectedPath + "`r`n")
    $Global:NetworkImportPath = $FolderBrowserDialog.SelectedPath
}
#region MrkCommands
function Invoke-MrkRestMethod {
        [CmdletBinding()]
                        Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$ResourceID,
        [Parameter(Mandatory)][ValidateSet('GET','POST','PUT','DELETE')][String]$Method,
        [Parameter()]$body
    )
        $orgBaseUri = Get-MrkOrgEndpoint
        $uri = $orgBaseUri + $ResourceID
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                try {
        $request = Invoke-RestMethod -Method $Method -ContentType 'application/json' -Headers (Get-MrkRestApiHeader) -Uri $uri -Body ($body | ConvertTo-Json -Depth 10)
                                                                } catch {
        if ($_.exception.message -match [regex]::Escape('(429)')){
            Write-Verbose "Meraki reports 'Too many API Rquests', sleeping 1 second and rerunning the same request"
            Start-Sleep 1
                $request = Invoke-RestMethod -Method $Method -ContentType 'application/json' -Headers (Get-MrkRestApiHeader) -Uri $uri -Body ($body | ConvertTo-Json -Depth 10)
            # Invoke-MrkRestMethod -ResourceID $ResourceID -Method $method -body $body;
        } elseif ($_.exception.message -match [regex]::Escape('(308)')){
                Write-Verbose "Meraki reports redirection. Request the orgBaseUri and rerun the same request"
                Get-MrkOrgEndpoint # reset the $global:orgBaseUri variable to get the non-default api.meraki.com URI
                $uri = $global:orgBaseUri + $ResourceID
                $request = Invoke-RestMethod -Method $Method -ContentType 'application/json' -Headers (Get-MrkRestApiHeader) -Uri $uri -Body ($body | ConvertTo-Json -Depth 10)
                # Invoke-MrkRestMethod -ResourceID $ResourceID -Method $method -body $body;
        } else {
            Get-RestError
        }
    }
        return $request
    }
function Get-RestError {
        Write-Output "PS Error: $_.Exception.Message"
        $result = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $responseBody = $reader.ReadToEnd();
        Write-Output "REST Error: $responsebody"
    }
function Get-MrkOrgEndpoint {
                            <#
    .DESCRIPTION
    PowerShell cmdlet has trouble with the redirectoion meraki uses, from api.meraki.com to the organization specific url ( such as n210.meraki.com).
    To work around this issue this function retrieves the oranization specific URL and uses it through out the module functions.
    The global variable orgBaseUri is set here and used in the invoke restmethod script.
    #>
        [CmdletBinding()]
        Param ()
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                                if (!$orgBaseUri){
        Write-Verbose "Get-MrkOrgEndpoint: global orgBaseUri is empty, retrieving organization specific meraki endpoint"
        $orgURI = 'https://api.meraki.com/api/v0/organizations'
        $webRequest = Invoke-WebRequest -uri $orgURI -Method GET -Headers (Get-MrkRestApiHeader)
        $redirectedURL = $webRequest.BaseResponse.ResponseUri.AbsoluteUri
        $global:orgBaseUri = $redirectedURL.Replace('/organizations','')
    }
        Write-Verbose "Get-MrkOrgEndpoint: Meraki RestApi organization URL: $orgBaseUri"
        Return $orgBaseUri
    }
function Get-MrkRestApiHeader {
        [CmdletBinding()]
        Param ()
                    if (!$mrkRestApiKey){
        Set-MrkRestApiKey 
        Get-MrkRestApiHeader
                        } Else {
        $global:mrkRestApiHeader = @{
        "X-Cisco-Meraki-API-Key" = $mrkRestApiKey
        }
        return $mrkRestApiHeader
    }
    }
function Set-MrkRestApiKey {
                                                        <#
    .SYNOPSIS
    Sets a Meraki Rest API key for a powershell session
    .DESCRIPTION
    REST API key is unique for each Meraki dashboard user. the REST API should be enabled organization wide, a dashboard user is able to create a key
    more info https://documentation.meraki.com/zGeneral_Administration/Other_Topics/The_Cisco_Meraki_Dashboard_API
    .EXAMPLE
    Set-MrkRestApiKey 
    .EXAMPLE
    Set-MrkRestApiKey 1234567890abcdefabcd1234567890abcdefabcd
    .PARAMETER key
    40 characters 0-9 a-f key that represents a logged in Meraki dashboard user 
    #>
        [CmdletBinding()]
                Param (
        [String]$key
    )
                if (!$mrkRestApiKey){
        $global:mrkRestApiKey = $APIKey    
    } 
                        if ($key){
        $global:mrkRestApiKey = $key
        Write-Host New Key set, invoking get-mrkOrgEndpoint
        Get-MrkOrgEndpoint
    }
                    if (!(Test-MrkRestApiKey -apiKey $mrkRestApiKey)){
        Write-Host REST API Key is invalid
        break
    }
    }
function Test-MrkRestApiKey {
                                            <#
    .SYNOPSIS
    Tests a Meraki Rest API key is it suits the syntax
    .DESCRIPTION
    Tests a Meraki Rest API key is it is 40 bytes long. 
    .EXAMPLE
    Test-MrkRestApiKey -apiKey 1234567890abcdefabcd1234567890abcdefabcd
    .PARAMETER apiKey
    40 characters 0-9 a-f key that represents a logged in Meraki dashboard user 
    #>
        [CmdletBinding()]
        [OutputType([bool])]
                Param (
        [Parameter()][string]$apiKey
    )
                    if ($apiKey.Length -ne 40){
        Write-Output "key length is not 40 bytes`, aborting.."
        return $false
    }
        return $true
    }
#endregion
#region Device Functions
function Remove-MrkDevice {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$Networkid,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][Alias("serialNr")][String]$serial
    )
    $request = Invoke-MrkRestMethod -Method POST -ResourceID ('/networks/' + $networkId + '/devices/' + $serial + '/remove')
    return $request
}
function New-MrkDevice {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][Alias("serialNr")][String]$serial
    )
    $body = @{
        "serial" = $serial
    }
    $request = Invoke-MrkRestMethod -Method POST -ResourceID ('/networks/' + $networkId + '/devices/claim') -Body $body
    return $request
}
function Get-MrkNetworkDevice {
        [CmdletBinding()]
                Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId
    )
        $request = Invoke-MrkRestMethod -Method GET -ResourceID ('/networks/' + $networkId + '/devices')
        return $request
    }
function Update-MrkDevice {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][Alias("serialNr")][String]$serial,
        [Parameter()][String]$NewName,
        [Parameter()][String]$NewTags,
        [Parameter()][String]$NewAddress,
        [Parameter()][String]$Notes
    )
    $body = @{
        "notes"=$Notes
    }
    $request = Invoke-MrkRestMethod -Method PUT -ResourceID ('/networks/' + $networkId + '/devices/' + $serial) -Body $body  
    return $request
}
#endregion
#region Update Functions
function Set-Syslog{
    if($ChkUpdateList.Checked -eq $true){
        Set-ColoredLine $TxtBxOutput Black ('Beginning to update syslog on Network:' + $NetBulkImportList + "`r`n")
    }
    if($ChkUpdateList.Checked -eq $false){
        Set-ColoredLine $TxtBxOutput Black ('Beginning to update syslog on Network:' + $TxtNetworkName.Text + "`r`n")
    }
    
    ####Check what our network types are, then add and create them in###
    #Define our Orgs
    Set-Orgv1
    
    try{
        Set-ColoredLine $TxtBxOutput Black ("Attempting to import syslog config into network. " + "`r`n")
        $SyslogFPath = '.\Syslog\syslog.txt'
        $SyslogConf = (Get-Content $SyslogFPath)
        $GetSyslogID = $BaseURL + '/networks/' + $NetworkID + '/syslogServers'
        $result = Invoke-Restmethod -Method PUT -Uri $GetSyslogID -Headers $headers -body $SyslogConf
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Green ("Syslog import has been applied. " + "`r`n")
    }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        if ($null -eq $result){
            Set-ColoredLine $TxtBxOutput Red ("Syslog import had an issue with the options that were being applied. Verify that the network can support the syslog options being added. " + "`r`n")
        }
        if ($null -ne $result){
            Get-CurrentLine
            $break
        }
        }
    #Set our Orgs back to v0
    Set-Orgv0
}
function Set-Alerts {
    if($ChkUpdateList.Checked -eq $false){
        Set-ColoredLine $TxtBxOutput Black ('Beginning to update alerts on Network:' + $TxtNetworkName.Text + "`r`n")
    }
    if($ChkUpdateList.Checked -eq $true){
        Set-ColoredLine $TxtBxOutput Black ('Beginning to update alerts on Network: ' + $NetBulkImportList + "`r`n")
    }
        
    ####Check what our network types are, then add and create them in###
    #Define our Orgs
    Set-Orgv1
    
    try{
        Set-ColoredLine $TxtBxOutput Black ("Attempting to import alerts into network. " + "`r`n")
        $AlertFPath = '.\Alerts\Alerts.txt'
        $AlertConf = (Get-Content $AlertFPath)
        $GetAlertID = $BaseURL + '/networks/' + $NetworkID + '/alerts/settings'
        $result = Invoke-RestMethod -Method PUT -Uri $GetAlertID -Headers $headers -body $AlertConf
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Black ("Alert import has been applied. " + "`r`n")
    }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    
    #Set our Orgs back to v0
    Set-Orgv0
}
function Set-Location{ 
    if($null -ne $Global:LocData){
        try{
            Set-ColoredLine $TxtBxOutput Black ('Attempting to apply Location/Floor plan configuration.' + "`r`n")
            $GetFloorPlanURI = $BaseURL + '/networks/' + $NetworkID + '/floorPlans'
            $result = Invoke-RestMethod -Method POST -Uri $GetFloorPlanURI -Headers $headers -Body ($Global:LocData | ConvertTo-Json)
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            Set-ColoredLine $TxtBxOutput Black ("Location data and floor plans have been imported into the new network." + "`r`n")
        }
        catch{
            $RESTError = ParseErrorForResponseBody($_)
            if ($RESTError.errors -match "missing: 'name' and 'imageContents'"){
                Set-ColoredLine $TxtBxOutput Red ("Location update failed likely caused by incorrect data being applied to the network." + "`r`n")
                Set-ColoredLine $TxtBxOutput Red ([string]$RESTError.errors + "`r`n")
            }
            else{
                Get-CurrentLine
                $break
            }
        }
    }
}
function Set-ContentFiltering {
    #Import Content Filtering rules into the new network
    if($null -ne $Global:ContentFiltering){
        Set-Orgv0
            try{
                if($ChkUpdateList.Checked -eq $true){
                    Set-ColoredLine $TxtBxOutput Black ('Attempting to apply Content filtering configuration on Network: ' + $NetBulkImportList + "`r`n")
                }
                if($ChkUpdateList.Checked -eq $false){
                    Set-ColoredLine $TxtBxOutput Black ('Attempting to apply Content filtering configuration on Network: ' + $TxtNetworkName.Text + "`r`n")
                }
                Set-ColoredLine $TxtBxOutput Black ("Adding: " + ($Global:ContentFiltering | ConvertTo-Json) + "`r`n")
                $ContentFilterURI = $BaseURL + '/networks/' + $NetworkID + '/contentFiltering'
                #Build and send the API call
                $result = Invoke-RestMethod -Method PUT -Uri $ContentFilterURI -Headers $headers -body ($Global:ContentFiltering | ConvertTo-Json)
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    
                if($ChkUpdateList.Checked -eq $true){
                    Set-ColoredLine $TxtBxOutput Green ("Content Filtering Rules has been applied on Network: " + $NetBulkImportList + "`r`n")
                }
                if($ChkUpdateList.Checked -eq $false){
                    Set-ColoredLine $TxtBxOutput Green ("Content Filtering Rules has been applied on Network: " + $TxtNetworkName.Text + "`r`n")
                }
            }
            catch{
                $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
    }
}
function Set-ThreatProtection {
    if ($null -ne $Global:SecData){
        Set-Orgv1
        if($ChkUpdateList.Checked -eq $true){
            Set-ColoredLine $TxtBxOutput Black ('Attempting to add Threat protection configuration on Network: ' + $NetBulkImportList + "`r`n")
        }
        if($ChkUpdateList.Checked -eq $false){
            Set-ColoredLine $TxtBxOutput Black ('Attempting to add Threat protection configuration on Network: ' + $TxtNetworkName + "`r`n")
        }
        try{
            #Build Threat Prot URI
            $ThreatProtURI = $BaseURL + '/networks/' + $NetworkID + '/appliance/security/malware'
    
            $result = Invoke-RestMethod -Method PUT -Uri $ThreatProtURI -Headers $headers -body ($Global:SecData | ConvertTo-Json)
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            
            if($ChkUpdateList.Checked -eq $true){
                Set-ColoredLine $TxtBxOutput Green ("Security data has been applied successfully on Network: " + $NetBulkImportList + "`r`n")
            }
            if($ChkUpdateList.Checked -eq $false){
                Set-ColoredLine $TxtBxOutput Green ("Security data has been applied successfully on Network: " + $TxtNetworkName + "`r`n")
            }
        }
        catch{
            $RESTError = ParseErrorForResponseBody($_)
                if ($RESTError.errors -match "not supported"){
                    Set-ColoredLine $TxtBxOutput Red ([string]$RESTError.errors + "`r`n")
                }
                else{
                    Get-CurrentLine
                    $break 
                }
        }
        Set-Orgv0
    }
}
function Set-IDS {
    if ($null -ne $Global:IDSData){
            Set-Orgv1
            try{
                Set-ColoredLine $TxtBxOutput Black ('Attempting to add IDS configuration.' + "`r`n")
                #Build Threat Prot URI
                $IdsURI = $BaseURL + '/networks/' + $NetworkID + '/appliance/security/intrusion'
                $result = Invoke-RestMethod -Method PUT -Uri $IdsURI -Header $headers -body ($Global:IDSData | ConvertTo-Json)
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Green ("IDS data has been applied successfully." + "`r`n")
            }
            catch{
                $RESTError = ParseErrorForResponseBody($_)
                if ($RESTError.errors -match "not supported"){
                    Set-ColoredLine $TxtBxOutput Red ([string]$RESTError.errors + "`r`n")
                }
                else{
                    Get-CurrentLine
                    $break 
                } 
            }
            Set-Orgv0
    }
}
function Set-TrafficShaping {
    if ($null -ne $Global:TRSData){
        #Define our Orgs
        Set-Orgv1
    
        if($ChkUpdateList.Checked -eq $true){
            Set-ColoredLine $TxtBxOutput Black ('Attempting to apply traffic shaping rules on Network: ' + $NetBulkImportList + "`r`n")
        }
        if($ChkUpdateList.Checked -eq $false){
            Set-ColoredLine $TxtBxOutput Black ('Attempting to apply traffic shaping rules on Network: ' + $TxtNetworkName + "`r`n")
        }
        try{
            #Grab the Malware security URI
            $GetTRSID = $BaseURL + '/networks/' + $NetworkID + '/appliance/trafficShaping'
            $result = Invoke-RestMethod -Method PUT -Uri $GetTRSID -Headers $headers -body ($Global:TRSData | ConvertTo-Json)
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            if($ChkUpdateList.Checked -eq $true){
                Set-ColoredLine $TxtBxOutput Green ("Traffic Shaping Rules has been applied on Network: " + $NetBulkImportList + "`r`n")
            }
            if($ChkUpdateList.Checked -eq $false){
                Set-ColoredLine $TxtBxOutput Green ("Traffic Shaping Rules has been applied on Network: " + $TxtNetworkName + "`r`n")
            }
        }
        catch{
            $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
    
        #Set the OrgID back to the way it was.
        Set-Orgv0
    }
}
#endregion
#region SSID Functions
function Set-MrkNetworkSSID {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId,
        [Parameter(Mandatory,HelpMessage="Provide a number between 0 and 15")][int]$number,
        [Parameter(Mandatory)][string]$name,
        [Parameter(Mandatory)][bool]$enabled,
        [Parameter()][ValidateSet('None', 'Click-through splash page', 'Billing', 'Password-protected with Meraki RADIUS', 'Password-protected with custom RADIUS', 'Password-protected with Active Directory', 'Password-protected with LDAP', 'SMS authentication', 'Systems Manager Sentry', 'Facebook Wi-Fi', 'Google OAuth', 'Sponsored guest')]
        [String]$splashPage,
        [Parameter(Mandatory)][ValidateSet("open","psk","open-with-radius","8021x-meraki","8021x-radius")][String]$authMode,
        [Parameter()][String]$psk,
        [Parameter(Mandatory)][ValidateSet('wpa','wep','wpa-eap')][String]$encryptionMode,
        [Parameter()][ValidateSet('WPA1 and WPA2','WPA2 only')][String]$wpaEncryptionMode,
        [Parameter(Mandatory)][ValidateSet('NAT mode','Bridge mode','Layer 3 roaming','Layer 3 roaming with a concentrator','VPN')][String]$ipAssignmentMode,
        [Parameter()][ValidateSet('1','2','5.5','6','9','11','12','18','24','36','48','54')][int]$minBitrate,
        [Parameter()][bool]$useVlanTagging,
        [Parameter()][int]$vlanId,
        [Parameter()][int]$defaultVlanId,
        [Parameter()][ValidateSet('Dual band operation', '5 GHz band only', 'Dual band operation with Band Steering')][string]$bandSelection,
        [Parameter()][int]$perClientBandwidthLimitUp,
        [Parameter()][int]$perClientBandwidthLimitDown,
        [Parameter(HelpMessage="format 'servername_or_ip,server_port,secret'")][string[]]$radiusServers,
        [Parameter()][bool]$radiusAccountingEnabled,
        [Parameter(HelpMessage="format 'servername_or_ip,server_port,secret'")][string[]]$radiusAccountingServers,
        [Parameter()][bool]$radiusCoaEnabled,
        [Parameter()][ValidateSet('Deny access','Allow access')][string]$radiusFailoverPolicy,
        [Parameter()][Validateset('Strict priority order','Round robin')][string]$radiusLoadBalancingPolicy,
        [Parameter()]$concentratorNetworkId,
        [Parameter()]$walledGardenEnabled,
        [Parameter()]$walledGardenRanges,
        [Parameter()]$apTagsAndVlanIds
    )
    #validate parameter-dependencies for psk, radius type authentication
    if (($authMode -eq '8021x-radius' -or $authMode -eq 'open-with-radius') -and $null -eq $radiusServers){
        $radiusServers=read-host -Prompt "the radiusserver(s) must be provided. Enter the parameters like 'radiusserver1,port,secret', 'radiusserver2,port,secret', '...' ";$PSBoundParameters += @{radiusServers = '1.2.3.4,1234,qwert'}
    }
    if ($authMode -eq 'psk' -and "" -eq $psk){
        $psk = read-host -Prompt "the psk key must be provided when authMode equals 'psk'";
        $PSBoundParameters += @{psk = $psk}
    }
    if($useVlanTagging -and $ipAssignmentMode -notin 'Bridge mode', 'Layer 3 roaming'){
        Write-Host "useVlanTagging is set to TRUE but the ipAssignmentMode is either not set or not one of 'Bridge mode' or 'Layer 3 roaming'"
        Write-Host "change the ipAssignmentMode or useVlanTagging to FALSE and run the command again"
        break
    }
    if($ipAssignmentMode -in 'Bridge mode', 'Layer 3 roaming' -and $defaultVlanId -eq 0){
        $defaultVlanId = read-host -Prompt "the -defaultVlanId parameter must be provided when ipAssignmentMode equals 'Bridge mode' or 'Layer 3 roaming'. Pls type the id number";
        $PSBoundParameters += @{defaultVlanId = $defaultVlanId}
    }
    if($ipAssignmentMode -in 'Layer 3 roaming with a concentrator', 'VPN' -and $vlanId -eq 0){
        $vlanId = read-host -Prompt "the -vlanId parameter must be provided when ipAssignmentMode equals 'Bridge mode' or 'Layer 3 roaming'. Pls type the id number";
        $PSBoundParameters += @{vlanId = $vlanId}
    }
    
    $body = [PSCustomObject]@{}
    #add the other properties to the $body as noteproperties based on parameter value present or not
    foreach ($key in $PSBoundParameters.keys){
        if($key -eq 'radiusServers' -or $key -eq 'radiusAccountingServers'){
            $valArray = @()
            foreach($serverParam in $PSBoundParameters.item($key)){
                #format like 'servername/ip','serverport','secret'
                $server = $serverParam.split(",")[0]
                $port = $serverParam.split(",")[1]
                $secret = $serverParam.split(",")[2]
                if ($null -eq $secret){$secret = Read-Host -Prompt 'provide the radius-secret for server $server'}
                $value = [pscustomobject]@{
                    host = $server
                    port = $port
                    secret = $secret
                }
                $valArray += $value
            }
            $body | Add-Member -MemberType NoteProperty -Name $key -Value $valArray
        } elseif ($key -ne 'networkId') {
            $body | Add-Member -MemberType NoteProperty -Name $key -Value $PSBoundParameters.item($key)
        }
    }
    #$body | convertto-json
    $request = Invoke-MrkRestMethod -Method PUT -ResourceID ('/networks/' + $networkId + '/ssids/' + $number) -body $body
    return $request
}
function New-SSID{
try{
    #First SSID Creation and Checks
    #The first SSID entry will always equal 0
    #First, Check if there's an entry in the SSID Name, if so, we'll process this and begin building out the SSID configuration
    #####WPA Secured configuration#####
    $SSIDFile0Loc = '.\SSID\0.txt'
    $SSIDFILE0 = (Get-Content $SSIDFile0Loc | ConvertFrom-Json)
    #####Open Network configuration####
    $SSIDFile1Loc = '.\SSID\1.txt'
    $SSIDFILE1 = (Get-Content $SSIDFile1Loc | ConvertFrom-Json)
    #Build out our loop
    $ssidnum = 0
    do {
        if ($SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum] -ne ''){
            Set-ColoredLine $TxtBxOutput Black ('Attempting to create SSID entry: ' + '(' + ($SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum]) + ')' + "`r`n")
            #Create as a secured wireless network
            if ($SSIDType.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum] -eq 'N'){
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                $result = Set-MrkNetworkSSID -networkId $NetworkID -enabled $SSIDFILE0.enabled -number $ssidnum -name ($SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum])  -splashPage $SSIDFILE0.splashPage -authMode $SSIDFILE0.authMode -psk ($SSIDPSK.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum]) -encryptionMode $SSIDFILE0.encryptionMode -wpaEncryptionMode $SSIDFILE0.wpaEncryptionMode -ipAssignmentMode $SSIDFILE0.ipAssignmentMode -minBitrate $SSIDFILE0.minBitrate -perClientBandwidthLimitDown $SSIDFILE0.perClientBandwidthLimitDown -perClientBandwidthLimitUp $SSIDFILE0.perClientBandwidthLimitUp -bandSelection $SSIDFILE0.bandSelection -useVlanTagging $SSIDFILE0.useVlanTagging -defaultVlanId $SSIDFILE0.defaultVlanId -vlanId $SSIDFILE0.defaultVlanId
                Set-ColoredLine $TxtBxOutput Green ('Sent POST request to create SSID: ' + '(' + ($SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum]) + ')' + "`r`n")
            }
            #Create as an Open wireless network
            if ($SSIDType.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum] -eq 'Y'){
                $result = Set-MrkNetworkSSID -networkId $networkID -enabled $SSIDFILE1.enabled -number $ssidnum -name ($SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum]) -splashPage $SSIDFILE1.splashPage -authMode $SSIDFILE1.authMode -ipAssignmentMode $SSIDFILE1.ipAssignmentMode -useVlanTagging $SSIDFILE1.useVlanTagging -defaultVlanId $SSIDFILE1.defaultVlanId -minBitrate $SSIDFILE1.minBitrate -bandSelection $SSIDFILE1.bandSelection -perClientBandwidthLimitUp $SSIDFILE1.perClientBandwidthLimitUp -perClientBandwidthLimitDown $SSIDFILE1.perClientBandwidthLimitDown -encryptionMode wpa
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Green ('Sent POST request to create SSID: ' + '(' + ($SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum]) + ')' + "`r`n")
            }
        }
        $ssidnum += 1
    }while ($ssidnum -lt $SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""}).Count)
    $ssidnum = 0
    }
catch{
    $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break 
    }
}
function Validate-SSIDs{
#Build out our loop
#Beginning SSID Checks
$ssidnum = 0
do {
    if ($SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum] -ne ''){
        if ($null -ne $SSIDPSK.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum]){
            if (($SSIDType.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum] -eq 'Y') -and (($SSIDPSK.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum]) -ne 'N' )){
                $WarningCount += 1
                Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
                Set-ColoredLine $TxtBxOutput DarkGoldenrod ('You cannot have a PSK with the SSID set in Open. Please change before continuing.' + "`r`n")
                $Global:Continue = $false
            }
        }
        if (($SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""}).Count) -gt ($SSIDPSK.Text.Split([Environment]::NewLine).Where({ $_ -ne ""}).Count)){
                    $WarningCount += 1
                    Set-ColoredLine $TxtBxOutput DarkGoldenrod ( 'WARNING: ' + $WarningCount + "`r`n")
                    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('If leaving PSK blank due to it not being needed, enter N to evaluate this as No Password Open SSID configuration.' + "`r`n")
                    $Global:Continue = $false
        }
    }
    $ssidnum += 1
}while ($ssidnum -lt $SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum].Count)
$ssidnum = 0
    
#Check if we have any empty names but other fields are filled out
do {
    if ($SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum] -eq ''){
        if ($SSIDPSK.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum] -ne ''){
            $WarningCount += 1
            Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
            Set-ColoredLine $TxtBxOutput DarkGoldenrod ('you must specify a name for the SSID before continuing' + "`r`n")
            $Global:Continue = $false
        }
        if ($SSIDType.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum] -eq 'Y'){
            $WarningCount += 1
            Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
            Set-ColoredLine $TxtBxOutput DarkGoldenrod ('you must specify a name for the SSID before continuing' + "`r`n")
            $Global:Continue = $false
        }
        if ($SSIDType.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum] -eq 'N'){
            if ($SSIDPSK.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum] -ne ''){
                $WarningCount += 1
                Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
                Set-ColoredLine $TxtBxOutput DarkGoldenrod ('You cannot have a PSK entry with no SSID Name.' + "`r`n")
                $Global:Continue = $false
            }
        }
    }
    $ssidnum += 1
}while ($ssidnum -lt $SSIDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum].Count)
$ssidnum = 0
    
#Check if our PSK is too weak
do {
    if ($null -ne $SSIDPSK.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum]){
        if ((($SSIDPSK.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum]).Length -le 6) -and (($SSIDPSK.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum]) -ne 'N' ) -and ($SSIDType.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum] -ne 'Y')){
            $WarningCount += 1
            Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
            Set-ColoredLine $TxtBxOutput DarkGoldenrod ('You must choose a stronger PSK before continuing' + "`r`n")
            $Global:Continue = $false
        }
    }
    if (($SSIDPSK.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum]) -eq ($SSIDType.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum])){
        $WarningCount += 1
        Set-ColoredLine $TxtBxOutput DarkGoldenrod ('WARNING: ' + $WarningCount + "`r`n")
        Set-ColoredLine $TxtBxOutput DarkGoldenrod ('You must choose a stronger PSK before continuing. If this was intended to be an open network, ensure that the Open configuration is set to "Y"' + "`r`n")
        $Global:Continue = $false
    }
    $ssidnum += 1
}while($ssidnum -lt $SSIDPSK.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$ssidnum].Count)
$ssidnum = 0
    
}
#endregion
#region Firewall Functions
function Get-MrkNetworkMXL3FwRule {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId
    )
    
    $request = Invoke-MrkRestMethod -Method GET -ResourceID ('/networks/' + $networkId + '/l3FirewallRules')
    return $request
}
function Update-MrkNetworkMXL3FwRule {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$networkId,
    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$comment,
    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("allow", "deny")]
        [String]$policy,
    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("any","tcp","udp","icmp")]
        [String]$protocol,
    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$srcPort,
    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$srcCidr,
    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$destPort,
    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$destCidr,
    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("add", "remove")]
        [String]$action,
    
        [Parameter()]
        [switch]$reset
    )
    $ruleset = @()
    if (-not $reset){
        $ruleSource = Get-MrkNetworkMXL3FwRule -networkId $networkId
        #the non-default rules are in the array above the default
        $ruleset = $ruleSource[0..$(($ruleSource.Count) -2)]
    }
        
    #populate the to-be ruleset first with the existing rules (will be none in case of reset)
    $applyRules = @()
    ForEach ($rule in $ruleset){
    
        #if the action is delete and either the current rule comment matches the given comment, or the rule specifications protocol/destPort/destCidr are equal keep the entry in the ruleset. 
        if ($action -eq 'remove' -and `
            (($rule.protocol -eq $protocol -and `
            $rule.destPort -eq $destPort -and `
            $rule.destCidr -eq $destCidr) -or `
            ($rule.comment -eq $comment))){
                "No longer adding this rule: $comment";
                continue
            }
    
        if ($action -eq 'add' -and `
            (($rule.protocol -eq $protocol -and `
                $rule.srcPort -eq $srcPort -and `
                $rule.srcCidr -eq $srcCidr -and `
                $rule.destPort -eq $destPort -and `
                $rule.destCidr -eq $destCidr) -or `
                ($rule.comment -eq $comment))){
                    "Not adding this rule as it is already present: $comment";
                    $rulePresent = $true
                }
              
        #add this exising rule to the $ruleset object
        $ruleEntry = New-Object -TypeName PSObject -Property @{
            comment  = $rule.comment
            policy   = $rule.policy
            protocol = $rule.protocol
            srcPort  = $rule.srcPort
            srcCidr  = $rule.srcCidr
            destPort = $rule.destPort
            destCidr = $rule.destCidr
        }
    
        $applyRules += $ruleEntry
    
    }
    
    #append the new ruleobject to the applyRules
    if ($action -eq 'add' -and $true -ne $rulePresent){
        $ruleEntry = New-Object -TypeName PSObject -Property @{
            comment  = $comment
            policy   = $policy
            protocol = $protocol
            srcPort  = $srcPort
            srcCidr  = $srcCidr
            destPort = $destPort
            destCidr = $destCidr
        }
    
        $applyRules += $ruleEntry
    };
    
    #construct the full ruleObject to push into the $body of the RESTapi request
    $ruleObject = New-Object -TypeName PSObject -Property @{
        rules = $applyRules
    }
    
    if($true -ne $rulePresent){
    
        $request = Invoke-MrkRestMethod -Method PUT -ResourceID ('/networks/' + $networkId + '/l3FirewallRules') -body $ruleObject
        return $request
        Return ($request | ConvertTo-Json)
    }
}
function Update-MrkNetworkVLAN {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$id,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$name,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$subnet,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$applianceIp,
        [Parameter()][string[]]$dnsNameservers,
        [Parameter()][string[]]$reservedIpRanges,
        [Parameter()][ValidateSet("","Do not respond to DHCP requests", "Run a DHCP server")]
        [string]$dhcpHandling
    )
    #reservedIpRanges string property (IP Reservation(s), comma separated) must be converted into hashtable type to pass it on to the REST API
    if($null -ne $reservedIpRanges){
        $tmpCol = @()
        forEach($res in $reservedIpRanges){
            $tmpCol += New-Object -TypeName PSObject -Property @{
                start = ($res.split(","))[0]
                end = ($res.split(","))[1]
                comment = ($res.split(","))[2]
            }
        }
        [array]$reservedIpRanges = $tmpCol
    }
    
    $body  = @{
        "id" = $Id
        "networkId" = $networkId
        "name" = $name
        "applianceIp" = $applianceIP
        "subnet" = $subnet
        "dnsNameservers" = $dnsNameservers -join "`n"
        "reservedIpRanges" = $reservedIpRanges
        "dhcpHandling" = $dhcpHandling
    }
    $request = Invoke-MrkRestMethod -Method Put -ResourceID ('/networks/' + $Networkid + '/vlans/' + $Id) -Body $body  
    return $request
}
function Update-MrkNetworkMXL7FwRule{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId,
        [ValidateSet("deny")][String]$policy="deny",
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][ValidateSet("application", "applicationCategory","host","port","ipRange")][String]$type,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]$value,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][ValidateSet("add", "remove")][String]$action,
        [Parameter()][switch]$reset
    )
    
    $ruleset = @()
    if (-not $reset){
        $ruleset = (Get-MrkNetworkMXL7FwRule -networkId $networkId).rules
    }
    #the value in the rule-object is an object itself that cannot be compared as string
    if ($type -match "application"){
        $PSoValue = [pscustomobject]$value
    } else {
        $PSoValue = $value
    }
    
    #populate the to-be ruleset first with the existing rules (will be empty in case of reset)
    $applyRules = @()
    ForEach ($rule in $ruleset){
    
        #if the action is delete and the rule specifications policy/type/value are equal do not add it back to the ruleset. 
        if ($action -eq 'remove' -and `
            ($rule.policy -eq $policy -and `
            $rule.type -eq $type -and `
            $rule.value -match $PSoValue)){
                "No longer adding this rule: $value";
                continue
            }
    
        if ($action -eq 'add' -and `
            ($rule.policy -eq $policy -and `
                $rule.type -eq $type -and `
                $rule.value -match $PSoValue)){
                    "Not adding new rule as it is already present: $value";
                    $rulePresent = $true
                }
              
        #add this exising rule into the $ruleset object
        $ruleEntry = [PSCustomObject]@{
            policy = $rule.policy
            type   = $rule.type
            value  = $rule.value
        }
    
        $applyRules += $ruleEntry
    
    }
    
    #append the new ruleobject to the applyRules
    if ($action -eq 'add' -and $true -ne $rulePresent){
        $ruleEntry = New-Object -TypeName PSObject -Property @{
            policy = $policy
            type   = $type
            value  = $PSoValue
        }
    
        $applyRules += $ruleEntry
    };
    
    #construct the full ruleObject to push into the $body of the RESTapi request
    $ruleObject = New-Object -TypeName PSObject -Property @{
        rules = $applyRules
    }
    
    if($true -ne $rulePresent){
    
        $request = Invoke-MrkRestMethod -Method PUT -ResourceID ('/networks/' + $networkId + '/l7FirewallRules') -body $ruleObject
        return $request
    
        # construct the uri of the MR device in the current organization
        # $uri = "$(Get-MrkOrgEndpoint)/networks/$networkId/l7FirewallRules"    
        # try {
        #     $request = Invoke-RestMethod -Method Put `
        #     -ContentType 'application/json' `
        #     -Headers (Get-MrkRestApiHeader) `
        #     -Uri $uri `
        #     -Body ($ruleObject | ConvertTo-Json -Depth 4) -Verbose -ErrorAction Stop
    
        #     Write-Host "succesfully updated firewall rules" -ForegroundColor Green
        # }
        # catch
        # {
        #     $_.exception
        # }
    
        # Return ($request | ConvertTo-Json)
    
    }
}
function Get-MrkNetworkMXL7FwRule{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId
    )
    
    $request = Invoke-MrkRestMethod -Method GET -ResourceID ('/networks/' + $networkId + '/l7FirewallRules')
    return $request
}
#endregion
#region VLAN Functions
function Get-MrkNetworkVLAN {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId,
        [parameter()][string]$id
    )
    
    if ($null -eq $id -or "" -eq $id){
        $request = Invoke-MrkRestMethod -Method GET -ResourceID ('/networks/' + $networkId + '/appliance/vlans')
    }else{
        $request = Invoke-MrkRestMethod -Method GET -ResourceID ('/networks/' + $networkId + '/appliance/vlans/' + $id)
    }
      
    return $request
}
function Add-MrkNetworkVLAN {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$id,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$name,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$subnet,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$applianceIp,
        [Parameter()][string[]]$dnsNameservers,
        [Parameter()][string[]]$reservedIpRanges,
        [Parameter()][ValidateSet("Do not respond to DHCP requests", "Run a DHCP server")]
        [string]$dhcpHandling
    )
    
    #$config = Get-MrkNetworkVLAN -networkId $networkId -id 
    #reservedIpRanges string property (IP Reservation(s), comma separated) must be converted into hashtable type to pass it on to the REST API
    if($null -ne $reservedIpRanges){
        $tmpCol = @()
        forEach($res in $reservedIpRanges){
            $tmpCol += New-Object -TypeName PSObject -Property @{
                start = ($res.split(","))[0]
                end = ($res.split(","))[1]
                comment = ($res.split(","))[2]
            }
        }
        [array]$reservedIpRanges = $tmpCol
    }
    
    $body  = @{
        "id" = $Id
        "networkId" = $networkId
        "name" = $Name
        "applianceIp" = $applianceIP
        "subnet" = $Subnet
        "dnsNameservers" = $dnsNameservers -join "`n"
        "reservedIpRanges" = $reservedIpRanges
        "dhcpHandling" = $dhcpHandling
    }
    
    $request = Invoke-MrkRestMethod -Method POST -ResourceID ('/networks/' + $networkId + '/vlans') -Body $body
    
    #during POST (create new) VLAN the API doesn't handle the setting for DHCP mode other than 'Run a DHCP server'. By default the DHCP mode is enabled. In case the DHCP must be off,
    # the Update-MrkNetworkVLAN function is called to update the Network VLAN DHCP setting using the same variables for the POST action.
    #additionally the REST API ignores the $dnsNameservers value and always sets "upstream_dns" which is also corrected during the update call 
    If ($dhcpHandling -eq "Do not respond to DHCP requests" -or $dnsNameservers -ne "upstream_dns"){
        $request = Update-MrkNetworkVLAN -networkId $networkId -id $id -name $name -subnet $subnet -applianceIp $applianceIp -dhcpHandling $dhcpHandling -dnsNameservers $dnsNameservers -reservedIpRanges $reservedIpRanges
        return $request
    } else {
        return $request
    }
}
function Remove-MrkNetworkVLAN {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$id
    )
    $request = Invoke-MrkRestMethod -Method DELETE -ResourceID ('/networks/' + $networkId + '/vlans/' + $id)
    return $request
}
#endregion
#region VPN Functions
function Get-MrkNetworkS2sVpn {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId
    )
    $request = Invoke-MrkRestMethod -Method GET -ResourceID ('/networks/' + $networkId + '/siteToSiteVpn')
    return $request
}
function Set-MrkNetworkS2sVpn{
    param(
        [Parameter(Mandatory)][String]$networkId,
        [Parameter()][String[]]$vpnHubs,
        [Parameter(Mandatory)][ValidateSet("none", "hub", "spoke")][String]$mode, #none, hub, spoke
        [Parameter()][bool]$useDefaultRoute=$false,
        [Parameter()][String[]]$vpnSubnets,
        [Parameter()][bool]$enforce=$false
    )
    
    $s2sVpnConfig = Get-MrkNetworkS2sVpn -networkId $networkId
    
    $hubs = @()
    $subnets = @()
    
    switch($mode){
        'none' {
            $body = [pscustomobject]@{
                "mode" = $mode
            }
        }
            
        Default {
    
            ForEach ($hubId in $vpnHubs){
                $hubs += [pscustomobject]@{
                    "hubId" = $hubId
                    "useDefaultRoute" = $false
                }
            }
    
            #first invoke the rest-call to set the VPN mode; then call the rest-method to retrieve the networks known to meraki for this particular site.
            $body = [pscustomobject]@{
                "mode" = $mode
            }
            if ($mode -eq 'spoke'){
                $body | Add-Member -MemberType NoteProperty -Name "hubs" -value @($hubs)
            }
            $request = Invoke-MrkRestMethod -Method PUT -ResourceID ('/networks/' + $networkId + '/siteToSiteVpn') -body $body
    
            $localNetworks = (Get-MrkNetworkS2sVpn -networkId $networkId).subnets.localsubnet
    
            foreach($net in $vpnSubnets){
                #build the $subnets array. $net is constructed like $subnet,$inVpn. e.g: "10.16.48.0/24,yes" or "192.168.128.0/24,no"
                $useVpn = $false
    
                $netArr = $net -split (",")
    
                [string]$subnet = $netArr[0]
                $inVpn = ($net -split (","))[1]
    
                if($inVpn -eq "yes"){$useVpn = $true}
    
                if($localNetworks.contains($subnet)){
                    $subnets += [pscustomobject]@{
                        "localSubnet" = $subnet
                        "useVpn" = $useVpn
                    }
                }
    
            }
    
            #validate the entries in $networkSubnets agains the provided $subnets
            $body = [pscustomobject]@{
                "mode" = $mode
                "hubs" = @($hubs)
                "subnets" = @($subnets)
            }
        }
    }
    
    $request = Invoke-MrkRestMethod -Method PUT -ResourceID ('/networks/' + $networkId + '/siteToSiteVpn') -body $body
    
    return $request
    
}
function Set-Site2SiteVPN {
#Check which local subnets will be added to VPN tunnel
#Load VPN Hubs file
if(!(Test-Path .\VPN\Hubs.txt)){
    Set-ColoredLine $TxtBxOutput Red ('There are no available Hubs to spoke the network.' + 'Skipping VPN Operation.' + ' Please add a VPN hub to the organization and try again.' + "`r`n")
}
    
if (Test-Path .\VPN\Hubs.txt){
    #VPN Hubs are loaded in and configured from file:
    $VPNHubs = Get-Content .\VPN\Hubs.txt
}
    
if ($Chk1VLANVPN.Checked -eq $true){
    try{
        $1VLANSubnet = $TxtBxNet1Range.Text + $TxtCidr1.Text
        Set-ColoredLine $TxtBxOutput Black ('Adding S2S VLAN configuration for VLAN:' + $1VLANSubnet + '. Please Wait..' + "`r`n")
        $1VLANSubnet = $1VLANSubnet + ',' + 'yes'
        $result = Set-MrkNetworkS2sVpn -networkId $NetworkID -mode spoke -useDefaultRoute $false -vpnSubnets $1VLANSubnet -vpnHubs $VPNHubs[0] , $VPNHubs[1]
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Green ('VPN configuration complete.' + "`r`n")
        Start-Sleep -Seconds 0.25
    }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
}
    
if ($Chk2VLANVPN.Checked -eq $true){
    try{
        $2VLANSubnet = $TxtBxNet2Range.Text + $TxtCidr2.Text
        Set-ColoredLine $TxtBxOutput Black ('Adding S2S VLAN configuration for VLAN:' + $2VLANSubnet + '. Please Wait..' + "`r`n")
        $2VLANSubnet = $2VLANSubnet + ',' + 'yes'
        $result = Set-MrkNetworkS2sVpn -networkId $NetworkID -mode spoke -useDefaultRoute $false -vpnSubnets $2VLANSubnet -vpnHubs $VPNHubs[0] , $VPNHubs[1]
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Green ('VPN configuration complete.' + "`r`n")
        Start-Sleep -Seconds 0.25
    }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
}
    
if ($Chk3VLANVPN.Checked -eq $true){
    try{
        $3VLANSubnet = $TxtBxNet3Range.Text + $TxtCidr3.Text
        Set-ColoredLine $TxtBxOutput Black ('Adding S2S VLAN configuration for VLAN:' + $3VLANSubnet + '. Please Wait..' + "`r`n")
        $3VLANSubnet = $3VLANSubnet + ',' + 'yes'
        $result = Set-MrkNetworkS2sVpn -networkId $NetworkID -mode spoke -useDefaultRoute $false -vpnSubnets $3VLANSubnet -vpnHubs $VPNHubs[0] , $VPNHubs[1]
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Green ('VPN configuration complete.' + "`r`n")
        Start-Sleep -Seconds 0.25
    }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
}
}
#endregion
#region Network Creation Functions
function New-Network {
#Our Organization ID is selected using $ComboOrgName.text, a section (OrganizationIDs) sets the $OrgID based on the variable
#Update our Organization Info using the Set-Orgv0 Function in our global constant
Set-Orgv0
####################
    
####Check what our network types are, then add and create them in###
$NetTypes = ""
if ($optAppliance.Checked -eq $true){
$NetTypes += " appliance "
}
if ($optSwitch.Checked -eq $true){
$NetTypes += " switch "
}
if ($optWireless.Checked -eq $true){
$NetTypes += " wireless "
}
if ($optCG.Checked -eq $true){
$NetTypes += " cellularGateway "
}
if ($optCam.Checked -eq $true){
$NetTypes += " camera "
}
    
#Log our changes
Set-ColoredLine $TxtBxOutput Black ('Beginning to create our new network: ' + $TxtNetworkName.Text + "`r`n")
    
    
    
$body  = @{
        "name" = $TxtNetworkName.Text
        "type" = $NetTypes
        "tags" = $TxtBxNetTag.Text
        "timeZone" = $ComboTimeZone.Text
}
    try{
        #Send the Request with the pertinent information:
        $CreateOrganizationNetwork = $BaseURL + '/organizations/' + $OrgID + '/networks'
        $request = Invoke-RestMethod -Method POST -Uri $CreateOrganizationNetwork -Headers $headers -Body ($body | ConvertTo-Json)
        Set-ColoredLine $TxtBxOutput Black (($request | ConvertTo-Json) + "`r`n")
    
        $Global:NetworkID = $request.id
    
        #return the request
        Set-ColoredLine $TxtBxOutput Green ('Network Name: ' + $TxtNetworkName.Text + ' has been created.' + "`r`n")
            
        Start-Sleep -Seconds 2
    }
    catch{ 
        $RESTError = ParseErrorForResponseBody($_)
        if ($TxtNetworkName.Text -eq ""){
            Set-ColoredLine $TxtBxOutput Red ("You cannot create a network without a defined network name. Cannot Continue!" + "`r`n")
        }
        if ($TxtNetworkName.Text -ne ""){
            Get-CurrentLine
            $break
        }
    }
}
Function New-VLAN{
#This will be used for deleting the default VLAN, one network must always exist.
#First the Network is created based on the information gathered from the form.
#Now, Create the needed VLANS based on what has been properly added (It will skip any empty VLAN fields)
#This function creates all three VLAN entries as long as they have valid data, else they are skipped from processing (e.g. they were not needed)
    
#Enable VLANS on the new network before continuing
$EVLANURI = $BaseURL + '/networks/' + $NetworkID + '/vlansEnabledState'
$body = @{
    "enabled" = 'true'
}
    try{
        $result = Invoke-RestMethod -Method PUT -Uri  $EVLANURI -Headers $headers -Body ($body | ConvertTo-Json)
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    
#Begin logging the events in the Text Output
Set-ColoredLine $TxtBxOutput Black ('Preparing to create first VLAN entry' + "`r`n")
    
    
#VLAN 1 POST COMMAND
#First check if we even have valid entries, If there is a VLAN ID in place, we'll continue moving forward
if ($null -ne $V1VLAN.Text){
try{
    if ($ChkIDNS1.Checked -eq $true){
        try{
            $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V1VLAN.Text -name $TxtBx1VLANName.Text -subnet ($TxtBxNet1Range.Text + $TxtCIDR1.Text) -applianceIp $TxtAppIP1.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS1.Text, $TxtBxNS12.Text
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
        catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
    #Add DHCP options from the VLAN import if any exist
        if ($null -ne $Global:V1DHCPOpt){
            Set-ColoredLine $TxtBxOutput Black ('Adding DHCP options into the VLAN' + "`r`n")
            #VLAN 1
            try{
                $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V1VLAN.Text
                $body = @{
                    "dhcpOptions" = @(
                    foreach ($V1DHCPOpt in $Global:V1DHCPOpt){
                        @{
                            "code" = $V1DHCPOpt.code
                            "type" = $V1DHCPOpt.type
                            "value" = $V1DHCPOpt.value
                            }
                    }
                )
                }
                $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($body | ConvertTo-Json)
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            }
            catch{ 
                $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
        }
    #Add Any Fixed IP assignments if they exist
    if ($null -ne $Global:V1FIPs){
    #Wrap all our code and do this process until each entry in the hash table is filled with our new fixed ip assigments
    $FIPLoop = 0
    try{
        while ($FIPLoop -ne $V1FIPs.PSObject.Properties.Value.Count){
            #Set our Appliance IP as a variable we can manipulate
            $FixedSubnet = $TxtAppIP1.Text
            ##########TRIM CODE#########
            $trim = $true
                                                    while ($trim -eq $true){
        ####Grab our Last Octet number#####
            if ($FixedSubnet.EndsWith(".") -eq $false){
    $LastVars += $FixedSubnet.Substring($FixedSubnet.Length -1)
        }
        ####Grab our Last Octect number#####
        $FixedSubnet = $FixedSubnet.Substring(0,$FixedSubnet.Length-1)
                if ($FixedSubnet.EndsWith(".") -eq $true){
    #Stop the loop
    $trim = $false
        }
            }
            ##########TRIM CODE#########
            #Flip our LastVars, Then convert it to an integer
            #Convert to Array
            $LastVars = $LastVars.ToCharArray()
            #Flip
            [array]::Reverse($LastVars)
            #Convert back to a joined string
            $LastVars = -join($LastVars)
            $LastVars = [int]$LastVars
            #Set our LastVars to itself plus 1, then store THIS result as $LastUsedIP
            ###Add for our loop if we have more than one
if ($null -ne $Global:LastUsedIP){
While ($LastVars -le $Global:LastUsedIP){
if ($LastVars -le $Global:LastUsedIP){
$LastVars += 1
}
}
}
if ($null -eq $Global:LastUsedIP){
$LastVars += 1
}
$Global:LastUsedIP = $LastVars
#Finish off by joining our next available IP address
$NextFIPAssignment = $FixedSubnet + $LastVars
    
#Destroy any temp variables
$LastVars = $null
    
#Use our next FIP assignment and shim into the VLAN
#$backup = $V1FIPs
    
if ($null -eq $NextFIP){
$NextFIP = 0
}
    
$FIPEntries +=@{
    $V1FIPs.PSObject.Properties.Name[$NextFIP] =@{
    "ip" =$NextFIPAssignment
    "name" = $V1FIPs.PSObject.Properties.Value[$NextFIP].name
}
}
$NextFIP += 1
    
#Finish out our Hash Table
if ($NextFIP -eq $V1FIPs.PSObject.Properties.Value.Count){
$fixedIPAssignments =@{
    "fixedIpAssignments" = $FIPEntries
}
}
    
$FIPLoop += 1
}
    }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    ######Send our Custom Hashtable as JSON back into that VLAN
    try{     
        if ($null -ne $fixedIPAssignments){
            Set-ColoredLine $TxtBxOutput Black ('Adding our fixed IP Assignments into the VLAN' + "`r`n")
            #VLAN 1
            $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V1VLAN.Text
    
            $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($fixedIPAssignments | ConvertTo-Json)
    
            }
    }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    #Loop Cleanup
    $NextFIP = $null
    $fixedIPAssignments = $null
    $FIPEntries = $null
    }
    }
if ($ChkPDNS1.Checked -eq $true){
    try{
        $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V1VLAN.Text -name $TxtBx1VLANName.Text -subnet ($TxtBxNet1Range.Text + $TxtCIDR1.Text) -applianceIp $TxtAppIP1.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    #Add DHCP options from the VLAN import if any exist
    if ($null -ne $Global:V1DHCPOpt){
    try{
            Set-ColoredLine $TxtBxOutput Black ('Adding DHCP options into the VLAN' + "`r`n")
            #VLAN 1
            $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V1VLAN.Text
            $body = @{
            "dhcpOptions" = @(
                foreach ($V1DHCPOpt in $Global:V1DHCPOpt){
                        @{
                        "code" = $V1DHCPOpt.code
                        "type" = $V1DHCPOpt.type
                        "value" = $V1DHCPOpt.value
                        }
                    }
                )
        }
        $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($body | ConvertTo-Json)
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    }
    #Add Any Fixed IP assignments if they exist
    if ($null -ne $Global:V1FIPs){
    #Wrap all our code and do this process until each entry in the hash table is filled with our new fixed ip assigments
    $FIPLoop = 0
    try{
        while ($FIPLoop -ne $V1FIPs.PSObject.Properties.Value.Count){
            #Set our Appliance IP as a variable we can manipulate
            $FixedSubnet = $TxtAppIP1.Text
            ##########TRIM CODE#########
            $trim = $true
            while ($trim -eq $true){
                ####Grab our Last Octect number#####
                if ($FixedSubnet.EndsWith(".") -eq $false){
                    $LastVars += $FixedSubnet.Substring($FixedSubnet.Length -1)
                }
                ####Grab our Last Octect number#####
                $FixedSubnet = $FixedSubnet.Substring(0,$FixedSubnet.Length-1)
                if ($FixedSubnet.EndsWith(".") -eq $true){
                    #Stop the loop
                    $trim = $false
                }
            }
            ##########TRIM CODE#########
            #Flip our LastVars, Then convert it to an integer
            #Convert to Array
            $LastVars = $LastVars.ToCharArray()
            #Flip
            [array]::Reverse($LastVars)
            #Convert back to a joined string
            $LastVars = -join($LastVars)
            $LastVars = [int]$LastVars
            #Set our LastVars to itself plus 1, then store THIS result as $LastUsedIP
            ###Add for our loop if we have more than one
    if ($null -ne $Global:LastUsedIP){
        While ($LastVars -le $Global:LastUsedIP){
            if ($LastVars -le $Global:LastUsedIP){
                $LastVars += 1
            }
        }
    }
    if ($null -eq $Global:LastUsedIP){
        $LastVars += 1
    }
    $Global:LastUsedIP = $LastVars
    #Finish off by joining our next available IP address
    $NextFIPAssignment = $FixedSubnet + $LastVars
    
    #Destroy any temp variables
    $LastVars = $null
    
    #Use our next FIP assignment and shim into the VLAN
    #$backup = $V1FIPs
    
    if ($null -eq $NextFIP){
        $NextFIP = 0
    }
    
    $FIPEntries +=@{
        $V1FIPs.PSObject.Properties.Name[$NextFIP] =@{
            "ip" =$NextFIPAssignment
            "name" = $V1FIPs.PSObject.Properties.Value[$NextFIP].name
        }
    }
    $NextFIP += 1
    
    #Finish out our Hash Table
    if ($NextFIP -eq $V1FIPs.PSObject.Properties.Value.Count){
    $fixedIPAssignments =@{
        "fixedIpAssignments" = $FIPEntries
    }
    }
    
    $FIPLoop += 1
    }
    }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    ######Send our Custom Hashtable as JSON back into that VLAN
    if ($null -ne $fixedIPAssignments){
        try{
            Set-ColoredLine $TxtBxOutput Black ('Adding our fixed IP Assignments into the VLAN' + "`r`n")
            #VLAN 1
            $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V1VLAN.Text
    
            $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($fixedIPAssignments | ConvertTo-Json)
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
        catch{
            $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
    }
    
    #Loop Cleanup
    $NextFIP = $null
    $fixedIPAssignments = $null
    $FIPEntries = $null
    }
}
    #$null out our lastusedIP to avoid further conflicts
    $Global:LastUsedIP = $null
    Set-ColoredLine $TxtBxOutput Green ('Sent POST request to create first VLAN Entry' + "`r`n")
    Start-Sleep -Seconds 0.25
    }
catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
}
    }
#END First VLAN POST COMMAND
    
####Delete our default VLAN if we're not using VLAN 1#####
#This also requires that $global:HasDefaultVLAN was set to $true during the network creation portion
if ($global:HasDefaultVLAN -eq $true){
    if ($V1VLAN.Text -ne '1' -and $V2VLAN.Text -ne '1' -and $V3VLAN.Text -ne '1'){
        try{
            #First, delete the VLAN, then, set the global var to $false after removed
            $result = Remove-MrkNetworkVLAN -networkId $NetworkID -id '1'
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            $global:HasDefaultVLAN = $false
            Set-ColoredLine $TxtBxOutput Black ('Default VLAN has been removed as there was no VLAN 1 defined' + "`r`n")
        }
        catch{
            $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
    }
}
#######End Default VLAN Deletion##########################
    
    
$TxtBxOutput.Text += 'Preparing to create second VLAN entry' + "`r`n"
#VLAN 2 POST COMMAND
if ($null -ne $V2VLAN.Text){
    try{
    if ($ChkIDNS2.Checked -eq $true){
        $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V2VLAN.Text -name $TxtBx2VLANName.Text -subnet ($TxtBxNet2Range.Text + $TxtCIDR2.Text) -applianceIp $TxtAppIP2.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS2.Text, $TxtBxNS22.Text
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        # Add any DHCP Options if they exist
    if ($null -ne $Global:V2DHCPOpt){
        Set-ColoredLine $TxtBxOutput Black ('Adding DHCP options into the VLAN' + "`r`n")
        #VLAN 2
        $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V2VLAN.Text
        $body = @{
        "dhcpOptions" = @(
        foreach ($V2DHCPOpt in $Global:V2DHCPOpt){
            @{
            "code" = $V2DHCPOpt.code
            "type" = $V2DHCPOpt.type
            "value" = $V2DHCPOpt.value
            }
            }
            )
        }
        $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($body | ConvertTo-Json)
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
#Add Any Fixed IP assignments if they exist
if ($null -ne $Global:V2FIPs){
    #Wrap all our code and do this process until each entry in the hash table is filled with our new fixed ip assigments
    $FIPLoop = 0
        while ($FIPLoop -ne $V2FIPs.PSObject.Properties.Value.Count){
            #Set our Appliance IP as a variable we can manipulate
            $FixedSubnet = $TxtAppIP2.Text
            ##########TRIM CODE#########
            $trim = $true
            while ($trim -eq $true){
            ####Grab our Last Octect number#####
                if ($FixedSubnet.EndsWith(".") -eq $false){
                    $LastVars += $FixedSubnet.Substring($FixedSubnet.Length -1)
                }
            ####Grab our Last Octect number#####
            $FixedSubnet = $FixedSubnet.Substring(0,$FixedSubnet.Length-1)
                if ($FixedSubnet.EndsWith(".") -eq $true){
    #Stop the loop
    $trim = $false
        }
            }
            ##########TRIM CODE#########
            #Flip our LastVars, Then convert it to an integer
            #Convert to Array
            $LastVars = $LastVars.ToCharArray()
            #Flip
            [array]::Reverse($LastVars)
            #Convert back to a joined string
            $LastVars = -join($LastVars)
            $LastVars = [int]$LastVars
            #Set our LastVars to itself plus 1, then store THIS result as $LastUsedIP
            ###Add for our loop if we have more than one
            if ($null -ne $Global:LastUsedIP){
                While ($LastVars -le $Global:LastUsedIP){
                    if ($LastVars -le $Global:LastUsedIP){
                        $LastVars += 1
                    }
                }
            }
            if ($null -eq $Global:LastUsedIP){
                $LastVars += 1
            }
            $Global:LastUsedIP = $LastVars
            #Finish off by joining our next available IP address
            $NextFIPAssignment = $FixedSubnet + $LastVars
    
            #Destroy any temp variables
            $LastVars = $null
    
            #Use our next FIP assignment and shim into the VLAN
            #$backup = $V2FIPs
    
            if ($null -eq $NextFIP){
                $NextFIP = 0
            }
    
            $FIPEntries +=@{
                $V2FIPs.PSObject.Properties.Name[$NextFIP] =@{
                "ip" =$NextFIPAssignment
                "name" = $V2FIPs.PSObject.Properties.Value[$NextFIP].name
                }
            }
            $NextFIP += 1
    
            #Finish out our Hash Table
            if ($NextFIP -eq $V2FIPs.PSObject.Properties.Value.Count){
                $fixedIPAssignments =@{
                    "fixedIpAssignments" = $FIPEntries
                }
            }
    
            $FIPLoop += 1
        }
    
    ######Send our Custom Hashtable as JSON back into that VLAN
    if ($null -ne $fixedIPAssignments){
        Set-ColoredLine $TxtBxOutput Black ('Adding our fixed IP Assignments into the VLAN' + "`r`n")
        #VLAN 1
        $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V2VLAN.Text
        $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($fixedIPAssignments | ConvertTo-Json)
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            }
    
    #Loop Cleanup
    $NextFIP = $null
    $fixedIPAssignments = $null
    $FIPEntries = $null
    }
}
if ($ChkPDNS2.Checked -eq $true){
    $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V2VLAN.Text -name $TxtBx2VLANName.Text -subnet ($TxtBxNet2Range.Text + $TxtCIDR2.Text) -applianceIp $TxtAppIP2.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    #Add any DHCP Options if they exist
    if ($null -ne $Global:V2DHCPOpt){
        Set-ColoredLine $TxtBxOutput Black ('Adding DHCP options into the VLAN' + "`r`n")
        #VLAN 2
        $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V2VLAN.Text
        $body = @{
            "dhcpOptions" = @(
                foreach ($V2DHCPOpt in $Global:V2DHCPOpt){
                    @{
                        "code" = $V2DHCPOpt.code
                        "type" = $V2DHCPOpt.type
                        "value" = $V2DHCPOpt.value
                        }
                }
            )
        }
    $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($body | ConvertTo-Json)
    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    }
#Add Any Fixed IP assignments if they exist
if ($null -ne $Global:V2FIPs){
    #Wrap all our code and do this process until each entry in the hash table is filled with our new fixed ip assigments
    $FIPLoop = 0
        while ($FIPLoop -ne $V2FIPs.PSObject.Properties.Value.Count){
            #Set our Appliance IP as a variable we can manipulate
            $FixedSubnet = $TxtAppIP2.Text
            ##########TRIM CODE#########
            $trim = $true
                                                    while ($trim -eq $true){
        ####Grab our Last Octect number#####
            if ($FixedSubnet.EndsWith(".") -eq $false){
    $LastVars += $FixedSubnet.Substring($FixedSubnet.Length -1)
        }
        ####Grab our Last Octect number#####
        $FixedSubnet = $FixedSubnet.Substring(0,$FixedSubnet.Length-1)
                if ($FixedSubnet.EndsWith(".") -eq $true){
    #Stop the loop
    $trim = $false
        }
            }
            ##########TRIM CODE#########
            #Flip our LastVars, Then convert it to an integer
            #Convert to Array
            $LastVars = $LastVars.ToCharArray()
            #Flip
            [array]::Reverse($LastVars)
            #Convert back to a joined string
            $LastVars = -join($LastVars)
            $LastVars = [int]$LastVars
            #Set our LastVars to itself plus 1, then store THIS result as $LastUsedIP
            ###Add for our loop if we have more than one
if ($null -ne $Global:LastUsedIP){
While ($LastVars -le $Global:LastUsedIP){
if ($LastVars -le $Global:LastUsedIP){
$LastVars += 1
}
}
}
if ($null -eq $Global:LastUsedIP){
$LastVars += 1
}
$Global:LastUsedIP = $LastVars
#Finish off by joining our next available IP address
$NextFIPAssignment = $FixedSubnet + $LastVars
    
#Destroy any temp variables
$LastVars = $null
    
#Use our next FIP assignment and shim into the VLAN
#$backup = $V2FIPs
    
if ($null -eq $NextFIP){
$NextFIP = 0
}
    
$FIPEntries +=@{
    $V2FIPs.PSObject.Properties.Name[$NextFIP] =@{
    "ip" =$NextFIPAssignment
    "name" = $V2FIPs.PSObject.Properties.Value[$NextFIP].name
}
}
$NextFIP += 1
    
#Finish out our Hash Table
if ($NextFIP -eq $V2FIPs.PSObject.Properties.Value.Count){
$fixedIPAssignments =@{
    "fixedIpAssignments" = $FIPEntries
}
}
    
$FIPLoop += 1
}
    
    ######Send our Custom Hashtable as JSON back into that VLAN
        if ($null -ne $fixedIPAssignments){
            Set-ColoredLine $TxtBxOutput Black ('Adding our fixed IP Assignments into the VLAN' + "`r`n")
            #VLAN 1
            $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V2VLAN.Text
    
            $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($fixedIPAssignments | ConvertTo-Json)
    
            }
    
    #Loop Cleanup
    $NextFIP = $null
    $fixedIPAssignments = $null
    $FIPEntries = $null
    }
}
    #$null out our lastusedIP to avoid further conflicts
    $Global:LastUsedIP = $null
    Set-ColoredLine $TxtBxOutput Green ('Sent POST request to create second VLAN Entry' + "`r`n")
    Start-Sleep -Seconds 0.25
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
}
#END Second VLAN POST COMMAND
    
$TxtBxOutput.Text += 'Preparing to create third VLAN entry' + "`r`n"
#VLAN 3 POST COMMAND
if ($null -ne $V3VLAN.Text){
try{
    if ($ChkIDNS3.Checked -eq $true){
        $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V3VLAN.Text -name $TxtBx3VLANName.Text -subnet ($TxtBxNet3Range.Text + $TxtCIDR3.Text) -applianceIp $TxtAppIP3.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS3.Text, $TxtBxNS33.Text
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    if ($null -ne $Global:V3DHCPOpt){
        Set-ColoredLine $TxtBxOutput Black ('Adding DHCP options into the VLAN' + "`r`n")
        #VLAN 3
        $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V3VLAN.Text
        $body = @{
            "dhcpOptions" = @(
                foreach ($V3DHCPOpt in $Global:V3DHCPOpt){
                        @{
                        "code" = $V3DHCPOpt.code
                        "type" = $V3DHCPOpt.type
                        "value" = $V3DHCPOpt.value
                        }
                    }
                )
        }
    $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($body | ConvertTo-Json)
    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    }
    #Add Any Fixed IP assignments if they exist
    if ($null -ne $Global:V3FIPs){
    #Wrap all our code and do this process until each entry in the hash table is filled with our new fixed ip assigments
    $FIPLoop = 0
        while ($FIPLoop -ne $V3FIPs.PSObject.Properties.Value.Count){
            #Set our Appliance IP as a variable we can manipulate
            $FixedSubnet = $TxtAppIP3.Text
            ##########TRIM CODE#########
            $trim = $true
            while ($trim -eq $true){
            ####Grab our Last Octect number#####
                if ($FixedSubnet.EndsWith(".") -eq $false){
                    $LastVars += $FixedSubnet.Substring($FixedSubnet.Length -1)
                }
            ####Grab our Last Octect number#####
            $FixedSubnet = $FixedSubnet.Substring(0,$FixedSubnet.Length-1)
                if ($FixedSubnet.EndsWith(".") -eq $true){
                    #Stop the loop
                    $trim = $false
                }
            }
            ##########TRIM CODE#########
            #Flip our LastVars, Then convert it to an integer
            #Convert to Array
            $LastVars = $LastVars.ToCharArray()
            #Flip
            [array]::Reverse($LastVars)
            #Convert back to a joined string
            $LastVars = -join($LastVars)
            $LastVars = [int]$LastVars
            #Set our LastVars to itself plus 1, then store THIS result as $LastUsedIP
            ###Add for our loop if we have more than one
            if ($null -ne $Global:LastUsedIP){
                While ($LastVars -le $Global:LastUsedIP){
                    if ($LastVars -le $Global:LastUsedIP){
                        $LastVars += 1
                    }
                }
            }
            if ($null -eq $Global:LastUsedIP){
                $LastVars += 1
            }
            $Global:LastUsedIP = $LastVars
            #Finish off by joining our next available IP address
            $NextFIPAssignment = $FixedSubnet + $LastVars
    
            #Destroy any temp variables
            $LastVars = $null
    
            #Use our next FIP assignment and shim into the VLAN
            #$backup = $V3FIPs
    
            if ($null -eq $NextFIP){
                $NextFIP = 0
            }
    
            $FIPEntries +=@{
                $V3FIPs.PSObject.Properties.Name[$NextFIP] =@{
                    "ip" =$NextFIPAssignment
                    "name" = $V3FIPs.PSObject.Properties.Value[$NextFIP].name
                }
            }
            $NextFIP += 1
    
            #Finish out our Hash Table
                if ($NextFIP -eq $V3FIPs.PSObject.Properties.Value.Count){
                    $fixedIPAssignments =@{
                        "fixedIpAssignments" = $FIPEntries
                    }
                }
    
            $FIPLoop += 1
            }
    
        ######Send our Custom Hashtable as JSON back into that VLAN
        if ($null -ne $fixedIPAssignments){
            Set-ColoredLine $TxtBxOutput Black ('Adding our fixed IP Assignments into the VLAN' + "`r`n")
            #VLAN 3
            $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V3VLAN.Text
    
            $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($fixedIPAssignments | ConvertTo-Json)
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            }
    
    #Loop Cleanup
    $NextFIP = $null
    $fixedIPAssignments = $null
    $FIPEntries = $null
    }
    }
if ($ChkPDNS3.Checked -eq $true){
    $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V3VLAN.Text -name $TxtBx3VLANName.Text -subnet ($TxtBxNet3Range.Text + $TxtCIDR3.Text) -applianceIp $TxtAppIP3.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    if ($null -ne $Global:V3DHCPOpt){
        Set-ColoredLine $TxtBxOutput Black ('Adding DHCP options into the VLAN' + "`r`n")
        #VLAN 3
        $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V3VLAN.Text
        $body = @{
            "dhcpOptions" = @(
                foreach ($V3DHCPOpt in $Global:V3DHCPOpt){
                        @{
                        "code" = $V3DHCPOpt.code
                        "type" = $V3DHCPOpt.type
                        "value" = $V3DHCPOpt.value
                        }
                    }
                )
        }
        $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($body | ConvertTo-Json)
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    }
    #Add Any Fixed IP assignments if they exist
    if ($null -ne $Global:V3FIPs){
        #Wrap all our code and do this process until each entry in the hash table is filled with our new fixed ip assigments
        $FIPLoop = 0
        while ($FIPLoop -ne $V3FIPs.PSObject.Properties.Value.Count){
            #Set our Appliance IP as a variable we can manipulate
            $FixedSubnet = $TxtAppIP3.Text
            ##########TRIM CODE#########
            $trim = $true
            while ($trim -eq $true){
            ####Grab our Last Octect number#####
                if ($FixedSubnet.EndsWith(".") -eq $false){
                    $LastVars += $FixedSubnet.Substring($FixedSubnet.Length -1)
                }
            ####Grab our Last Octect number#####
            $FixedSubnet = $FixedSubnet.Substring(0,$FixedSubnet.Length-1)
                if ($FixedSubnet.EndsWith(".") -eq $true){
                    #Stop the loop
                    $trim = $false
                }
            }
            ##########TRIM CODE#########
            #Flip our LastVars, Then convert it to an integer
            #Convert to Array
            $LastVars = $LastVars.ToCharArray()
            #Flip
            [array]::Reverse($LastVars)
            #Convert back to a joined string
            $LastVars = -join($LastVars)
            $LastVars = [int]$LastVars
            #Set our LastVars to itself plus 1, then store THIS result as $LastUsedIP
            ###Add for our loop if we have more than one
        if ($null -ne $Global:LastUsedIP){
            While ($LastVars -le $Global:LastUsedIP){
                if ($LastVars -le $Global:LastUsedIP){
                    $LastVars += 1
                }
            }
        }
        if ($null -eq $Global:LastUsedIP){
            $LastVars += 1
        }
        $Global:LastUsedIP = $LastVars
        #Finish off by joining our next available IP address
        $NextFIPAssignment = $FixedSubnet + $LastVars
    
        #Destroy any temp variables
        $LastVars = $null
    
        #Use our next FIP assignment and shim into the VLAN
        #$backup = $V3FIPs
    
        if ($null -eq $NextFIP){
            $NextFIP = 0
        }
    
        $FIPEntries +=@{
                $V3FIPs.PSObject.Properties.Name[$NextFIP] =@{
                "ip" =$NextFIPAssignment
                "name" = $V3FIPs.PSObject.Properties.Value[$NextFIP].name
            }
        }
        $NextFIP += 1
    
        #Finish out our Hash Table
        if ($NextFIP -eq $V3FIPs.PSObject.Properties.Value.Count){
            $fixedIPAssignments =@{
                "fixedIpAssignments" = $FIPEntries
            }
        }
    
        $FIPLoop += 1
        }
    
        ######Send our Custom Hashtable as JSON back into that VLAN
        if ($null -ne $fixedIPAssignments){
            Set-ColoredLine $TxtBxOutput Black ('Adding our fixed IP Assignments into the VLAN' + "`r`n")
            #VLAN 3
            $GetCurVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V3VLAN.Text
    
            $result = Invoke-Restmethod -Method PUT -Uri $GetCurVLAN -Headers $headers -Body ($fixedIPAssignments | ConvertTo-Json)
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            }
    
        #Loop Cleanup
        $NextFIP = $null
        $fixedIPAssignments = $null
        $FIPEntries = $null
        }
}
#$null out our lastusedIP to avoid further conflicts
$Global:LastUsedIP = $null
Set-ColoredLine $TxtBxOutput Green ('Sent POST request to create third VLAN Entry' + "`r`n")
Start-Sleep -Seconds 0.25
}
catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
}
}
#END Third VLAN POST COMMAND
    
}
}
Function Claim-NetDevice{
Set-Orgv1
    
#Begin logging the events in the Text Output
Set-ColoredLine $TxtBxOutput Black ('Attempting to add devices into the network, please wait' + "`r`n")
    
#Build out our loop
$serialnum = 0
do {
    if ($null -ne $TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]){
        try{
            Set-ColoredLine $TxtBxOutput Black ('Adding ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) +  ' into the network, please wait' + "`r`n")
            $result = New-MrkDevice -Networkid $NetworkID -serial ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum])
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            Set-ColoredLine $TxtBxOutput Green ('Device: ' +  ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ', was added into the network.' + "`r`n")
                #Check if Tags have been entered, and if they need to be added
                if (($TxtBxDevTag.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Tags: ' + ($TxtBxDevTag.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) +  ' into the network, please wait' + "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + $TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]
                        $tags = ($TxtBxDevTag.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                            
                        $body = @{
                            "tags" =@( $tags.Split("") )
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device tags on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' have been added.' + "`r`n")
                        $tags = $null
                    }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
                #Check if Notes have been entered, and if they need to be added
                if(($TxtBxDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Notes: ' + ($TxtBxDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) + ' to device: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) +  "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum])
                        $body = @{
                            "notes" = ($TxtBxDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device notes on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' have been added.' + "`r`n")
                        }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
                #Check if addresses have been entered, and if they need to be added
                if (($TxtBxDevAddress.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Address: ' + ($TxtBxDevAddress.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) +  ' into the network, please wait' + "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + $TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]
                        $body = @{
                            "address" = ($TxtBxDevAddress.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device address on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' has been added.' + "`r`n")
                    }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
                #Check if names have been entered, and if they need to be added
                if (($TxtBxDevName.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Name: ' + ($TxtBxDevName.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) +  ' into the network, please wait' + "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + $TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]
                        $body = @{
                            "name" = ($TxtBxDevName.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device name on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' has been added.' + "`r`n")
                    }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
        }
        catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
    
    }
    $serialnum += 1
    
}while ($serialnum -lt $TxtBxSD.Text.Split("").Where({ $_ -ne ""}).Count)
$serialnum = 0
    
Set-Orgv0
    
if ($TxtBxSD.Text -eq ''){
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('No devices were added to MNCT. Skipping Network device claim procedure' + "`r`n")
}
    
}
#endregion

#endregion
############FUNCTIONS###################
    
#This Region defines all the GUI action buttons and configuration
#region GUIActions
#Import/Update Organization Info
$BtnGetOrganizations.Add_Click({
    $OrgInfo = Invoke-RestMethod -Method GET -Uri 'https://api.meraki.com/api/v0/organizations' -Headers $headers
        $OrgNum = 0
    foreach ($Org in $OrgInfo){
        $OrgNum += 1
        if (!(Test-Path "$PWD\Organizations\$OrgNum.txt")){
            New-Item "$PWD\Organizations\$OrgNum.txt"
            $body =@{
                "id" = $Org.id
                "name" = $Org.name
                "url" = $Org.url.Substring(0,$Org.url.IndexOf("/o")) + "/api/v0"
                "urlv1" = $Org.url.Substring(0,$Org.url.IndexOf("/o")) + "/api/v1"
            }
            $body | ConvertTo-Json >> "$PWD\Organizations\$OrgNum.txt"
        }
    }
    $OrgInfo = $null
    $OrgNum = $null
    $body = $null
})

#Clear all FW Rules
$BtnClearFWRules.Add_Click({
$global:json = ''
$global:L7json = ''
$jsonrulelogging = ''
$L7jsonrulelogging = ''
Set-ColoredLine $TxtBxOutput Black ('L3 and L7 Firewall rules are now cleared!' + "`r`n")
#Update the Firewall Configuration in the Overview:
$TxtBxFWRules.Text = 'L3 FW Rules:' + "`r`n" + $jsonrulelogging + "`r`n" + 'L7 FW Rules:' + "`r`n"  + $L7jsonrulelogging
})
    
#Upload Firewall Rules, sets result to $FirewallRules Variable which is then passed when creating the network
$BtnFWRules.Add_Click({
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'FirewallRules (*.txt)|*.txt'
    Title = 'Select Firewall ruleset'}
$FileBrowser.ShowDialog()
if($FileBrowser.FileName -ne ''){
$FirewallRules = $FileBrowser.FileName
$FirewallRulesContent = Get-Content $FirewallRules
###Separate this, run as rules
$global:json = $FirewallRulesContent | ConvertFrom-Json
    
#Create Logging in GUI
$jsonrulelogging = foreach ($json in $global:json){$json.comment + "`r`n"}
$L7jsonrulelogging = foreach ($L7json in $global:L7json){$L7json.value.name + "`r`n"}
    
Set-ColoredLine $TxtBxOutput Black ('The following rules will be added to the new network in this order:' + "`r`n" + $jsonrulelogging)
    
#Update the Firewall Configuration in the Overview:
$TxtBxFWRules.Text = 'L3 FW Rules:' + "`r`n" + $jsonrulelogging + "`r`n" + 'L7 FW Rules:' + "`r`n"  + $L7jsonrulelogging
}
})
    
$BtnFW7Rules.Add_Click({
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'FirewallRules (*.txt)|*.txt'
    Title = 'Select Firewall ruleset'}
$FileBrowser.ShowDialog()
if($FileBrowser.FileName -ne ''){
$L7FirewallRules = $FileBrowser.FileName
$L7FirewallRulesContent = Get-Content $L7FirewallRules
###Separate this, run as rules
$global:L7json = $L7FirewallRulesContent | ConvertFrom-Json
    
#Create Logging in GUI
$jsonrulelogging = foreach ($json in $global:json){$json.comment + "`r`n"}
$L7jsonrulelogging = foreach ($L7json in $global:L7json){$L7json.value.name + "`r`n"}
    
Set-ColoredLine $TxtBxOutput Black ('The following rules will be added to the new network in this order:' + "`r`n" + $L7jsonrulelogging)
    
#Update the Firewall Configuration in the Overview:
$TxtBxFWRules.Text = 'L3 FW Rules:' + "`r`n" + $jsonrulelogging + "`r`n" + 'L7 FW Rules:' + "`r`n"  + $L7jsonrulelogging
    
}
})
    
#Removes a device from the selected network
$BtnRmNetDevice.Add_Click({
    
#Define our Organization List
Set-Orgv0
    
Get-NetworkID
    
#Begin logging the events in the Text Output
Set-ColoredLine $TxtBxOutput Black ('Attempting to remove devices from the network, please wait' + "`r`n")
    
#Build out our loop
$serialnum = 0
do {
    if ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum] -ne ''){
        try{
            Set-ColoredLine $TxtBxOutput Black ('Removing ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) +  ' from the network, please wait' + "`r`n")
            $result = Remove-MrkDevice -Networkid $NetworkID -serial ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum])
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            Set-ColoredLine $TxtBxOutput Green ('Device: ' +  ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ', was removed from the network.' + "`r`n")
        }
        catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
    
    }
    $serialnum += 1
    
}while ($serialnum -lt $TxtBxSD.Text.Split("").Where({ $_ -ne ""}).Count)
$serialnum = 0
    
Set-ColoredLine $TxtBxOutput Green ('Device removal procedure completed.' + "`r`n")
    
})
    
#Log When Network Timezone Changed
$ComboTimeZone.Add_TextChanged({
    Set-ColoredLine $TxtBxOutput Black ('Timezone set for provisioned network is now: ' + $ComboTimeZone.Text)
})
    
####Update the Network Lists for both Creation and Import#####
$ComboOrgName.Add_TextChanged({
#Pre-Gathered API IDs for the Orgs, sets on ComboBox Changes
Set-Orgv0
    
    Set-ColoredLine $TxtBxOutput Black ('Organization name changed to: ' + $ComboOrgName.text  + '.' +  "`r`n" + 'Org ID now equals: ' + $OrgID + "`r`n" + '$BaseURL now is:' + $BaseURL + "`r`n")
        
#Combo Org Name Changes(Import of all Network Names in an org into net name list)
    
    try{
        #Grab our network ID for the new network
        $GetNetNameIndex = $BaseURL + '/organizations/' + $OrgID + '/networks'
        $request = Invoke-RestMethod -Method GET -Uri $GetNetNameIndex -Headers $headers
        $NetworkNameIndex = ($request).Name
        $TxtNetworkName.Items.Clear()
        $TxtNetworkName.Items.AddRange(($NetworkNameIndex | Sort-Object))
    
        #Add this List to our bulk network apply Textbox as well
        $NetListImports = ($NetworkNameIndex | Sort-Object)
        $TxtBxNetList.Text = ''
        foreach ($NetListImports in $NetListImports){
        $TxtBxNetList.Text = $TxtBxNetList.Text + $NetListImports
        $TxtBxNetList.Text += "`r`n"
        }
        #Clear the current network name as its likely no longer part of that org.
        $TxtNetworkName.Text = ''
        $lblNetworkNameInfo.Text = "Network Name (" + $TxtNetworkName.Items.Count + " Total)"
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
})
$ComboOrgImport.Add_TextChanged({
Set-OrgImportv0
    
    Set-ColoredLine $TxtBxOutput Black ('Import Organization name changed to: ' + $ComboOrgImport.text  + '.' +  "`r`n" + 'Import Org ID now equals: ' + $OrgID + "`r`n" + '$BaseURL now is:' + $BaseURL + "`r`n")
        
    try{
        #Grab our network ID for the new network
        $GetNetNameImportIndex = $BaseURL + '/organizations/' + $OrgID + '/networks'
        $request = Invoke-RestMethod -Method GET -Uri $GetNetNameImportIndex -Headers $headers
        $NetworkImportIndex = ($request).Name
        $TxBxNetNameImport.Items.Clear()
        $TxBxNetNameImport.Items.AddRange(($NetworkImportIndex | Sort-Object))
        #Clear the current network import name as its likely no longer part of that org.
        $TxBxNetNameImport.Text = ''
        $LblNetTagName.Text = "Network Name (" + $TxBxNetNameImport.Items.Count + ") Total)"
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
})
    
$BtnSubnetAvailibility.Add_Click({
if (Test-Path -Path ('.\RouteTable.txt')){
$Routetable = (Get-Content ('.\RouteTable.txt'))
    
$Subnet1 = $TxtBxNet1Range.Text + $TxtCidr1.Text
$Subnet2 = $TxtBxNet2Range.Text + $TxtCidr2.Text
$Subnet3 = $TxtBxNet3Range.Text + $TxtCidr3.Text
    
#Check the first VLAN entry submission
if (!([string]::IsNullOrWhitespace($Subnet1))){
if ($Routetable | Select-String -Pattern $Subnet1){
    Set-ColoredLine $TxtBxOutput Red ('THIS ROUTE:' + $Subnet1 + "`r`n" + 'IS IN USE IN THE VPN, ALLOWING USE IN THE VPN TUNNEL WILL CAUSE ADDRESSING CONFLICT.' + "`r`n" + "`r`n")
}else {
    Set-ColoredLine $TxtBxOutput Black ('THIS ROUTE:' + $Subnet1 + "`r`n" +  'can be used without route table conflict' + "`r`n" + "`r`n")
}
}
    
    
#Check the second VLAN entry submission
if (!([string]::IsNullOrWhitespace($Subnet2))){
if  ($Routetable |Select-String -Pattern $Subnet2){
    Set-ColoredLine $TxtBxOutput Red ('THIS ROUTE:'  + $Subnet2 + "`r`n" +  'IS IN USE IN THE VPN, ALLOWING USE IN THE VPN TUNNEL WILL CAUSE ADDRESSING CONFLICT.' + "`r`n" + "`r`n")
}else {
    Set-ColoredLine $TxtBxOutput Black ('THIS ROUTE:'  +  $Subnet2 + "`r`n" + 'can be used without route table conflict' + "`r`n" + "`r`n")
}
}
    
#Check the third VLAN entry submission
if (!([string]::IsNullOrWhitespace($Subnet3))){
if ($Routetable |Select-String -Pattern $Subnet3){
    Set-ColoredLine $TxtBxOutput Red ('THIS ROUTE:' + $Subnet3 + "`r`n" + 'IS IN USE IN THE VPN, ALLOWING USE IN THE VPN TUNNEL WILL CAUSE ADDRESSING CONFLICT.' + "`r`n" + "`r`n")
} else {
    Set-ColoredLine $TxtBxOutput Black ('THIS ROUTE:' + $Subnet3 + "`r`n" + 'can be used without route table conflict' + "`r`n" + "`r`n")
}
}
}
else {Set-ColoredLine $TxtBxOutput Black ('FILE NOT FOUND IN ROOT DIRECTORY: ' + "$pwd\RouteTable.txt")}
})
    
#Bulk Import Update Checkbox Options
$ChkUpdateList.Add_CheckedChanged({
if($ChkUpdateList.Checked -eq $true){
#Disable and uncheck Devices and Device Notes
$optDevices.Checked = $false
$optDevNote.Checked = $false
$optDevices.enabled = $false
$optDevNote.enabled = $false
$optDeviceName.enabled = $false
$optDeviceName.Checked = $false
if ($optNName.Checked -eq $true){
$RadNameOverwrite.Checked = $false
$RadNameOverwrite.enabled = $false
}
$TxtBxNetListApply.enabled = $true
}
    
if($ChkUpdateList.Checked -eq $false){
$optDevices.enabled = $true
$optDevNote.enabled = $true
$TxtBxNetListApply.enabled = $false
if ($optNName.Checked -eq $true){
$RadNameOverwrite.enabled = $true
}
}
})
    
#Check Changes for Overwrite and Append options for Net Tag updates
$RadTagOverWrite.Add_CheckedChanged({
if($optNTag.Checked -eq $true){
if($RadTagOverWrite.Checked -eq $true){
$RadTagAppend.Checked = $false
}
if($RadTagOverWrite.Checked -eq $false){
$RadTagAppend.Checked = $true
}
}
else{
$RadTagOverWrite.Checked = $false}
    
})
$RadTagAppend.Add_CheckedChanged({
if($optNTag.Checked -eq $true){
if($RadTagAppend.Checked -eq $true){
$RadTagOverWrite.Checked = $false
}
if($RadTagAppend.Checked -eq $false){
$RadTagOverWrite.Checked = $true
}
}
else{
$RadTagAppend.Checked = $false
}
})
    
$RadNameOverwrite.Add_CheckedChanged({
if ($RadNameOverwrite.Checked -eq $true){
    $RadNameEnd.Checked = $false
    $RadNameFront.Checked = $false
    $RadNameEnd.enabled = $false
    $RadNameFront.enabled = $false
}
if ($RadNameOverwrite.Checked -eq $false){
    $RadNameEnd.enabled = $true
    $RadNameFront.enabled = $true
}
})
$RadNameAppend.Add_CheckedChanged({
if ($RadNameAppend.Checked -eq $true){
    $RadNameEnd.enabled = $true
    $RadNameFront.enabled = $true
}
})
    
#Check Changes for the Net Tag checkbox for updates
$optNTag.Add_CheckedChanged({
#Default it to check overwrite
if($optNTag.Checked -eq $true){
$RadTagAppend.Checked = $true
}
else{
$RadTagOverWrite.Checked = $false
$RadTagAppend.Checked = $false
}
})
    
#Check for $OptNName Changes
$optNName.Add_CheckedChanged({
#Uncheck both the overwrite and append, set our name change txtbx disabled
if ($optNName.Checked -eq $false){
$RadNameOverwrite.Checked = $false
$RadNameAppend.Checked = $false
$TxtBxNameChange.enabled = $false
$RadNameOverwrite.enabled = $false
$RadNameAppend.enabled = $false
$RadNameEnd.enabled = $false
$RadNameFront.enabled = $false
}
    
if ($optNName.Checked -eq $true){
$TxtBxNameChange.enabled = $true
$RadNameOverwrite.enabled = $true
$RadNameAppend.enabled = $true
}
})
    
#Launch the API Builder
$BtnAPIBuilder.Add_Click({
.\APIBuilder\APIBuilder.ps1
    
})
    
#Enable/disable $optFWRTop and $optFWRBottom when checked or unchecked
$optFWR.Add_CheckedChanged({
if($optFWR.Checked -eq $true){
$optFWRTop.enabled = $true
$optFWRBottom.enabled = $true
$optFWRBottom.Checked = $true
$optFWRRemove.enabled = $true
}
if($optFWR.Checked -eq $false){
$optFWRTop.enabled = $false
$optFWRBottom.enabled = $false
$optFWRRemove.enabled = $false
$optFWRTop.Checked = $false
$optFWRBottom.Checked = $false
$optFWRRemove.Checked = $false
}
})
    
$BtnSBCU.Add_Click({
if ($TxBxNetNameImport.Text -ne ''){
    #Variable passes
    $Global:SwitchNetImport = $TxBxNetNameImport.Text
    Set-OrgImportv0
    
    .\SBCU\SBCU.ps1
}
    
if ($TxBxNetNameImport.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error. No network selected in the import section of the tool.' + "`r`n")
    Set-ColoredLine $TxtBxOutput Red ('Please specify a network that has a switch to open SBCU.' + "`r`n")
}
    
})
    
#Auto Update our Route Table
$BtnUpdateRouteTable.Add_Click({
Set-Orgv1
    try{
        $GetVPNRoutes = $BaseURL + '/organizations/' + $OrgID + '/appliance/vpn/statuses'
        $VPNRouteTable = Invoke-RestMethod -Method GET -Uri $GetVPNRoutes -Headers $headers | ConvertTo-Json -Depth 3
        $VPNRouteTable >> JSONRouteExport.txt
        $VPNRouteTable = Get-Content .\JSONRouteExport.txt | ConvertFrom-Json
        Remove-Item .\RouteTable.txt
        $VPNRouteTable.value.exportedSubnets.subnet >> RouteTable.txt
        Remove-Item .\JSONRouteExport.txt
    
        Set-ColoredLine $TxtBxOutput Black ("Reading stored routes in RouteTable.txt..." + "`r`n")
        Set-ColoredLine $TxtBxOutput Green ('The following routes from VPN route table have been uploaded into MNCT!' + "`r`n")
    
        foreach ($route in $VPNRouteTable.value){
            Set-ColoredLine $TxtBxOutput Black ($route.networkName +  "`r`n")
            Set-ColoredLine $TxtBxOutput Black ([string]$route.exportedSubnets.subnet +  "`r`n")
        }
    }
    catch{
        $RESTError = ParseErrorForResponseBody($_)
        Set-ColoredLine $TxtBxOutput Red ([string]$RESTError.errors + "`r`n")
    }
    
Set-Orgv0
    
})
    
#Import Fixed IP Data
$BtnImportFIPs.Add_Click({
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'Static Devices (*.csv)|*.csv'
    Title = 'Select Bulk Static Devices'}
$FileBrowser.ShowDialog()
if($FileBrowser.FileName -ne ''){
    $Global:FIPData = Get-Content -Raw $FileBrowser.FileName | ConvertFrom-Csv
    
    Set-ColoredLine $TxtBxOutput Black ("Reading stored data in" + $FileBrowser.FileName + "`r`n")
    Set-ColoredLine $TxtBxOutput Black ('Fixed IP Assignment data has been uploaded into MNCT!' + "`r`n")
}
})
    
#Import/Update Fixed IP Data
$BtnUpdateFIPs.Add_Click({
    
Set-ColoredLine $TxtBxOutput Black ("Sending Fixed IP assignments into Network. Please wait." + "`r`n")
    
Set-Orgv0
    try{
        Get-NetworkID
    
        foreach ($FIPs in $FIPData){
            if($FIPs -ne ''){
                
        $BodyMain +=@{
            $FIPs.MAC = @{
                    "ip" = $FIPs.IPv4address
                    "name" = $FIPs.Description
                        }
                    }
    
            #End of Loop
            }
        }
    
        $IPAssignments +=@{
                "fixedIpAssignments" = $BodyMain     
                }
    
        #Send the Assignments as PUT
        $IPAssignmentURI = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $TxtBxVlanID.Text
        $result = Invoke-RestMethod -Method PUT -Uri $IPAssignmentURI -Headers $headers -Body ($IPAssignments | ConvertTo-Json -Depth 3)
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Green ('Fixed IP Assignment data has been sent from MNCT!' + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        if ($null -eq $BodyMain){
            Set-ColoredLine $TxtBxOutput Red ("There was no data imported to add to the network. Cannot continue!" + "`r`n")
        }
        if ($null -ne $BodyMain){
            Get-CurrentLine
            $break
        }
    }
})
    
#Update Appliance Ports
$BtnUpdateAppPorts.Add_Click({
if ($TxtNetworkName.Text -ne ''){
#Read our Import Org Combo Box for the Org ID
Set-Orgv0
    try{
        Get-NetworkID
        #Grab the network ID of the selected network
        $AppliancePorts = 1 , 2 , 3 , 4
    
        #For each port
        foreach ($port in $AppliancePorts){
            $portData = Get-Content .\Appliance\$port.txt
            $GetAppPorts = $BaseURL + '/networks/' + $NetworkID + '/appliancePorts/' + $port
            $result = Invoke-RestMethod -Method PUT -Uri $GetAppPorts -Headers $headers -Body $portData
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            Start-Sleep -Seconds 0.25
        }
        Set-ColoredLine $TxtBxOutput Green ('Appliance Ports have been updated!' + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
}
if ($TxtNetworkName.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
}
})
    
#region Task Scheduler
$optTSEnabled.Add_CheckedChanged({
if ($optTSEnabled.Checked -eq $true){
Set-ColoredLine $TxtBxOutput Black ("Scheduled Tasks now enabled." + "`r`n")
}
if ($optTSEnabled.Checked -eq $false){
Set-ColoredLine $TxtBxOutput Black ("Scheduled Tasks are now disabled." + "`r`n")
Set-ColoredLine $TxtBxOutput Black ("Killing all Scheduled Tasks" + "`r`n")
$RSpaces = Get-Runspace
foreach ($RS in $RSpaces){
    if ($RS.id -gt 1){ 
        $RS.dispose()
        Set-ColoredLine $TxtBxOutput Black ("Killed Task: " + $RS.Name + "`r`n")
    }
}
#Clear the Task List
$ComboTasks.Items.Clear()
    
Set-ColoredLine $TxtBxOutput Black ("Scheduled Tasks have been killed." + "`r`n")
}
})
    
$BtnKillTask.Add_Click({
$RSpaces = Get-Runspace
($RSpaces | Where-Object {$_.Name -match $ComboTasks.Text}).dispose()
'debug'
#Update ComboTasks with the new task information
$RSpaces = Get-Runspace
$ComboTasks.Items.Clear()
foreach ($Task in $RSpaces){
    try
    {
        $ComboTasks.Items.AddRange(((($Task | Where-Object {$_.id -ne 1}).Name | Sort-Object)))
    }
    catch 
    {}
}
$ComboTasks.Text = ''
})
    
#Schedule Tasks
$BtnCreateTask.Add_Click({
#Define our scheduling time
#Convert Hours + Mins to total amount of Seconds
$Global:ScheduleTime = (([int]$TxtBxHours.Text * 60) + ([int]$TxtBxMins.Text)) * 60
    
#Create the Task
if ($optTSEnabled.Checked -eq $true){
    #Verify 1. We have a task name 2. Verify we have a scheduled time to run the task on
    if (($TxtBxTaskname.Text -ne "") -and ($Global:ScheduleTime -ne "")){
            
        $TaskVars = [hashtable]::Synchronized(@{
        "ScheduleTime" = $ScheduleTime
        "headers" = $headers
        "TaskName" = $TxtBxTaskname.Text
        "OrgID" = $OrgID
        "Html" = $Html
        "Email" = $Email
        "ScriptName" = $TxtBxScriptName.Text
        })
    
        $backgroundRS = [runspacefactory]::CreateRunspace()
        $backgroundRS.ApartmentState = "STA"
        $backgroundRS.ThreadOptions = "ReuseThread"
        $backgroundRS.Open()
        $backgroundRS.Name = $TxtBxTaskname.Text
        $backgroundRS.SessionStateProxy.SetVariable("TaskVars", $TaskVars)
    
        Set-ColoredLine $TxtBxOutput Black ("Creating Task: " + $backgroundRS.Name + "`r`n")
    
        $TaskVars.BackgroundJobInfo = [powershell]::Create().AddScript({
            while ($true) {
                #Main Logic
                #Build our API Call (test)
                $APICMDFilePath = '.\TaskScheduler\' + $TaskVars.TaskName + '\APICMD.txt'
                $APICMDFile = (Get-Content $APICMDFilePath)
    
                #Set our RS Logging information
                $RSLog = '.\TaskScheduler\' + $TaskVars.TaskName + '\TaskLog.txt'
    
                #Set our GET Result Path
                $RSResultPath = '.\TaskScheduler\' + $TaskVars.TaskName + '\ScheduleResult.txt'
    
                #Set our Root Path (Used for HTML-Convert Reports)
                $RSHtml = '.\TaskScheduler\' + $TaskVars.TaskName + '\Report.html'
    
                #See what all our Variables equal, create a variable log file
                $RSVariableLogs = '.\TaskScheduler\' + $TaskVars.TaskName + '\VarLogs.txt'
                'OrgID: ' + $TaskVars.OrgID >> $RSVariableLogs
                #Debug the header
                #'Header: ' + ($TaskVars.headers | ConvertTo-Json) >> $RSVariableLogs
    
                #Loop Wrap
                #Network-Based GET Tasks
                if ($APICMDFile[3] -eq '$NetworkID'){
                $NetworkListPath = '.\TaskScheduler\' + $TaskVars.TaskName + '\Networks.txt'
    
                    #Check if we have Networks in our network list, if so, continue
                    if ((Test-Path $NetworkListPath) -eq $true){
                        #Create our network list
                        $Networks = (Get-Content $NetworkListPath)
                            #Get our Networks in the Org just one time, then reference back for each network in the list
                                
                            #Get the Network ID via GET
                            $GetNetworkID = $APICMDFile[1] + '/organizations/' + $TaskVars.OrgID + '/networks'
                            $NetworkCall = Invoke-RestMethod -Method GET -Uri $GetNetworkID -Headers $TaskVars.headers
                            $NetworkCall >> $RSLog
    
                            #Start our main-loop
                            foreach ($Network in $Networks){
    
                            #Sort and find our NetworkID
                            $NetworkID = ($NetworkCall | Where-Object {$_.name -eq $Network}).id
                            #Store $Networkcall and $NetworkID for logging
                            '(' + $Network + '):' + $NetworkID >> $RSLog
    
                            #Build our API Command
                            $APICMD = $APICMDFile[0] + $APICMDFile[1] + $APICMDFile[2] + $APICMDFile[3] + $APICMDFile[4] + '$TaskVars.headers'
    
                                if ($NetworkID -ne ''){
                                'NetworkID check passed:' + '(' + $Network + ')' + $NetworkID >> $RSVariableLogs
                                'Command Being sent to ' + $NetworkID + ': ' + $APICMD >> $RSVariableLogs
                                $APIResult = (Invoke-Expression $APICMD | ConvertTo-Json) >> $RSResultPath
                                Start-Sleep -Seconds 0.25
    
                                }
                            }
                            #Build HTML report if: we have valid data, and HTML was set to $true for this runspace
                            if ($TaskVars.Html -eq $true){
                                if ((Get-Content $RSResultPath) -ne ""){
                                $HTMLOutput = (Get-Content $RSResultPath) | ConvertFrom-Json 
                                $HTMLData = $HTMLOutput | ConvertTo-Html >> $RSHtml
                                }
                            }
                            #Run a custom script if: the variable was pushed into the hashtable meaning it was not $null
                            if ($TaskVars.ScriptName -ne $null){
                                'A script name was added to this task: ' + $TaskVars.ScriptName >> $RSLog
                                'Attempting to run: ' + $TaskVars.ScriptName >> $RSLog
                                & ('.\TaskScheduler\' + $TaskVars.TaskName + '\' + $TaskVars.ScriptName)
                                'Script: ' + $TaskVars.ScriptName + ' ,was sent to run.' >> $RSLog
                            }
                            #Email it and be done
                            if ($TaskVars.Email -eq $true){
                            #region Email Parameters
                            $From = (Get-Content .\Email\Address.txt)
                            $To = (Get-Content .\Email\Contacts.txt)
                            $CC = (Get-Content .\Email\CC.txt)
                            $Attachment = $RSHtml
                            $Subject = "Meraki Report: " + $TaskVars.TaskName + '-' + (Get-Date)
                            $SMTPServer = (Get-Content .\Email\SMTP.txt)
                                if ($TaskVars.Html -eq $true){
                                    $Body = Get-Content $RSHtml
                                    Send-MailMessage -From $From -To $To -Subject $Subject -Attachments $Attachment -Body ($Body | Out-String) -BodyAsHtml -SmtpServer $SMTPServer -Cc $CC
                                }
                                if ($TaskVars.Html -ne $true){
                                    $Body = Get-Content $RSResultPath
                                    Send-MailMessage -From $From -To $To -Subject $Subject -Attachments $Attachment -Body ($Body | Out-String) -SmtpServer $SMTPServer -CC $CC
                                }
                            #endregion
                        
                            }
                            #Rename items with the date appended to prepare for next schedule run
                            #Rename Report.html to Report(dateinfo).html
                            Rename-Item $RSHtml -NewName ('Report-' + (Get-Date -Format "MM-dd-yyyy(hh.mm tt)") + '.html')
                            #Rename TaskResult to ScheduleResult(dateinfo).txt
                            Rename-Item $RSResultPath -NewName ('ScheduleResult-' + (Get-Date -Format "MM-dd-yyyy(hh.mm tt)") + '.txt')
                    }
                }
    
                #Organization-Based GET Tasks
                if ($APICMDFile[3] -eq '$OrgID'){
                #Build our API Command
                $APICMD = $APICMDFile[0] + $APICMDFile[1] + $APICMDFile[2] + '$TaskVars.OrgID' + $APICMDFile[4] + '$TaskVars.headers'
                'Org-Based Command detected:' >> $RSLog
                'Command Being sent to Org ' + $TaskVars.OrgID + ':' + ($APICMDFile[1] + $APICMDFile[2] + $TaskVars.OrgID + $APICMDFile[4]) >> $RSLog
                (Invoke-RestMethod -Method $APICMDFile[0].Split("")[2] -Uri ($APICMDFile[1] + $APICMDFile[2] + $TaskVars.OrgID + $APICMDFile[4].Split("")[0]) -Headers $TaskVars.headers) | ConvertTo-Json >> $RSResultPath
                    
                #Build HTML report if: we have valid data, and HTML was set to $true for this runspace
                    if ($TaskVars.Html -eq $true){
                        if ((Get-Content $RSResultPath) -ne ""){
                        $HTMLOutput = (Get-Content $RSResultPath) | ConvertFrom-Json 
                        $HTMLData = $HTMLOutput | ConvertTo-Html >> $RSHtml
                        }
                    }
                #Run a custom script if: the variable was pushed into the hashtable meaning it was not $null
                    if ($TaskVars.ScriptName -ne $null){
                        'A script name was added to this task: ' + $TaskVars.ScriptName >> $RSLog
                        'Attempting to run: ' + $TaskVars.ScriptName >> $RSLog
                        & ('.\TaskScheduler\' + $TaskVars.TaskName + '\' + $TaskVars.ScriptName)
                        'Script: ' + $TaskVars.ScriptName + ' ,was sent to run.' >> $RSLog
                    }
                #Email it and be done
                    if ($TaskVars.Email -eq $true){
                    #region Email Parameters
                    $From = (Get-Content .\Email\Address.txt)
                    $To = (Get-Content .\Email\Contacts.txt)
                    $CC = (Get-Content .\Email\CC.txt)
                    $Attachment = $RSHtml
                    $Subject = "Meraki Report: " + $TaskVars.TaskName + '-' + (Get-Date)
                    $SMTPServer = (Get-Content .\Email\SMTP.txt)
                        if ($TaskVars.Html -eq $true){
                            $Body = Get-Content $RSHtml
                            Send-MailMessage -From $From -To $To -Subject $Subject -Attachments $Attachment -Body ($Body | Out-String) -BodyAsHtml -SmtpServer $SMTPServer -Cc $CC
                        }
                        if ($TaskVars.Html -ne $true){
                            $Body = Get-Content $RSResultPath
                            Send-MailMessage -From $From -To $To -Subject $Subject -Attachments $Attachment -Body ($Body | Out-String) -SmtpServer $SMTPServer -CC $CC
                        }
                    #endregion
                        
                    }
                #Rename items with the date appended to prepare for next schedule run
                #Rename Report.html to Report(dateinfo).html
                Rename-Item $RSHtml -NewName ('Report-' + (Get-Date -Format "MM-dd-yyyy(hh.mm tt)") + '.html')
                #Rename TaskResult to ScheduleResult(dateinfo).txt
                Rename-Item $RSResultPath -NewName ('ScheduleResult-' + (Get-Date -Format "MM-dd-yyyy(hh.mm tt)") + '.txt')
                }
                #Loop Wrap
    
                Start-Sleep -Seconds $TaskVars.ScheduleTime
            }
        })
        $TaskVars.BackgroundJobInfo.Runspace = $backgroundRS
        $TaskVars.BackgroundJob = $TaskVars.BackgroundJobInfo.BeginInvoke()
    
        Set-ColoredLine $TxtBxOutput Green ("Task: " + $backgroundRS.Name + " has been created!" + "`r`n")
    
        #Update ComboTasks with the new task information
        $RSpaces = Get-Runspace
        $ComboTasks.Items.Clear()
        foreach ($Task in $RSpaces){
        try
        {
        $ComboTasks.Items.AddRange(((($Task | Where-Object {$_.id -ne 1}).Name | Sort-Object)))
        }
        catch 
        {}
        }
    
    }  
    if ($TxtBxTaskname.Text -eq ""){
        Set-ColoredLine $TxtBxOutput Red ("Cannot create task because there was no task name entered or one of the next following reasons is true." + "`r`n")
        Set-ColoredLine $TxtBxOutput Red ("If the task has not yet been built, please do so before scheduling." + "`r`n")
        Set-ColoredLine $TxtBxOutput Red ("If the task has been built, please enter the name of the task now." + "`r`n")
        Set-ColoredLine $TxtBxOutput Red ("Verify that there is a proper time parameter entered to run the task on." + "`r`n")
    }
}
    
if ($optTSEnabled.Checked -eq $false){
    Set-ColoredLine $TxtBxOutput Red ("Please enable the Task Scheduler before creating a task." + "`r`n")
}
    
#Set our Scheduled time back to $null
$Global:ScheduleTime = $null
})
    
#Review Current Tasks (Runspaces)
$BtnActTasks.Add_Click({
Get-Runspace | Out-GridView -Title 'Scheduled Tasks'
})
    
#Create Tasks
$BtnBuildTask.Add_Click({
#Build our custom scheduled task
Set-ColoredLine $TxtBxOutput Black ("Preparing Build task." + "`r`n")
    
#Before creating the new task, ensure we have commands that will be added
if($optCustomAPI.Checked -eq $true){
    if ($Global:APICMD -ne $null){
    $HasCommand = $true
    }
    if ($Global:APICMD -eq $null){
    Set-ColoredLine $TxtBxOutput Red ("If using Custom API, please build the API command with the APIBuilder before continuing." + "`r`n")
    }
}
    
#Before creating the new task, ensure we have either networks or an Org to pull from
if ($TxtBxNetListApply.Text -ne ""){
        $HasNetworks = $true
}
    
#Set our Dir
if ($TxtBxTaskname.Text -ne ""){
$Dir = ".\TaskScheduler\" + $TxtBxTaskname.Text
}
    
#Build the Directory, first check if it exists, if not then create it
#Check if a taskname was created
if ($TxtBxTaskname.Text -ne ""){
#Check if it exists first
#Dir already exists, don't build a new task
if ((Test-Path $Dir) -eq $true){
    Set-ColoredLine $TxtBxOutput Red ("Taskname already exists. Please use a new taskname or delete the directory under .\TaskScheduler\(TaskName)" + "`r`n")
}
    
#Check if any command was added, if so, move forward
if ($HasCommand -eq $true){
    if ((Test-Path $Dir) -eq $false){
    Set-ColoredLine $TxtBxOutput Black ("Building Scheduled Task..." + "`r`n")
    mkdir $Dir
    #Create Network File
    if ($HasNetworks -eq $true){
    Set-ColoredLine $TxtBxOutput Black ("Adding Networks to the Task." + "`r`n")
    ($TxtBxNetListApply.Text).Split("") >> $Dir\Networks.txt
    Set-ColoredLine $TxtBxOutput Black ("Networks have been added to the Task." + "`r`n")
    }
        #Create CommandList
        #Add Custom API Data
        if ($Global:APIBMethod -eq 'GET'){
        #Run Code added in the for loop:
        if ($Global:KnownVar -eq "{0}"){
        $KnownVar = '$NetworkID'
        }
        if ($Global:KnownVar -eq "{1}"){
        $KnownVar = '$OrgID'
        }
    
        #Build our command line by line, then it will be strung back up together later
        "Invoke-RestMethod -Method " + $Global:APIBMethod  + " -Uri "  >> $Dir\APICMD.txt
        $Global:APIBURL >> $Dir\APICMD.txt
        $Global:APIStartPath >> $Dir\APICMD.txt
        $KnownVar >> $Dir\APICMD.txt
        $Global:APIEndPath + " -Headers " >> $Dir\APICMD.txt
    
        #Log our completion
        Set-ColoredLine $TxtBxOutput Green ("Task builder procedure complete!" + "`r`n")
        $TxtBxTaskname.Items.AddRange(($TxtBxTaskname.Text | Sort-Object))
        }
    }
    if ($HasNetworks -ne $true){
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Warning: Networks weren't added into this task from the Network List because none were chosen." + "`r`n")
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("This task will be deemed to run API calls that are focused around Org API push/pulls." + "`r`n")
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("If networks needed to be added, add the list of networks to: " + ".\TaskScheduler\$TxtBxTaskname.Text\Networks.txt" + " manually." + "`r`n")
    }
}
if ($HasCommand -eq $null){
    Set-ColoredLine $TxtBxOutput Red ("Please select the type of command to be performed with this task (Custom API)." + "`r`n")
}
    
}
if ($TxtBxTaskname.Text -eq ""){
    Set-ColoredLine $TxtBxOutput Red ( "Task name was not entered. Task building was cancelled." + "`r`n")
}
    
#Cleanup
$HasCommand = $null
$HasNetworks = $null
$Dir = $null
})
    
$ChkBxHTML.Add_CheckedChanged({
if ($ChkBxHTML.Checked -eq $true){
    $Global:Html = $true
}
    
if ($ChkBxHTML.Checked -eq $false){
    $Global:Html = $false
}
    
})
    
$ChkBxEmail.Add_CheckedChanged({
if ($ChkBxEmail.Checked -eq $true){
    $Global:Email = $true
}
    
if ($ChkBxEmail.Checked -eq $false){
    $Global:Email = $false
}
    
})
    
#endregion
    
#region Clear Buttons for GUI interface
$BtnNetClear.Add_Click({
#Clear Network Information
$TxtNetworkName.Text = ''
$V1VLAN.Text = ''
$V2VLAN.Text = ''
$V3VLAN.Text = ''
$TxtBxNet1Range.Text = ''
$TxtBxNet2Range.Text = ''
$TxtBxNet3Range.Text = ''
$TxtCIDR1.Text = ''
$TxtCIDR2.Text = ''
$TxtCIDR3.Text = ''
$TxtBx1VLANName.Text = ''
$TxtBx2VLANName.Text = ''
$TxtBx3VLANName.Text = ''
$TxtAppIP1.Text = ''
$TxtAppIP2.Text = ''
$TxtAppIP3.Text = ''
$Chk1VLANVPN.Checked = $false
$Chk2VLANVPN.Checked = $false
$Chk3VLANVPN.Checked = $false
})
$BtnClearDNS.Add_Click({
$ChkPDNS1.Checked = $false
$ChkPDNS2.Checked = $false
$ChkPDNS3.Checked = $false
$ChkIDNS1.Checked = $false
$ChkIDNS2.Checked = $false
$ChkIDNS3.Checked = $false
$TxtBxNS12.Text = ''
$TxtBxNS1.Text = ''
$TxtBxNS2.Text = ''
$TxtBxNS22.Text = ''
$TxtBxNS3.Text = ''
$TxtBxNS33.Text = ''
    
})
$BtnClearSSID.Add_Click({
$SSIDN.Text = ''
$SSIDPSK.Text = ''
$SSIDType.Text = ''
})
#endregion
    
$BtnLogs.Add_Click({
Invoke-Item .\Logs
})
    
#Re-Generate Secure API Key
$BtnGenerateKey.Add_Click({
$Key = Read-Host -AsSecureString
    
if (Test-Path .\API\API-Key.xml){
    Remove-Item .\API\API-Key.xml
}
if ($null -ne $Key){
    $Key | Export-Clixml -Path ".\API\API-Key.xml"
    $KeyLoc = Import-CliXml -Path ".\API\API-Key.xml"
}
#Decrypt0r
$TxtBxAPIKey.text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($KeyLoc))
    if ($TxtBxAPIKey.text -ne ''){
    Set-ColoredLine $TxtBxOutput Green 'API Key was successfully loaded!'
    }
    if ($TxtBxAPIKey.text -eq ''){
    Set-ColoredLine $TxtBxOutput Red 'API Key could not be found. Please check that the API-Key file exists and try again!'
    }
    
if (Test-Path ".\API\API-Key.xml"){
    Set-ColoredLine $TxtBxOutput DarkGoldenrod "Secure API Key was successfully created. Please close MNCT completely to re-establish the key correctly."
}
})
    
#Delete Secure API Key
$BtnDeleteKey.Add_Click({
if (!(Test-Path .\API\API-Key.xml)){
    Set-ColoredLine $TxtBxOutput Red "MNCT was unable to find a key in the key location. Disregarding this request!"
}
if (Test-Path ".\API\API-Key.xml"){
    Remove-Item .\API\API-Key.xml
    Set-ColoredLine $TxtBxOutput Green "Secure API Key was successfully deleted. Please close MNCT completely to re-establish the key correctly."
}
    
})
    
$BtnNetworkConfImport.Add_Click({
Update-MNCTStatus -Running $true
    
Import-Folder
    
if ($null -ne $Global:NetworkImportPath){
    try{
        Set-ColoredLine $TxtBxOutput Black ("Attempting to import network configuration"  + "`r`n")
        #Set the Network Name in MNCT
        $TxtNetworkName.Text = $Global:NetworkImportPath.Split("\")[-1]
    
        #Import L3 FW Rules
        if (Test-Path ($Global:NetworkImportPath + "\L3FW.txt")){
            try{
                $FirewallRulesContent = Get-Content ($Global:NetworkImportPath + "\L3FW.txt")
    
                ###Separate this, run as rules
                $global:json = $FirewallRulesContent | ConvertFrom-Json
    
                #Create Logging in GUI
                $jsonrulelogging = foreach ($json in $global:json){$json.comment + "`r`n"}
                $L7jsonrulelogging = foreach ($L7json in $global:L7json){$L7json.value.name + "`r`n"}
    
                Set-ColoredLine $TxtBxOutput Black ('The following rules have been imported in this order:' + "`r`n" + $jsonrulelogging)
    
                #Update the Firewall Configuration in the Overview:
                $TxtBxFWRules.Text = 'L3 FW Rules:' + "`r`n" + $jsonrulelogging + "`r`n" + 'L7 FW Rules:' + "`r`n"  + $L7jsonrulelogging
    
                #ExportVariables
                $Global:L3FWExport = $global:json
    
                Set-ColoredLine $TxtBxOutput Green ('L3 Firewall import complete!' + "`r`n")
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
        }
        #Import L7 FW Rules
        if (Test-Path ($Global:NetworkImportPath + "\L7FW.txt")){
            try{
                $L7FirewallRulesContent = Get-Content ($Global:NetworkImportPath + "\L7FW.txt")
    
                ###Separate this, run as rules
                $global:L7json = $L7FirewallRulesContent | ConvertFrom-Json
    
                if ("" -eq $global:L7json){
                    Set-ColoredLine $TxtBxOutput DarkGoldenrod("The import detected the configuration file, but it contained no firewall rule information" + "`r`n")
                }
    
                #Create Logging in GUI
                $jsonrulelogging = foreach ($json in $global:json){$json.comment + "`r`n"}
                $L7jsonrulelogging = foreach ($L7json in $global:L7json){$L7json.value.name + "`r`n"}
                    
                if ("" -ne $global:L7json){
                    Set-ColoredLine $TxtBxOutput Black ('The following rules have been imported in this order:' + "`r`n" + $L7jsonrulelogging)
                }
    
                #Update the Firewall Configuration in the Overview:
                $TxtBxFWRules.Text = 'L3 FW Rules:' + "`r`n" + $jsonrulelogging + "`r`n" + 'L7 FW Rules:' + "`r`n"  + $L7jsonrulelogging
    
                #L7 FW Export Variable
                $Global:L7FWExport = $global:L7json
    
                Set-ColoredLine $TxtBxOutput Green ('L7 Firewall import complete!' + "`r`n")
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
        }
        #Import Network Tags
        if (Test-Path ($Global:NetworkImportPath + "\Tags.txt")){
            try{
                $TxtBxNetTag.Text = (Get-Content ($Global:NetworkImportPath + "\Tags.txt")) -replace '"' 
                Set-ColoredLine $TxtBxOutput Black ('The following tags have been imported: ' + $TxtBxNetTag.Text  + "`r`n")
    
                #Export Variable
                $Global:TagExport = $TxtBxNetTag.Text
    
                Set-ColoredLine $TxtBxOutput Green ("Tag import completed!" + "`r`n")
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
    
        }
        #Import Device Types
        if (Test-Path ($Global:NetworkImportPath + "\Devices.txt")){
            try{
                Set-ColoredLine $TxtBxOutput Black ("Beginning Device type import" + "`r`n") 
                $DevTImport = Get-Content ($Global:NetworkImportPath + "\Devices.txt") | ConvertFrom-Json
                if ($DevTImport -contains 'appliance'){
                    $optAppliance.Checked = $true
                    #Create Logging in GUI
                    Set-ColoredLine $TxtBxOutput Green ('Device Type Appliance was imported' + "`r`n")
                }
                if ($DevTImport -contains 'switch'){
                    $optSwitch.Checked = $true
                    #Create Logging in GUI
                    Set-ColoredLine $TxtBxOutput Green ('Device Type Switch was imported' + "`r`n")
                }
                if ($DevTImport -contains 'wireless'){
                    $optWireless.Checked = $true
                    #Create Logging in GUI
                    Set-ColoredLine $TxtBxOutput Green ('Device Type Wireless was imported' + "`r`n")
                }
                if ($DevTImport -contains 'cellularGateway'){
                    $optCG.Checked = $true
                    #Create Logging in GUI
                    Set-ColoredLine $TxtBxOutput Green ('Device Type Cellular Gateway was imported' + "`r`n")
                }
                if ($DevTImport -contains 'camera'){
                    $optCam.Checked = $true
                    #Create Logging in GUI
                    Set-ColoredLine $TxtBxOutput Green ('Device Type Camera was imported' + "`r`n")
                }
                #Variable Export
                $Global:DevExport = $DevTImport
                Set-ColoredLine $TxtBxOutput Green ("Device type import completed!" + "`r`n")
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
        }
        #Import Content Filtering
        if (Test-Path ($Global:NetworkImportPath + "\ContentFiltering.txt")){
            try{
                Set-ColoredLine $TxtBxOutput Black ("Attempting Content Filter import" + "`r`n")
                $Global:ContentFiltering = Get-Content ($Global:NetworkImportPath + "\ContentFiltering.txt") | ConvertFrom-Json
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($ContentFiltering | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Green ("Content Filter import completed!" + "`r`n")
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
        }
        #Import Location
        if (Test-Path ($Global:NetworkImportPath + "\Location.txt")){
            try{
                Set-ColoredLine $TxtBxOutput Black ("Attempting Location import" + "`r`n")
                $Global:LocData = Get-Content ($Global:NetworkImportPath + "\Location.txt") | ConvertFrom-Json
                if ("" -eq $global:LocData){
                    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("The import detected the configuration file, but it contained no Location information" + "`r`n")
                }
                if ("" -ne $global:LocData){
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($Global:LocData | ConvertTo-Json) + "`r`n")}
                }
                Set-ColoredLine $TxtBxOutput Green ("Location import completed!" + "`r`n")
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }    
        }
        #Import Traffic Shaping
        if (Test-Path ($Global:NetworkImportPath + "\TrafficShaping.txt")){
            try{
                Set-ColoredLine $TxtBxOutput Black ("Attempting Traffic Shaping import" + "`r`n")
                $Global:TRSData = Get-Content ($Global:NetworkImportPath + "\TrafficShaping.txt") | ConvertFrom-Json
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($TRSData | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Green  ("Traffic Shaping import completed" + "`r`n")
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
        }
        #Import Threat Protection
        if (Test-Path ($Global:NetworkImportPath + "\ThreatProtection.txt")){
            try{
                Set-ColoredLine $TxtBxOutput Black ("Attempting Threat Protection import"  + "`r`n")
                $Global:SecData = Get-Content ($Global:NetworkImportPath + "\ThreatProtection.txt") | ConvertFrom-Json
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($Global:SecData | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Green ("Security data has been imported." + "`r`n")
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
        }
        #Import VLANs
        if (Test-Path ($Global:NetworkImportPath + "\VLAN.txt")){
            try{
                $VLANImport = Get-Content ($Global:NetworkImportPath + "\VLAN.txt") | ConvertFrom-Json
                
                #VLAN Export Variable
                $Global:VLANExport = $VLANImport
    
                if (!($VLANImport[0].Length -gt 4)){
                    ###Blank out our VLAN text data first, then import
                    #region VLAN1 Resets
                    $V1VLAN.Text = ''
                    $TxtBx1VLANName.Text = ''
                    $TxtAppIP1.Text = ''
                    $TxtCIDR1.Text = ''
                    $TxtBxNet1Range.Text = ''
                    $ChkIDNS1.Checked = $false
                    $ChkPDNS1.Checked = $false
                    $TxtBxNS1.Text = ''
                    $TxtBxNS12.Text = ''
                    #endregion
    
                    #region VLAN2 Resets
                    $V2VLAN.Text = ''
                    $TxtBx2VLANName.Text = ''
                    $TxtAppIP2.Text = ''
                    $TxtCIDR2.Text = ''
                    $TxtBxNet2Range.Text = ''
                    $ChkIDNS2.Checked = $false
                    $ChkPDNS2.Checked = $false
                    $TxtBxNS2.Text = ''
                    $TxtBxNS22.Text = ''
                    #endregion
    
                    #region VLAN3 Resets
                    $V3VLAN.Text = ''
                    $TxtBx3VLANName.Text = ''
                    $TxtAppIP3.Text = ''
                    $TxtCIDR3.Text = ''
                    $TxtBxNet3Range.Text = ''
                    $ChkIDNS3.Checked = $false
                    $ChkPDNS3.Checked = $false
                    $TxtBxNS3.Text = ''
                    $TxtBxNS33.Text = ''
                    #endregion
    
                    Set-ColoredLine $TxtBxOutput Black ("Removing VLAN Entries in MNCT, preparing import from: " + $TxBxNetNameImport.Text + "`r`n")
                    if ($VLANImport[0] -ne $null){
                        Set-ColoredLine $TxtBxOutput Black ("Configuring First VLAN entry configuration from import." + "`r`n")
    
                        #First VLAN Entry
                        #VLAN Configuration
                        $V1VLAN.Text = $VLANImport[0].id
                        #Set the VLAN Name
                        $TxtBx1VLANName.Text = $VLANImport[0].name
                        #Set the Appliance IP
                        $TxtAppIP1.Text = $VLANImport[0].applianceIp
    
                        #Manipulate the subnet
                        $TxtCIDR1.Text = $VLANImport[0].subnet.SubString($VLANImport[0].subnet.Length - 3)
                        $TxtBxNet1Range.Text = $VLANImport[0].subnet -replace ".{3}$"
    
                        #DNS Configuration
                        #Check if it's Internal DNS
                        if($VLANImport[0].dnsNameservers -ne "upstream_dns"){
                            $ChkIDNS1.Checked = $true
                            $ChkPDNS1.Checked = $false
                            #Import our DNS Servers and set it in our text boxes
                            $VLAN1DNSImp = $VLANImport[0].dnsNameservers | ConvertFrom-String
                            $TxtBxNS1.Text = $VLAN1DNSImp.P1
                            $TxtBxNS12.Text = $VLAN1DNSImp.P2
                        }
                        #Check if it's Proxy
                        if($VLANImport[0].dnsNameservers -eq "upstream_dns"){
                            $ChkPDNS1.Checked = $true
                            $ChkIDNS1.Checked = $false
                            $TxtBxNS1.Text = ""
                            $TxtBxNS12.Text = ""
                        }
    
                        #First VLAN/DHCP Configuration
                        Set-ColoredLine $TxtBxOutput Black ("Creating DHCP Global Variables..." + "`r`n")
                        $Global:V1DHCPOpt = $VLANImport[0].dhcpOptions
                        #Grab our Fixed IP Assignments and store them as a var
                        $Global:V1FIPs = $VLANImport[0].fixedIpAssignments
                        $Global:V1resIpRanges = $VLANImport[0].reservedIpRanges
    
    
                        Set-ColoredLine $TxtBxOutput Green ("Created V1DHCPOpt: " + $Global:V1DHCPOpt + "Created V1FixedIP:" + $Global:V1FixedIP + "Created V1resIpRanges:" + $Global:V1resIpRanges + "`r`n")
    
                        Set-ColoredLine $TxtBxOutput Green ("First VLAN entry configuration complete." + "`r`n")
                    }
                    if ($VLANImport[1] -ne $null){
                        Set-ColoredLine $TxtBxOutput Black ("Configuring Second VLAN entry configuration from import." + "`r`n")
                        #Second VLAN Entry
                        #VLAN Configuration
                        $V2VLAN.Text = $VLANImport[1].id
                        #Set the VLAN Name
                        $TxtBx2VLANName.Text = $VLANImport[1].name
                        #Set the Appliance IP
                        $TxtAppIP2.Text = $VLANImport[1].applianceIp
    
                        #Manipulate the subnet
                        $TxtCIDR2.Text = $VLANImport[1].subnet.SubString($VLANImport[1].subnet.Length - 3)
                        $TxtBxNet2Range.Text = $VLANImport[1].subnet -replace ".{3}$"
    
                        #DNS Configuration
                        #Check if it's Internal DNS
                        if($VLANImport[1].dnsNameservers -ne "upstream_dns"){
                            $ChkIDNS2.Checked = $true
                            $ChkPDNS2.Checked = $false
                            #Import our DNS Servers and set it in our text boxes
                            $VLAN2DNSImp = $VLANImport[1].dnsNameservers | ConvertFrom-String
                            $TxtBxNS2.Text = $VLAN2DNSImp.P1
                            $TxtBxNS22.Text = $VLAN2DNSImp.P2
                        }
                        #Check if it's Proxy
                        if($VLANImport[1].dnsNameservers -eq "upstream_dns"){
                            $ChkPDNS2.Checked = $true
                            $ChkIDNS2.Checked = $false
                            $TxtBxNS2.Text = ""
                            $TxtBxNS22.Text = ""
                        }
    
                        #Second VLAN/DHCP Configuration
                        Set-ColoredLine $TxtBxOutput Black ("Creating DHCP Global Variables..." + "`r`n")
                        $Global:V2DHCPOpt = $VLANImport[1].dhcpOptions
                        $Global:V2FIPs = $VLANImport[1].fixedIpAssignments
                        $Global:V2resIpRanges = $VLANImport[1].reservedIpRanges
    
                        Set-ColoredLine $TxtBxOutput Green ("Created V2DHCPOpt: " + $Global:V2DHCPOpt + "Created V2FixedIP:" + $Global:V2FixedIP + "Created V2resIpRanges:" + $Global:V2resIpRanges + "`r`n")
    
                        Set-ColoredLine $TxtBxOutput Green ("Second VLAN entry configuration complete." + "`r`n")
                    }
                    if ($VLANImport[2] -ne $null){
                        Set-ColoredLine $TxtBxOutput Black ("Configuring Third VLAN entry configuration from import." + "`r`n")
                        #Third VLAN Entry
                        #VLAN Configuration
                        $V3VLAN.Text = $VLANImport[2].id
                        #Set the VLAN Name
                        $TxtBx3VLANName.Text = $VLANImport[2].name
                        #Set the Appliance IP
                        $TxtAppIP3.Text = $VLANImport[2].applianceIp
    
                        #Manipulate the subnet
                        $TxtCIDR3.Text = $VLANImport[2].subnet.SubString($VLANImport[2].subnet.Length - 3)
                        $TxtBxNet3Range.Text = $VLANImport[2].subnet -replace ".{3}$"
    
                        #DNS Configuration
                        #Check if it's Internal DNS
                        if($VLANImport[2].dnsNameservers -ne "upstream_dns"){
                            $ChkIDNS3.Checked = $true
                            $ChkPDNS3.Checked = $false
                            #Import our DNS Servers and set it in our text boxes
                            $VLAN3DNSImp = $VLANImport[2].dnsNameservers | ConvertFrom-String
                            $TxtBxNS3.Text = $VLAN3DNSImp.P1
                            $TxtBxNS33.Text = $VLAN3DNSImp.P2
                        }
                        #Check if it's Proxy
                        if($VLANImport[2].dnsNameservers -eq "upstream_dns"){
                            $ChkPDNS3.Checked = $true
                            $ChkIDNS3.Checked = $false
                            $TxtBxNS3.Text = ""
                            $TxtBxNS33.Text = ""
                        }
    
                        #Third VLAN/DHCP Configuration
                        Set-ColoredLine $TxtBxOutput Black ("Creating DHCP Global Variables..." + "`r`n")
                        $Global:V3DHCPOpt = $VLANImport[2].dhcpOptions
                        $Global:V3FIPs = $VLANImport[2].fixedIpAssignments
                        $Global:V3resIpRanges = $VLANImport[2].reservedIpRanges
    
                        Set-ColoredLine $TxtBxOutput Green ("Created V3DHCPOpt: " + $Global:V3DHCPOpt + "Created V3FixedIP:" + $Global:V3FixedIP + "Created V3resIpRanges:" + $Global:V3resIpRanges + "`r`n")
    
                        Set-ColoredLine $TxtBxOutput Green ("Third VLAN entry configuration complete." + "`r`n")
            }
                        Set-ColoredLine $TxtBxOutput Green ("VLAN Import from:" + $TxBxNetNameImport.Text + " complete." + "`r`n")
            }
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                    Get-CurrentLine
                    $break
            }
        }
        #Import IDS
        if (Test-Path ($Global:NetworkImportPath + "\IDS.txt")){
            try{
                Set-ColoredLine $TxtBxOutput Black ("Attempting IDS import"  + "`r`n")
                $Global:IDSData = Get-Content ($Global:NetworkImportPath + "\IDS.txt") | ConvertFrom-Json
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($Global:IDSData | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Green ("Intrusion Detection settings have been imported!" + "`r`n")
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
        }
        #Import Timezone
        if (Test-Path ($Global:NetworkImportPath + "\Timezone.txt")){
            try{
                Set-ColoredLine $TxtBxOutput Black ("Attempting Timezone import"  + "`r`n")
                $ComboTimeZone.Text = Get-Content ($Global:NetworkImportPath + "\Timezone.txt")
                Set-ColoredLine $TxtBxOutput Green ("Timezone has been imported!" + "`r`n")
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
        }
    
        Set-ColoredLine $TxtBxOutput Green ("Network Configuration Import Complete!"  + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    Update-MNCTStatus -Running $false
    }
})
    
$ChkBxDebug.Add_CheckedChanged({
    if ($ChkBxDebug.Checked -eq $true){
        $Global:break = $true
        Set-Debugging
    }
    if ($ChkBxDebug.Checked -eq $false){
        $Global:break = $false
        Set-Debugging
        $break
    }
    
})
#endregion
    
#########NETWORK IMPORT SELECTIONS######
#region Import Selections
$BtnFWImport.Add_Click({
if ($null -ne $APIKey){
if ($TxBxNetNameImport.Text -ne ''){
Update-MNCTStatus -Running $true
    
#Read our Import Org Combo Box for the Org ID
Set-OrgImportv0
    
Get-NetworkImportID
    
try {
    #Create Logging in GUI
    $jsonrulelogging = foreach ($json in $global:json){$json.comment + "`r`n"}
    $L7jsonrulelogging = foreach ($L7json in $global:L7json){$L7json.value.name + "`r`n"}
    
    $FWRuleImports = (Get-MrkNetworkMXL3FwRule -networkId $NetworkID)
    #ExportVariables
    $Global:L3FWExport = $FWRuleImports
    
    $global:json = $FWRuleImports
    
    #Create Logging in GUI
    $jsonrulelogging = foreach ($json in $global:json){$json.comment + "`r`n"}
    
    Set-ColoredLine $TxtBxOutput Black ('The following rules from: ' + $TxBxNetNameImport.Text + ', have been imported in this order:' + "`r`n" + $jsonrulelogging)
    
    $L7jsonrulelogging = $global:L7json.rules.value.name
    
    $L7Logging = foreach($L7jsonrulelogging in $L7jsonrulelogging){$L7jsonrulelogging + "`r`n"}
    
    #Update the Firewall Configuration in the Overview:
    $TxtBxFWRules.Text = 'L3 FW Rules:' + "`r`n" + $jsonrulelogging + "`r`n" + 'L7 FW Rules:' + "`r`n"  + $L7Logging
    
    Set-ColoredLine $TxtBxOutput Green ("L3 Firewall Import Completed!" + "`r`n")
}
catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
}
    
Update-MNCTStatus -Running $false
}
if ($TxBxNetNameImport.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
}
}
})
$BtnFW7Import.Add_Click({
if ($TxBxNetNameImport.Text -ne ''){
Update-MNCTStatus -Running $true
    
Set-OrgImportv0
    
#Get Network Information
    try{
        Get-NetworkImportID
    
        #Create Logging in GUI
        $jsonrulelogging = foreach ($json in $global:json){$json.comment + "`r`n"}
        $L7jsonrulelogging = foreach ($L7json in $global:L7json){$L7json.value.name + "`r`n"}
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    
    
try{
    Set-ColoredLine $TxtBxOutput Black ("Attempting L7 Firewall rule import from: " + $TxBxNetNameImport.Text + "`r`n")
    $L7FWRuleImports = (Get-MrkNetworkMXL7FwRule -networkId $NetworkID)
        
    #L7 FW Export Variable
    $Global:L7FWExport = $L7FWRuleImports
    
    $global:L7json = $L7FWRuleImports
    
    $L7jsonrulelogging = $L7FWRuleImports.rules.value.name
    
    Set-ColoredLine $TxtBxOutput Black ('The following rules have been imported from:' + $TxBxNetNameImport.Text + ', in this order:' + "`r`n" + $L7jsonrulelogging)
    
    $L7Logging = foreach($L7jsonrulelogging in $L7jsonrulelogging){$L7jsonrulelogging + "`r`n"}
    
    #L7FW Test
    $break
    
    #Update the Firewall Configuration in the Overview:
    $TxtBxFWRules.Text = 'L3 FW Rules:' + "`r`n" + $jsonrulelogging + "`r`n" + 'L7 FW Rules:' + "`r`n"  + $L7Logging
    
    if ("" -eq $L7json.rules){
        Set-ColoredLine $TxtBxOutput DarkGoldenrod ("API Request to obtain L7 Firewall rules was sucessful, however the network did not contain any L7 FW rules to import." + "`r`n")
    }
    
    Set-ColoredLine $TxtBxOutput Green ("L7 Firewall rule import completed!" + "`r`n")
}
catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
}
    
    
Update-MNCTStatus -Running $false
}
if ($TxBxNetNameImport.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
}
})
$BtnTagImport.Add_Click({
if ($TxBxNetNameImport.Text -ne ''){
    Update-MNCTStatus -Running $true
        
    #Read our Import Org Combo Box for the Org ID
    Set-OrgImportv0
    
    try{
        Get-NetworkImportID
            
        #Create Logging in GUI
        Set-ColoredLine $TxtBxOutput Black ('The following tags have been imported from: ' + $TxBxNetNameImport.Text + $TxtBxNetTag.Text  + "`r`n")
    
        #Export Variable
        $Global:TagExport = ($request | Where-Object {$_.name -eq $TxBxNetNameImport.Text}).tags
        Set-ColoredLine $TxtBxOutput Green ("Tag import completed!" + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
    }
    
    Update-MNCTStatus -Running $false
}
if ($TxBxNetNameImport.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
}
})
$BtnImportDT.Add_Click({
if ($TxBxNetNameImport.Text -ne ''){
    Update-MNCTStatus -Running $true
    
    #Read our Import Org Combo Box for the Org ID
    Set-OrgImportv1
    
    #Fill in the Product Types
    try{
        Set-ColoredLine $TxtBxOutput Black ("Beginning Device type import from: " + $TxBxNetNameImport.Text  + "`r`n")
        #Grab the network ID of the selected network
        $GetNetworkID = $BaseURL + '/organizations/' + $OrgID + '/networks'
        $request = Invoke-RestMethod -Method GET -Uri $GetNetworkID -Headers $headers
        $DevTImport = ($request | Where-Object {$_.name -eq $TxBxNetNameImport.Text}).productTypes
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black ((($request | Where-Object {$_.name -eq $TxBxNetNameImport.Text}).productTypes | ConvertTo-Json) + "`r`n")}
        if ($DevTImport -contains 'appliance'){
            $optAppliance.Checked = $true
            #Create Logging in GUI
            Set-ColoredLine $TxtBxOutput Green ('Device Type Appliance was imported' + "`r`n")
        }
        if ($DevTImport -contains 'switch'){
            $optSwitch.Checked = $true
            #Create Logging in GUI
            Set-ColoredLine $TxtBxOutput Green ('Device Type Switch was imported' + "`r`n")
        }
        if ($DevTImport -contains 'wireless'){
            $optWireless.Checked = $true
            #Create Logging in GUI
            Set-ColoredLine $TxtBxOutput Green ('Device Type Wireless was imported' + "`r`n")
        }
        if ($DevTImport -contains 'cellularGateway'){
            $optCG.Checked = $true
            #Create Logging in GUI
            Set-ColoredLine $TxtBxOutput Green ('Device Type Cellular Gateway was imported' + "`r`n")
        }
        if ($DevTImport -contains 'camera'){
            $optCam.Checked = $true
            #Create Logging in GUI
            Set-ColoredLine $TxtBxOutput Green ('Device Type Camera was imported' + "`r`n")
        }
        #Variable Export
        $Global:DevExport = $DevTImport
        Set-ColoredLine $TxtBxOutput Green ("Device type import completed!" + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
    }
    
    Set-ColoredLine $TxtBxOutput Black ('Importing Network Devices from ' + $TxBxNetNameImport.Text + "`r`n")
                  
    Get-NetworkImportID
    
        #Import all Devices
        try{
            #Retrieve Network Devices, then populate info into MNCT
            $result = Get-MrkNetworkDevice -networkId $NetworkID
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                
            #Null out all entries before importing
            $TxtBxSD.Text = ''
            $TxtBxDN.Text = ''
            $TxtBxDevTag.Text = ''
            $TxtBxDevAddress.Text = ''
            $TxtBxDevModel.Text = ''
            $TxtBxDevName.Text = ''
    
            #Build out our loop
            $serialnum = 0
            do {
                $TxtBxSD.Text += $result[$serialnum].serial + "`r`n"
                $TxtBxDN.Text += $result[$serialnum].notes + "`r`n"
                $TxtBxDevTag.Text += $result[$serialnum].tags + "`r`n"
                $TxtBxDevAddress.Text += $result[$serialnum].address + "`r`n"
                $TxtBxDevModel.Text += $result[$serialnum].model + "`r`n"
                $TxtBxDevName.Text += $result[$serialnum].name + "`r`n"
                $serialnum += 1
            }while ($serialnum -lt $result.Count)
            $serialnum = 0
    
            #Create Logging in GUI
            Set-ColoredLine $TxtBxOutput Green ('Network Devices have been imported from ' + $TxBxNetNameImport.Text + "`r`n")
        }
        catch{ $RESTError = ParseErrorForResponseBody($_)
                if ($null -eq $result){
                Set-ColoredLine $TxtBxOutput Red ('Devices were not able to be imported from: ' + $TxBxNetNameImport.Text + ". The reason is likely that the network has no available devices to import." + "`r`n")
                }
                if ($null -ne $result){
                Get-CurrentLine
                $break
                }
        }
    
    #Read our Import Org Combo Box for the Org ID
    Set-OrgImportv0
    
Update-MNCTStatus -Running $false
}
if ($TxBxNetNameImport.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
}
    
})
$BtnImportCFilter.Add_Click({
if ($TxBxNetNameImport.Text -ne ''){
    Update-MNCTStatus -Running $true
        
    #Read our Import Org Combo Box for the Org ID
    Set-OrgImportv0
    
    Get-NetworkImportID
    
    try{
        Set-ColoredLine $TxtBxOutput Black ("Attempting Content Filter import from: " + $TxBxNetNameImport.Text  + "`r`n")
        #Grab the content filtering
        $GetCFURI = $BaseURL + '/networks/' + $NetworkID + '/contentFiltering'
        $Global:ContentFiltering = Invoke-RestMethod -Method GET -Uri $GetCFURI -Headers $headers
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($ContentFiltering | ConvertTo-Json) + "`r`n")}
        foreach($Global:ContentFiltering in $Global:ContentFiltering){
            Set-ColoredLine $TxtBxOutput Black ('Importing Blocked URL Category: ' + $Global:ContentFiltering.blockedUrlCategories.name + "`r`n")
        }
        Set-ColoredLine $TxtBxOutput Green ("Content Filter import completed!" + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
    }
    
    Update-MNCTStatus -Running $false
}
if ($TxBxNetNameImport.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
}
})
$BtnImportLoc.Add_Click({
if ($TxBxNetNameImport.Text -ne ''){
    Update-MNCTStatus -Running $true
        
    #Read our Import Org Combo Box for the Org ID
    Set-OrgImportv0
    
    Get-NetworkImportID
        
    try{
        Set-ColoredLine $TxtBxOutput Black ("Attempting Location import from: " + $TxBxNetNameImport.Text  + "`r`n")
        #Grab the Location
        $LocURI = $BaseURL + '/networks/' + $NetworkID + '/floorPlans'
        $Global:LocData = Invoke-RestMethod -Method GET -Uri $LocURI -Headers $headers
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($LocData | ConvertTo-Json) + "`r`n")}
        if ($Global:LocData -eq ""){
            Set-ColoredLine $TxtBxOutput DarkGoldenrod ("API Request to obtain Location data was sucessful, however the network did not have any data to import." + "`r`n")
        }
        Set-ColoredLine $TxtBxOutput Green ("Location import completed!" + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    
    Update-MNCTStatus -Running $false
    }
if ($TxBxNetNameImport.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
}
})
$BtnImportTRS.Add_Click({
if ($TxBxNetNameImport.Text -ne ''){
    Update-MNCTStatus -Running $true
    
    #Read our Import Org Combo Box for the Org ID
    Set-OrgImportv1
    try{
        #Grab the network ID of the selected network
        $GetNetworkID = $BaseURL + '/organizations/' + $OrgID + '/networks'
        $request = Invoke-RestMethod -Method GET -Uri $GetNetworkID -Headers $headers
        $NetworkID = ($request | Where-Object {$_.name -eq $TxBxNetNameImport.Text}).id
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
    }
        
    try{
        Set-ColoredLine $TxtBxOutput Black ("Attempting Traffic Shaping import from: " + $TxBxNetNameImport.Text + "`r`n")
        #Grab the TRS 
        $GetTRSID = $BaseURL + '/networks/' + $NetworkID + '/appliance/trafficShaping'
        $Global:TRSData = Invoke-RestMethod -Method GET -Uri $GetTRSID -Headers $headers
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($TRSData | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Black ("Traffic Shaping data has been imported." + "limit up:" + $Global:TRSData.globalBandwidthLimits.limitUp + "`r`n" + 'limit down:' + $Global:TRSData.globalBandwidthLimits.limitDown + "`r`n")
        Set-ColoredLine $TxtBxOutput Green  ("Traffic Shaping import completed" + "`r`n")
        }
    catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
    }
       
    
    Update-MNCTStatus -Running $false
}
if ($TxBxNetNameImport.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
}
})
$BtnImportTP.Add_Click({
if ($TxBxNetNameImport.Text -ne ''){
    Update-MNCTStatus -Running $true
    
    #Read our Import Org Combo Box for the Org ID
    Set-OrgImportv1
    
    Get-NetworkImportID
          
    try {
        $Global:SecData = $null
        Set-ColoredLine $TxtBxOutput Black ("Attempting Threat Protection import from: " + $TxBxNetNameImport.Text + "`r`n")
        #Grab the Malware security settings
        $GetSecData = $BaseURL + '/networks/' + $NetworkID + '/appliance/security/malware'
        $Global:SecData = Invoke-RestMethod -Method GET -Uri $GetSecData -Headers $headers
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($SecData | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Green ("Security data has been imported." + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
            if ($null -eq $Global:SecData){
            Set-ColoredLine $TxtBxOutput Red ('An Error occured with Threat Protection Import. You cannot import from a network in which it does not contain valid Threat Protection configuration. This import has been skipped. ' + "`r`n")
            }
            if ($null -ne $Global:SecData){
            Get-CurrentLine
            $break
            }
    }
    
    Update-MNCTStatus -Running $false
}
if ($TxBxNetNameImport.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
}
})
$BtnImportVLAN.Add_Click({
if ($TxBxNetNameImport.Text -ne ''){
Update-MNCTStatus -Running $true
    
#Read our Import Org Combo Box for the Org ID
Set-OrgImportv1
    
Get-NetworkImportID
    
Set-ColoredLine $TxtBxOutput Black ("Attempting VLAN Import from: " + $TxBxNetNameImport.Text + "`r`n")
    
try{
    $VLANImport = Get-MrkNetworkVLAN -networkId $NetworkID
    #VLAN Export Variable
    $Global:VLANExport = $VLANImport
    if (!($VLANImport[0].Length -gt 4)){
        ###Blank out our VLAN text data first, then import
        #region VLAN1 Resets
        $V1VLAN.Text = ''
        $TxtBx1VLANName.Text = ''
        $TxtAppIP1.Text = ''
        $TxtCIDR1.Text = ''
        $TxtBxNet1Range.Text = ''
        $ChkIDNS1.Checked = $false
        $ChkPDNS1.Checked = $false
        $TxtBxNS1.Text = ''
        $TxtBxNS12.Text = ''
        #endregion
    
        #region VLAN2 Resets
        $V2VLAN.Text = ''
        $TxtBx2VLANName.Text = ''
        $TxtAppIP2.Text = ''
        $TxtCIDR2.Text = ''
        $TxtBxNet2Range.Text = ''
        $ChkIDNS2.Checked = $false
        $ChkPDNS2.Checked = $false
        $TxtBxNS2.Text = ''
        $TxtBxNS22.Text = ''
        #endregion
    
        #region VLAN3 Resets
        $V3VLAN.Text = ''
        $TxtBx3VLANName.Text = ''
        $TxtAppIP3.Text = ''
        $TxtCIDR3.Text = ''
        $TxtBxNet3Range.Text = ''
        $ChkIDNS3.Checked = $false
        $ChkPDNS3.Checked = $false
        $TxtBxNS3.Text = ''
        $TxtBxNS33.Text = ''
        #endregion
    
        Set-ColoredLine $TxtBxOutput Black ("Removing VLAN Entries in MNCT, preparing import from: " + $TxBxNetNameImport.Text + "`r`n")
        if ($VLANImport[0] -ne $null){
            Set-ColoredLine $TxtBxOutput Black ("Configuring First VLAN entry configuration from import." + "`r`n")
    
            #First VLAN Entry
            #VLAN Configuration
            $V1VLAN.Text = $VLANImport[0].id
            #Set the VLAN Name
            $TxtBx1VLANName.Text = $VLANImport[0].name
            #Set the Appliance IP
            $TxtAppIP1.Text = $VLANImport[0].applianceIp
    
            #Manipulate the subnet
            $TxtCIDR1.Text = $VLANImport[0].subnet.SubString($VLANImport[0].subnet.Length - 3)
            $TxtBxNet1Range.Text = $VLANImport[0].subnet -replace ".{3}$"
    
            #DNS Configuration
            #Check if it's Internal DNS
            if($VLANImport[0].dnsNameservers -ne "upstream_dns"){
                $ChkIDNS1.Checked = $true
                $ChkPDNS1.Checked = $false
                #Import our DNS Servers and set it in our text boxes
                $VLAN1DNSImp = $VLANImport[0].dnsNameservers | ConvertFrom-String
                $TxtBxNS1.Text = $VLAN1DNSImp.P1
                $TxtBxNS12.Text = $VLAN1DNSImp.P2
            }
            #Check if it's Proxy
            if($VLANImport[0].dnsNameservers -eq "upstream_dns"){
                $ChkPDNS1.Checked = $true
                $ChkIDNS1.Checked = $false
                $TxtBxNS1.Text = ""
                $TxtBxNS12.Text = ""
            }
    
            #First VLAN/DHCP Configuration
            Set-ColoredLine $TxtBxOutput Black ("Creating DHCP Global Variables..." + "`r`n")
            $Global:V1DHCPOpt = $VLANImport[0].dhcpOptions
            #Grab our Fixed IP Assignments and store them as a var
            $Global:V1FIPs = $VLANImport[0].fixedIpAssignments
            $Global:V1resIpRanges = $VLANImport[0].reservedIpRanges
    
    
            Set-ColoredLine $TxtBxOutput Green ("Created V1DHCPOpt: " + $Global:V1DHCPOpt + "Created V1FixedIP:" + $Global:V1FixedIP + "Created V1resIpRanges:" + $Global:V1resIpRanges + "`r`n")
    
            Set-ColoredLine $TxtBxOutput Green ("First VLAN entry configuration complete." + "`r`n")
        }
        if ($VLANImport[1] -ne $null){
            Set-ColoredLine $TxtBxOutput Black ("Configuring Second VLAN entry configuration from import." + "`r`n")
            #Second VLAN Entry
            #VLAN Configuration
            $V2VLAN.Text = $VLANImport[1].id
            #Set the VLAN Name
            $TxtBx2VLANName.Text = $VLANImport[1].name
            #Set the Appliance IP
            $TxtAppIP2.Text = $VLANImport[1].applianceIp
    
            #Manipulate the subnet
            $TxtCIDR2.Text = $VLANImport[1].subnet.SubString($VLANImport[1].subnet.Length - 3)
            $TxtBxNet2Range.Text = $VLANImport[1].subnet -replace ".{3}$"
    
            #DNS Configuration
            #Check if it's Internal DNS
            if($VLANImport[1].dnsNameservers -ne "upstream_dns"){
                $ChkIDNS2.Checked = $true
                $ChkPDNS2.Checked = $false
                #Import our DNS Servers and set it in our text boxes
                $VLAN2DNSImp = $VLANImport[1].dnsNameservers | ConvertFrom-String
                $TxtBxNS2.Text = $VLAN2DNSImp.P1
                $TxtBxNS22.Text = $VLAN2DNSImp.P2
            }
            #Check if it's Proxy
            if($VLANImport[1].dnsNameservers -eq "upstream_dns"){
                $ChkPDNS2.Checked = $true
                $ChkIDNS2.Checked = $false
                $TxtBxNS2.Text = ""
                $TxtBxNS22.Text = ""
            }
    
            #Second VLAN/DHCP Configuration
            Set-ColoredLine $TxtBxOutput Black ("Creating DHCP Global Variables..." + "`r`n")
            $Global:V2DHCPOpt = $VLANImport[1].dhcpOptions
            $Global:V2FIPs = $VLANImport[1].fixedIpAssignments
            $Global:V2resIpRanges = $VLANImport[1].reservedIpRanges
    
            Set-ColoredLine $TxtBxOutput Green ("Created V2DHCPOpt: " + $Global:V2DHCPOpt + "Created V2FixedIP:" + $Global:V2FixedIP + "Created V2resIpRanges:" + $Global:V2resIpRanges + "`r`n")
    
            Set-ColoredLine $TxtBxOutput Green ("Second VLAN entry configuration complete." + "`r`n")
        }
        if ($VLANImport[2] -ne $null){
            Set-ColoredLine $TxtBxOutput Black ("Configuring Third VLAN entry configuration from import." + "`r`n")
            #Third VLAN Entry
            #VLAN Configuration
            $V3VLAN.Text = $VLANImport[2].id
            #Set the VLAN Name
            $TxtBx3VLANName.Text = $VLANImport[2].name
            #Set the Appliance IP
            $TxtAppIP3.Text = $VLANImport[2].applianceIp
    
            #Manipulate the subnet
            $TxtCIDR3.Text = $VLANImport[2].subnet.SubString($VLANImport[2].subnet.Length - 3)
            $TxtBxNet3Range.Text = $VLANImport[2].subnet -replace ".{3}$"
    
            #DNS Configuration
            #Check if it's Internal DNS
            if($VLANImport[2].dnsNameservers -ne "upstream_dns"){
                $ChkIDNS3.Checked = $true
                $ChkPDNS3.Checked = $false
                #Import our DNS Servers and set it in our text boxes
                $VLAN3DNSImp = $VLANImport[2].dnsNameservers | ConvertFrom-String
                $TxtBxNS3.Text = $VLAN3DNSImp.P1
                $TxtBxNS33.Text = $VLAN3DNSImp.P2
            }
            #Check if it's Proxy
            if($VLANImport[2].dnsNameservers -eq "upstream_dns"){
                $ChkPDNS3.Checked = $true
                $ChkIDNS3.Checked = $false
                $TxtBxNS3.Text = ""
                $TxtBxNS33.Text = ""
            }
    
            #Third VLAN/DHCP Configuration
            Set-ColoredLine $TxtBxOutput Black ("Creating DHCP Global Variables..." + "`r`n")
            $Global:V3DHCPOpt = $VLANImport[2].dhcpOptions
            $Global:V3FIPs = $VLANImport[2].fixedIpAssignments
            $Global:V3resIpRanges = $VLANImport[2].reservedIpRanges
    
            Set-ColoredLine $TxtBxOutput Green ("Created V3DHCPOpt: " + $Global:V3DHCPOpt + "Created V3FixedIP:" + $Global:V3FixedIP + "Created V3resIpRanges:" + $Global:V3resIpRanges + "`r`n")
    
            Set-ColoredLine $TxtBxOutput Green ("Third VLAN entry configuration complete." + "`r`n")
}
            Set-ColoredLine $TxtBxOutput Green ("VLAN Import from:" + $TxBxNetNameImport.Text + " complete." + "`r`n")
}
}
catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
        Set-ColoredLine $TxtBxOutput Red ("Error! Network is not compatible for VLAN Import. It's likely the network is in a single LAN configuration." + "`r`n")
}
    
Update-MNCTStatus -Running $false
}
if ($TxBxNetNameImport.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
}
})
$BtnTimezoneImport.Add_Click({
    if ($TxBxNetNameImport.Text -ne ''){
        Update-MNCTStatus -Running $true
            
        Set-ColoredLine $TxtBxOutput Black ('Importing Timezone from ' + $TxBxNetNameImport.Text + "`r`n")
            
        #Read our Import Org Combo Box for the Org ID
        Set-OrgImportv0
    
        try{
            #Grab the network ID of the selected network
            $GetNetworkID = $BaseURL + '/organizations/' + $OrgID + '/networks'
            $request = Invoke-RestMethod -Method GET -Uri $GetNetworkID -Headers $headers
            $ComboTimeZone.Text = ($request | Where-Object {$_.name -eq $TxBxNetNameImport.Text}).timeZone
            Set-ColoredLine $TxtBxOutput Black ((($request | Where-Object {$_.name -eq $TxBxNetNameImport.Text}).timeZone | ConvertTo-Json) + "`r`n")
    
            #Export Variable
            $Global:TZExport = ($request | Where-Object {$_.name -eq $TxBxNetNameImport.Text}).timeZone
    
            #Create Logging in GUI
            Set-ColoredLine $TxtBxOutput Green ('Timezone has been imported from ' + $TxBxNetNameImport.Text + "`r`n")
        }
        catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
        }
    
        Update-MNCTStatus -Running $false
    }
    if ($TxBxNetNameImport.Text -eq ''){
        Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
    }
})
$BtnImportIDS.Add_Click({
if ($TxBxNetNameImport.Text -ne ''){
    Update-MNCTStatus -Running $true
        
    #Read our Import Org Combo Box for the Org ID
    Set-OrgImportv1
    
    Get-NetworkImportID
        
    try{
        $Global:IDSData = $null
        Set-ColoredLine $TxtBxOutput Black ("Attempting Intrusion Detection import from: " + $TxBxNetNameImport.Text + "`r`n")
        #Grab the Malware security settings
        $GetIDS = $BaseURL + '/networks/' + $NetworkID + '/appliance/security/intrusion'
        $Global:IDSData = Invoke-RestMethod -Method GET -Uri $GetIDS -Headers $headers
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($Global:IDSData | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Green ("Intrusion Detection settings have been imported!" + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
            if ($null -eq $Global:IDSData){
                Set-ColoredLine $TxtBxOutput Red ('An error occured when attempting IDS import. You cannot import IDS configuration from a network that does not support it.' + "`r`n")       
            }
            if ($null -ne $Global:IDSData){
            Get-CurrentLine
            $break
            }
    }
    
    Update-MNCTStatus -Running $false
}
if ($TxBxNetNameImport.Text -eq ''){
    Set-ColoredLine $TxtBxOutput Red ('Error! No Network name or incorrect network name selected. Please select an existing network name before continuing.' + "`r`n")
}
})
#Import everything
$BtnImportAll.Add_Click({
#FW Imports
$BtnFWImport.PerformClick()
$BtnFW7Import.PerformClick()
#Tag Imports
$BtnTagImport.PerformClick()
#Import Device Types
$BtnImportDT.PerformClick()
#Import Content Filtering
$BtnImportCFilter.PerformClick()
#import Location
$BtnImportLoc.PerformClick()
#Import Traffic rule shaping
$BtnImportTRS.PerformClick()
#Import Threat Prot..
$BtnImportTP.PerformClick()
#Import Vlan, DHCP Config
$BtnImportVLAN.PerformClick()
#Import Timezone
$BtnTimezoneImport.PerformClick()
#Import IDS
$BtnImportIDS.PerformClick()
})
    
$BtnExportAll.Add_Click({
Update-MNCTStatus -Running $true
    
#Export everything to file
if (!(Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text))){
    Set-ColoredLine $TxtBxOutput Black ("Creating Network Export Path at: " + ('.\NetworkExports\' + $TxBxNetNameImport.Text) + "`r`n")
    New-Item ('.\NetworkExports\' + $TxBxNetNameImport.Text) -ItemType "directory"
    Set-ColoredLine $TxtBxOutput Green ("Network Export Path created! " + "`r`n")
}
#Export L3FW Rules from network to File
if (Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\L3FW.txt')){
    Set-ColoredLine $TxtBxOutput Black ("Removing old L3FW export... " + "`r`n")
    Remove-Item -Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\L3FW.txt')
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Old L3FW export removed! " + "`r`n")
}
Set-ColoredLine $TxtBxOutput Black ("Creating L3FW Export... " + "`r`n")
($Global:L3FWExport | ConvertTo-Json) >> ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\L3FW.txt')
Set-ColoredLine $TxtBxOutput Green ("L3FW Export Created! " + "`r`n")
    
#Export L7FW Rules from network to File
if (Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\L7FW.txt')){
    Set-ColoredLine $TxtBxOutput Black ("Removing old L7FW Export... " + "`r`n")
    Remove-Item -Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\L7FW.txt')
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Old L7FW export removed! " + "`r`n")
}
Set-ColoredLine $TxtBxOutput Black ("Creating L7FW Export... " + "`r`n")
($Global:L7FWExport | ConvertTo-Json) >> ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\L7FW.txt')
Set-ColoredLine $TxtBxOutput Green ("L7FW Export Created! " + "`r`n")
    
#Export Tags from network to File
if (Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Tags.txt')){
    Set-ColoredLine $TxtBxOutput Black ("Removing old tag export... " + "`r`n")
    Remove-Item -Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Tags.txt')
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Old tag export removed! " + "`r`n")
}
Set-ColoredLine $TxtBxOutput Black ("Creating Tag Export... " + "`r`n")
($Global:TagExport | ConvertTo-Json) >> ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Tags.txt')
Set-ColoredLine $TxtBxOutput Green ("Tag Export Created! " + "`r`n")
    
#Export Device Types from network to File
if (Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Devices.txt')){
    Set-ColoredLine $TxtBxOutput Black ("Removing old Device Type export... " + "`r`n")
    Remove-Item -Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Devices.txt')
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Old Device Type export removed! " + "`r`n")
}
Set-ColoredLine $TxtBxOutput Black ("Creating Device Export... " + "`r`n")
($Global:DevExport | ConvertTo-Json) >> ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Devices.txt')
Set-ColoredLine $TxtBxOutput Green ("Device Export Created! " + "`r`n")
    
#Export Content Filtering  from network to File
if (Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\ContentFiltering.txt')){
    Set-ColoredLine $TxtBxOutput Black ("Removing old ContentFiltering export... " + "`r`n")
    Remove-Item -Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\ContentFiltering.txt')
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Old Content Filtering export removed! " + "`r`n")
}
Set-ColoredLine $TxtBxOutput Black ("Creating Content Filtering Export... " + "`r`n")
($Global:ContentFiltering | ConvertTo-Json) >> ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\ContentFiltering.txt')
Set-ColoredLine $TxtBxOutput Green ("Content Filtering Export Created! " + "`r`n")
    
#Export Location from network to File
if (Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Location.txt')){
    Set-ColoredLine $TxtBxOutput Black ("Removing old Location export... " + "`r`n")
    Remove-Item -Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Location.txt')
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Old Location export removed! " + "`r`n")
}
Set-ColoredLine $TxtBxOutput Black ("Creating Location Export... " + "`r`n")
($Global:LocData | ConvertTo-Json) >> ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Location.txt')
Set-ColoredLine $TxtBxOutput Green ("Location Export Created! " + "`r`n")
    
#Export Traffic Shaping from network to File
if (Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\TrafficShaping.txt')){
    Set-ColoredLine $TxtBxOutput Black ("Removing old Traffic Shaping export... " + "`r`n")
    Remove-Item -Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\TrafficShaping.txt')
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Old Traffic Shaping export removed! " + "`r`n")
}
Set-ColoredLine $TxtBxOutput Black ("Creating TrafficShaping Export... " + "`r`n")
($Global:TRSData | ConvertTo-Json) >> ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\TrafficShaping.txt')
Set-ColoredLine $TxtBxOutput Green ("TrafficShaping Export Created! " + "`r`n")
    
#Export Threat Protection from network to File
if (Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\ThreatProtection.txt')){
    Set-ColoredLine $TxtBxOutput Black ("Removing old Threat Protection export... " + "`r`n")
    Remove-Item -Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\ThreatProtection.txt')
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Old Threat Protection export removed! " + "`r`n")
}
Set-ColoredLine $TxtBxOutput Black ("Creating ThreatProtection Export... " + "`r`n")
($Global:SecData | ConvertTo-Json) >> ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\ThreatProtection.txt')
Set-ColoredLine $TxtBxOutput Green ("ThreatProtection Export Created! " + "`r`n")
    
#Export VLAN from network to File
if (Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\VLAN.txt')){
    Set-ColoredLine $TxtBxOutput Black ("Removing old VLAN export... " + "`r`n")
    Remove-Item -Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\VLAN.txt')
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Old VLAN export removed! " + "`r`n")
}
Set-ColoredLine $TxtBxOutput Black ("Creating VLAN Export... " + "`r`n")
($Global:VLANExport | ConvertTo-Json) >> ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\VLAN.txt')
Set-ColoredLine $TxtBxOutput Green ("VLAN Export Created! " + "`r`n")
    
#Export IDS from network to File
if (Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\IDS.txt')){
    Set-ColoredLine $TxtBxOutput Black ("Removing old IDS export... " + "`r`n")
    Remove-Item -Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\IDS.txt')
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Old IDS export removed! " + "`r`n")
}
Set-ColoredLine $TxtBxOutput Black ("Creating IDS Export... " + "`r`n")
($Global:IDSData | ConvertTo-Json) >> ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\IDS.txt')
Set-ColoredLine $TxtBxOutput Green ("IDS Export Created! " + "`r`n")
    
#Export Timezone from network to File
if (Test-Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Timezone.txt')){
    Set-ColoredLine $TxtBxOutput Black ("Removing old Timezone export... " + "`r`n")
    Remove-Item -Path ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Timezone.txt')
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ("Old Timezone export removed! " + "`r`n")
}
Set-ColoredLine $TxtBxOutput Black ("Creating Timezone Export... " + "`r`n")
$ComboTimeZone.Text >> ('.\NetworkExports\' + $TxBxNetNameImport.Text + '\Timezone.txt')
Set-ColoredLine $TxtBxOutput Green ("Timezone Export Created! " + "`r`n")
    
    
Update-MNCTStatus -Running $false
})
#endregion
#########END NET IMPORT SELECTIONS######
    
#########UPDATE NETWORK CONF BTN########
$BtnUpdateNetworkConfig.Add_Click({
$UpdateContinue = $true
#Pre-Checks
if (($optFWRBottom.Checked -eq $true) -and ($optFWRTop.Checked -eq $true)){
        $UpdateContinue = $false
        Set-ColoredLine $TxtBxOutput Red ('Could not update Network! Please check only one option for L3 FW Rules before continuing.' +  "`r`n")
    }
# Start our Updates
if ($UpdateContinue -eq $true){
#Notify the GUI a process is about to start
Update-MNCTStatus -Running $true
    
#This allows updates to be applied just one network
if($ChkUpdateList.Checked -eq $false){
    
$LogFile = 'MNCTNetUpdateLog-' + (get-date -f yyyy-MM-dd) + '.txt'
'Beginning network update steps and procedures ' + (get-date -f yyyy-MM-dd) >> ('.\Logs\' + $LogFile)
#Set up our $vars and info
    
#Define our Organization List
Set-Orgv0
    
    
#Grab our network ID to apply the following changes to
$GetNetworkID = $BaseURL + '/organizations/' + $OrgID + '/networks'
$request = Invoke-RestMethod -Method GET -Uri $GetNetworkID -Headers $headers
$NetworkID = ($request | Where-Object {$_.name -eq $TxtNetworkName.Text}).id
##################################
    
#######NCUU CHECKS###########
if ($NetworkID -ne $null){
    ###Network Name Change#####
    if($optNName.Checked -eq $true){
        if($RadNameOverwrite.Checked -eq $true){
            try{
                Set-ColoredLine $TxtBxOutput Black ('Attempting to change network name from:' + $TxtNetworkName.Text + ' to:' + $TxtBxNameChange.Text + "`r`n")
                            $body  = @{
                    "name" = $TxtBxNameChange.Text
                }
                $ChangeNetName = $BaseURL + '/networks/' + $NetworkID
                $ChangeNetName = Invoke-RestMethod -Method PUT -Uri $ChangeNetName -Headers $headers -body ($body | ConvertTo-Json)
                Set-ColoredLine $TxtBxOutput Green ('Network name now changed to:' + $TxtBxNameChange.Text + "`r`n")
                $TxtNetworkName.Text = $TxtBxNameChange.Text
    
                #Update our Name Lists
                #Grab our network ID for the new network names
                $GetNetNameIndex = $BaseURL + '/organizations/' + $OrgID + '/networks'
                $request = Invoke-RestMethod -Method GET -Uri $GetNetNameIndex -Headers $headers
                $NetworkNameIndex = ($request).Name
                $TxtNetworkName.Items.Clear()
                $TxtNetworkName.Items.AddRange(($NetworkNameIndex | Sort-Object))
    
                #Add this List to our bulk network apply Textbox as well
                $NetListImports = ($NetworkNameIndex | Sort-Object)
                $TxtBxNetList.Text = ''
                            foreach ($NetListImports in $NetListImports){
                $TxtBxNetList.Text = $TxtBxNetList.Text + $NetListImports
                $TxtBxNetList.Text += "`r`n"
            }
    
                #Grab our network ID for the new network names on the import section
                $GetNetNameImportIndex = $BaseURL + '/organizations/' + $OrgID + '/networks'
                $request = Invoke-RestMethod -Method GET -Uri $GetNetNameImportIndex -Headers $headers
                $NetworkImportIndex = ($request).Name
                $TxBxNetNameImport.Items.Clear()
                $TxBxNetNameImport.Items.AddRange(($NetworkImportIndex | Sort-Object))
            }
            catch{ $RESTError = ParseErrorForResponseBody($_)
                Get-CurrentLine
                $break
            }
}
if($RadNameAppend.Checked -eq $true){
    #Add our New Name Appended to the end of the current name listed on the network
    if ($RadNameEnd.Checked -eq $true){
        $body  = @{
            "name" = $TxtNetworkName.Text + $TxtBxNameChange.Text
        }
        Set-ColoredLine $TxtBxOutput Black ('Attempting to change network name from:' + $TxtNetworkName.Text + ' to:' + $TxtNetworkName.Text + $TxtBxNameChange.Text + "`r`n")
    }
    
    #Add our New Name Appended to the front of the current name listed on the network
    if ($RadNameFront.Checked -eq $true){
        $body  = @{
            "name" = $TxtBxNameChange.Text + $TxtNetworkName.Text
        }
        Set-ColoredLine $TxtBxOutput Black ('Attempting to change network name from:' + $TxtNetworkName.Text + ' to:' + $TxtBxNameChange.Text + $TxtNetworkName.Text + "`r`n")
}
    
if (($RadNameFront.Checked -eq $true) -or ($RadNameEnd.Checked -eq $true)) {
    try{
    $ChangeNetName = $BaseURL + '/networks/' + $NetworkID
    $ChangeNetName = Invoke-RestMethod -Method PUT -Uri $ChangeNetName -Headers $headers -body ($body | ConvertTo-Json)
    if ($RadNameEnd.Checked -eq $true){
        Set-ColoredLine $TxtBxOutput Green ('Network name now changed to:' + ($TxtNetworkName.Text + $TxtBxNameChange.Text) + "`r`n")
        $TxtNetworkName.Text = $TxtNetworkName.Text + $TxtBxNameChange.Text
    }
    if ($RadNameFront.Checked -eq $true){
        Set-ColoredLine $TxtBxOutput Green ('Network name now changed to:' + ($TxtBxNameChange.Text + $TxtNetworkName.Text) + "`r`n")
        $TxtNetworkName.Text = $TxtBxNameChange.Text + $TxtNetworkName.Text
    }
    
    
    #Update our name Lists
    #Grab our network ID for the new network names
    $GetNetNameIndex = $BaseURL + '/organizations/' + $OrgID + '/networks'
    $request = Invoke-RestMethod -Method GET -Uri $GetNetNameIndex -Headers $headers
    $NetworkNameIndex = ($request).Name
    $TxtNetworkName.Items.Clear()
    $TxtNetworkName.Items.AddRange(($NetworkNameIndex | Sort-Object))
    
    #Add this List to our bulk network apply Textbox as well
    $NetListImports = ($NetworkNameIndex | Sort-Object)
    $TxtBxNetList.Text = ''
    foreach ($NetListImports in $NetListImports){
        $TxtBxNetList.Text = $TxtBxNetList.Text + $NetListImports
        $TxtBxNetList.Text += "`r`n"
    }
    
    #Grab our network ID for the new network names on the import section
    $GetNetNameImportIndex = $BaseURL + '/organizations/' + $OrgID + '/networks'
    $request = Invoke-RestMethod -Method GET -Uri $GetNetNameImportIndex -Headers $headers
    $NetworkImportIndex = ($request).Name
    $TxBxNetNameImport.Items.Clear()
    $TxBxNetNameImport.Items.AddRange(($NetworkImportIndex | Sort-Object))
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
}
    
else{Set-ColoredLine $TxtBxOutput Red ('Please Select Overwrite or Append to continue to change the network name. Please also verify that if using Append, Select F for Front or E for End to apply the name additions.')}
}
}
    ####VLANS####
    if($optVLANs.Checked -eq $true){
    try{
    #Grab what current VLANS we have to check if we need to create new entries
    $GetNetVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans'
    $VLANList = Invoke-RestMethod -Method Get -Uri $GetNetVLAN -Headers $headers
    Set-ColoredLine $TxtBxOutput Black (($VLANList | ConvertTo-Json) + "`r`n")
    #region VLAN1 Commands
#VLAN 1 PUT COMMAND
#First check if we even have valid entries, If there is a VLAN ID in place, we'll continue moving forward
if (($VLANList | Where-Object {$_.id -eq $V1VLAN.Text}).id -eq $V1VLAN.Text){
    if ($V1VLAN.Text -ne ''){
        Set-ColoredLine $TxtBxOutput Black ('Preparing to update first VLAN entry' + "`r`n")
        #If NameOnly is selected
    if($optVNameOnly.Checked -eq $true){
            if($VLANList.id -eq $V1VLAN.Text){
            $body  = @{
                    "id"   = $V1VLAN.Text
                    "name" = $TxtBx1VLANName.Text
                        }
            $UpdateVLANName = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V1VLAN.Text
            $result = Invoke-RestMethod -Method PUT -Uri $UpdateVLANName -Headers $headers -Body ($body | ConvertTo-Json)
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            Set-ColoredLine $TxtBxOutput Black ('Sent PUT request to update first VLAN Entry' + "`r`n")
            Start-Sleep -Seconds 0.25
            }
    }
    #If NameOnly is not Selected (Regular)
    if($optVNameOnly.Checked -eq $false){
        if($VLANList.id -eq $V1VLAN.Text){
            $VlanUpdateSubnet = $true
            foreach($VLANLNum in ($VLANList | Where-Object {$_.id -ne $V1VLAN.Text})){
                if ($VLANLNum.subnet -eq ($TxtBxNet1Range.Text + $TxtCIDR1.Text)){
                    $VlanUpdateSubnet = $false
                }
            }
    if ($VlanUpdateSubnet -eq $true){
        if ($ChkIDNS1.Checked -eq $true){
            #Don't continue until we've looped through and allowed $VlanUpdateSubnet to -eq $true
            $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V1VLAN.Text -name $TxtBx1VLANName.Text -subnet ($TxtBxNet1Range.Text + $TxtCIDR1.Text) -applianceIp $TxtAppIP1.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS1.Text, $TxtBxNS12.Text
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
        if ($ChkPDNS1.Checked -eq $true){
            $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V1VLAN.Text -name $TxtBx1VLANName.Text -subnet ($TxtBxNet1Range.Text + $TxtCIDR1.Text) -applianceIp $TxtAppIP1.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
        Set-ColoredLine $TxtBxOutput Green ('Sent PUT request to update first VLAN Entry' + "`r`n")
    }
    if ($VlanUpdateSubnet -eq $false){
        Set-ColoredLine $TxtBxOutput Red ('There was an attempt to update the VLAN over another existing subnet. This action has been cancelled.' + "`r`n")
    }
        Start-Sleep -Seconds 0.25
        }
    }
    Set-ColoredLine $TxtBxOutput Green ('Update on first VLAN entry complete!' + "`r`n")
}
}
    
#If that fails, then check if we need to create a new VLAN
#Create New VLAN for Entry 1
if($optVNameOnly.Checked -eq $false){
    if (($VLANList | Where-Object {$_.id -eq $V1VLAN.Text}).id -ne $V1VLAN.Text){
        if($V1VLAN.Text -ne ''){
            #Don't continue until we've looped through and allowed $VlanCreation to -eq $true
            $VLANCreation = $true
            #First, Check if there's any current subnet conflicts (i.e. there is already a subnet that equals this)
            foreach($VLANLNum in $VLANList.subnet){
                if (($TxtBxNet1Range.Text + $TxtCIDR1.Text) -eq $VLANLNum){
                    $VLANCreation = $false
                }
            }
        if ($VLANCreation -eq $true){
            Set-ColoredLine $TxtBxOutput Black ('Preparing to create first VLAN entry' + "`r`n")
            if ($ChkIDNS1.Checked -eq $true){
                $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V1VLAN.Text -name $TxtBx1VLANName.Text -subnet ($TxtBxNet1Range.Text + $TxtCIDR1.Text) -applianceIp $TxtAppIP1.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS1.Text, $TxtBxNS12.Text
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            }
            if ($ChkPDNS1.Checked -eq $true){
                $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V1VLAN.Text -name $TxtBx1VLANName.Text -subnet ($TxtBxNet1Range.Text + $TxtCIDR1.Text) -applianceIp $TxtAppIP1.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            }
            Set-ColoredLine $TxtBxOutput Green ('Creation of first VLAN entry complete!' + "`r`n")
        }
        if ($VLANCreation -eq $false){
            Set-ColoredLine $TxtBxOutput Red ('There is already a network with the same subnet in this network. Please try an new subnet.' + "`r`n")
        }
        }
    }
}
#END First VLAN COMMANDS
#endregion
    
    #region VLAN2 Commands
#VLAN 2 PUT COMMAND
#First check if we even have valid entries, If there is a VLAN ID in place, we'll continue moving forward
if (($VLANList | Where-Object {$_.id -eq $V2VLAN.Text}).id -eq $V2VLAN.Text){
    if ($V2VLAN.Text -ne ''){
        Set-ColoredLine $TxtBxOutput Black ('Preparing to update second VLAN entry' + "`r`n")
        #If NameOnly is selected
        if($optVNameOnly.Checked -eq $true){
            if($VLANList.id -eq $V2VLAN.Text){
                $body  = @{
                        "id"   = $V2VLAN.Text
                        "name" = $TxtBx2VLANName.Text
                }
                $UpdateVLANName = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V2VLAN.Text
                $result = Invoke-RestMethod -Method PUT -Uri $UpdateVLANName -Headers $headers -Body ($body | ConvertTo-Json)
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Green ('Sent PUT request to update second VLAN Entry' + "`r`n")
                Start-Sleep -Seconds 0.25
            }
        }
    #If NameOnly is not Selected (Regular)
    if($optVNameOnly.Checked -eq $false){
        if($VLANList.id -eq $V2VLAN.Text){
            $VlanUpdateSubnet = $true
            foreach($VLANLNum in ($VLANList | Where-Object {$_.id -ne $V2VLAN.Text})){
                if ($VLANLNum.subnet -eq ($TxtBxNet2Range.Text + $TxtCIDR2.Text)){
                    $VlanUpdateSubnet = $false
                }
            }
        if ($VlanUpdateSubnet -eq $true){
            if ($ChkIDNS2.Checked -eq $true){
                #Don't continue until we've looped through and allowed $VlanUpdateSubnet to -eq $true
                $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V2VLAN.Text -name $TxtBx2VLANName.Text -subnet ($TxtBxNet2Range.Text + $TxtCIDR2.Text) -applianceIp $TxtAppIP2.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS2.Text, $TxtBxNS22.Text
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            }
        if ($ChkPDNS2.Checked -eq $true){
            $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V2VLAN.Text -name $TxtBx2VLANName.Text -subnet ($TxtBxNet2Range.Text + $TxtCIDR2.Text) -applianceIp $TxtAppIP2.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
        Set-ColoredLine $TxtBxOutput Green ('Sent PUT request to update second VLAN Entry' + "`r`n")
    }
    if ($VlanUpdateSubnet -eq $false){
        Set-ColoredLine $TxtBxOutput Red ('There was an attempt to update the VLAN over another existing subnet. This action has been cancelled.' + "`r`n")
    }
Start-Sleep -Seconds 0.25
    }
    }
    Set-ColoredLine $TxtBxOutput Green ('Update on second VLAN entry complete!' + "`r`n")
}
}
    
#If that fails, then check if we need to create a new VLAN
#Create New VLAN for Entry 2
if($optVNameOnly.Checked -eq $false){
    if (($VLANList | Where-Object {$_.id -eq $V2VLAN.Text}).id -ne $V2VLAN.Text){
        if($V2VLAN.Text -ne ''){
            #Don't continue until we've looped through and allowed $VlanCreation to -eq $true
            $VLANCreation = $true
            #second, Check if there's any current subnet conflicts (i.e. there is already a subnet that equals this)
            foreach($VLANLNum in $VLANList.subnet){
                if (($TxtBxNet2Range.Text + $TxtCIDR2.Text) -eq $VLANLNum){
                    $VLANCreation = $false
                }
            }
            if ($VLANCreation -eq $true){
                Set-ColoredLine $TxtBxOutput Black ('Preparing to create second VLAN entry' + "`r`n")
                if ($ChkIDNS2.Checked -eq $true){
                    $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V2VLAN.Text -name $TxtBx2VLANName.Text -subnet ($TxtBxNet2Range.Text + $TxtCIDR2.Text) -applianceIp $TxtAppIP2.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS2.Text, $TxtBxNS22.Text
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                }
                if ($ChkPDNS2.Checked -eq $true){
                    $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V2VLAN.Text -name $TxtBx2VLANName.Text -subnet ($TxtBxNet2Range.Text + $TxtCIDR2.Text) -applianceIp $TxtAppIP2.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                }
                Set-ColoredLine $TxtBxOutput Green ('Creation of second VLAN entry complete!' + "`r`n")
            }
            if ($VLANCreation -eq $false){
                Set-ColoredLine $TxtBxOutput Red ('There is already a network with the same subnet in this network. Please try an new subnet.' + "`r`n")
            }
        }
    }
}
#END second VLAN COMMANDS
#endregion
    
    #region VLAN3 Commands
#VLAN 3 PUT COMMAND
#First check if we even have valid entries, If there is a VLAN ID in place, we'll continue moving forward
if (($VLANList | Where-Object {$_.id -eq $V3VLAN.Text}).id -eq $V3VLAN.Text){
    if ($V3VLAN.Text -ne ''){
        Set-ColoredLine $TxtBxOutput Black ('Preparing to update third VLAN entry' + "`r`n")
        #If NameOnly is selected
    if($optVNameOnly.Checked -eq $true){
            if($VLANList.id -eq $V3VLAN.Text){
                $body  = @{
                    "id"   = $V3VLAN.Text
                    "name" = $TxtBx3VLANName.Text
                }
                $UpdateVLANName = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V3VLAN.Text
                $result = Invoke-RestMethod -Method PUT -Uri $UpdateVLANName -Headers $headers -Body ($body | ConvertTo-Json)
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Green ('Sent PUT request to update third VLAN Entry' + "`r`n")
                Start-Sleep -Seconds 0.25
            }
    }
    #If NameOnly is not Selected (Regular)
    if($optVNameOnly.Checked -eq $false){
        if($VLANList.id -eq $V3VLAN.Text){
            $VlanUpdateSubnet = $true
            foreach($VLANLNum in ($VLANList | Where-Object {$_.id -ne $V3VLAN.Text})){
                if ($VLANLNum.subnet -eq ($TxtBxNet3Range.Text + $TxtCIDR3.Text)){
                    $VlanUpdateSubnet = $false
                }
            }
            if ($VlanUpdateSubnet -eq $true){
                if ($ChkIDNS3.Checked -eq $true){
                    #Don't continue until we've looped through and allowed $VlanUpdateSubnet to -eq $true
                    $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V3VLAN.Text -name $TxtBx3VLANName.Text -subnet ($TxtBxNet3Range.Text + $TxtCIDR3.Text) -applianceIp $TxtAppIP3.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS3.Text, $TxtBxNS33.Text
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                }
                if ($ChkPDNS3.Checked -eq $true){
                    $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V3VLAN.Text -name $TxtBx3VLANName.Text -subnet ($TxtBxNet3Range.Text + $TxtCIDR3.Text) -applianceIp $TxtAppIP3.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                }
                Set-ColoredLine $TxtBxOutput Green ('Sent PUT request to update third VLAN Entry' + "`r`n")
            }
        if ($VlanUpdateSubnet -eq $false){
            Set-ColoredLine $TxtBxOutput Red ('There was an attempt to update the VLAN over another existing subnet. This action has been cancelled.' + "`r`n")
        }
        Start-Sleep -Seconds 0.25
        }
    }
    Set-ColoredLine $TxtBxOutput Green ('Update on third VLAN entry complete!' + "`r`n")
    }
}
    
#If that fails, then check if we need to create a new VLAN
#Create New VLAN for Entry 3
if($optVNameOnly.Checked -eq $false){
    if (($VLANList | Where-Object {$_.id -eq $V3VLAN.Text}).id -ne $V3VLAN.Text){
        if($V3VLAN.Text -ne ''){
            #Don't continue until we've looped through and allowed $VlanCreation to -eq $true
            $VLANCreation = $true
            #second, Check if there's any current subnet conflicts (i.e. there is already a subnet that equals this)
            foreach($VLANLNum in $VLANList.subnet){
                if (($TxtBxNet3Range.Text + $TxtCIDR3.Text) -eq $VLANLNum){
                    $VLANCreation = $false
                }
            }
            if ($VLANCreation -eq $true){
                Set-ColoredLine $TxtBxOutput Black ('Preparing to create third VLAN entry' + "`r`n")
                if ($ChkIDNS3.Checked -eq $true){
                    $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V3VLAN.Text -name $TxtBx3VLANName.Text -subnet ($TxtBxNet3Range.Text + $TxtCIDR3.Text) -applianceIp $TxtAppIP3.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS3.Text, $TxtBxNS33.Text
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                }
                if ($ChkPDNS3.Checked -eq $true){
                    $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V3VLAN.Text -name $TxtBx3VLANName.Text -subnet ($TxtBxNet3Range.Text + $TxtCIDR3.Text) -applianceIp $TxtAppIP3.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                }
                Set-ColoredLine $TxtBxOutput Green ('Creation of third VLAN entry complete!' + "`r`n")
            }
            if ($VLANCreation -eq $false){
                Set-ColoredLine $TxtBxOutput Red ('There is already a network with the same subnet in this network. Please try an new subnet.' + "`r`n")
            }
        }
    }
}
#END third VLAN COMMANDS
#endregion
    
    if ($V1VLAN.Text -ne '' -or $V2VLAN.Text -ne '' -or $V3VLAN.Text -ne ''){
        Set-ColoredLine $TxtBxOutput Green ('VLAN Configuration has now been applied successfully.' + "`r`n")
    }
    if ($V1VLAN.Text -eq '' + $V2VLAN.Text -eq '' + $V3VLAN.Text -eq ''){
        Set-ColoredLine $TxtBxOutput Red ('VLAN Configuration changes were attempted, however no changes were made due to invalid or unspecified VLAN IDs in MNCT.' + "`r`n")
    }
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    }
###SSID Config####
if($optSSID.Checked -eq $true){
    try{
        $Global:Continue = $true
        ############SSID CHECKS###############
        #Checks that there isnt a PSK and Open config on the SSID, various failsafes
        Set-ColoredLine $TxtBxOutput Black ('Validating SSID configuration checks before applying.' + "`r`n")
    
        Validate-SSIDs
    
        ############END SSID CHECKS###########
        if ($Global:Continue -eq $true){
            New-SSID
    
            Set-ColoredLine $TxtBxOutput Green ('SSID update completed successfully.' + "`r`n")
        }
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
        }
}
###Net Tags#####
#Do two different options depending if we're overwriting the tags or just appending new tags
#Net Tag Overwrites
if($optNTag.Checked -eq $true -and $RadTagOverwrite.Checked -eq $true){
    try {
    if($NTagOptSubnet.Checked -eq $true){
        #Add Network subnets of a network to tags
        #Grab what current VLANS we have to check if we need to create new entries
        $GetVLANSubnets = $BaseURL + '/networks/' + $NetworkID + '/vlans'
        $VLANSubnets = Invoke-RestMethod -Method Get -Uri $GetVLANSubnets -Headers $headers
        Set-ColoredLine $TxtBxOutput Black (($VLANSubnets | ConvertTo-Json) + "`r`n")
        $TxtBxNetTag.Text += ' ' + $VLANSubnets.subnet
    }
        Set-ColoredLine $TxtBxOutput Black ('Beginning to update network tags on network:' + $TxtNetworkName.Text + "`r`n")
        $body  = @{
                "tags" = $TxtBxNetTag.Text
        }
    
        #Send the Request with the pertinent information:
        $TagUpdateURI = $BaseURL + '/networks/' + $NetworkID
        $request = Invoke-RestMethod -Method PUT -Uri $TagUpdateURI -Headers $headers -Body ($body | ConvertTo-Json)
        Set-ColoredLine $TxtBxOutput Black (($request | ConvertTo-Json) + "`r`n")
        #return the request
        Set-ColoredLine $TxtBxOutput Green ('Network Tags: ' + $TxtBxNetTag.Text + ' has been added.' + "`r`n")
        }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
        }
}
#Net Tag Appends
if($optNTag.Checked -eq $true -and $RadTagAppend.Checked -eq $true){
    try{
    if($NTagOptSubnet.Checked -eq $true){
        #Add Network subnets of a network to tags
        #Grab what current VLANS we have to check if we need to create new entries
        $GetVLANSubnets = $BaseURL + '/networks/' + $NetworkID + '/vlans'
        $VLANSubnets = Invoke-RestMethod -Method Get -Uri $GetVLANSubnets -Headers $headers
        Set-ColoredLine $TxtBxOutput Black (($VLANSubnets | ConvertTo-Json) + "`r`n")
        $TxtBxNetTag.Text += ' ' + $VLANSubnets.subnet
    }
    Set-ColoredLine $TxtBxOutput Black ('Beginning to update network tags on network:' + $TxtNetworkName.Text + "`r`n")
    
    #Grab our existing network Tags to apply the following changes to
    $GetNetTags = $BaseURL + '/organizations/' + $OrgID + '/networks'
    $request = Invoke-RestMethod -Method GET -Uri $GetNetTags -Headers $headers
    $NetTags = ($request | Where-Object {$_.name -eq $TxtNetworkName.Text}).tags
    
    $body  = @{
            "tags" = ($TxtBxNetTag.Text + $NetTags)
    }
    #Send the Request with the pertinent information:
    $TagUpdateURI = $BaseURL + '/networks/' + $NetworkID
    $request = Invoke-RestMethod -Method PUT -Uri $TagUpdateURI -Headers $headers -Body ($body | ConvertTo-Json)
    Set-ColoredLine $TxtBxOutput Black (($request | ConvertTo-Json) + "`r`n")
    #return the request
    Set-ColoredLine $TxtBxOutput Black ('Network Tags: ' + ($TxtBxNetTag.Text + $NetTags) + ' has been added.' + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
}
###FW Rules#####
if($optFWR.Checked -eq $true){
    #Check to see if FWR was checked, but the top and bottom options were not selected. In this case we will default.
    if (($optFWRBottom.Checked -eq $false) -and ($optFWRTop.Checked -eq $false)){
        $optFWRBottom.Checked = $true
    }
        
    #Apply rules to the bottom
    if ($optFWRBottom.Checked -eq $true){
        try{
        Get-MrkNetworkMXL3FwRule -networkId $NetworkID
        #Delete the catch all deny, then auto apply it to the bottom after the new rules have been added
        Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment "Catch All Deny" -policy deny -protocol any -srcPort any -srcCidr any -destPort any -destCidr any -action remove
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Black ('Moving Default Catch all deny rule to bottom of ruleset' + "`r`n")
        #Update Mrk Network MX FW
                foreach ($json in $json){
                    $result = Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment $json.comment -policy $json.policy -protocol $json.protocol -srcPort $json.srcPort -srcCidr $json.srcCidr -destPort $json.destPort -destCidr $json.destCidr -action add
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                    Set-ColoredLine $TxtBxOutput Black ('Firewall Rule: ' + '(' + $json.comment + ')' + ' was added to the network' + "`r`n")
                    Start-Sleep -Seconds 0.25
                                        }
        #Add back the catch all deny, apply it as the last rule
        Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment "Catch All Deny" -policy deny -protocol any -srcPort Any -srcCidr Any -destPort Any -destCidr Any -action add
        Set-ColoredLine $TxtBxOutput Black ('All rules have now been added.' + "`r`n")
        }
        catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
    }
    #Apply rules to the top
    if ($optFWRTop.Checked -eq $true){
        try{
        #Grab our current rules, then we reapply them after adding our import
        $CurFWRules = Get-MrkNetworkMXL3FwRule -networkId $NetworkID
    
        #Remove the existing, then re-add back after the application of the import rules
        foreach ($CurFWRule in $CurFWRules){
            Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment $CurFWRule.comment -policy $CurFWRule.policy -protocol $CurFWRule.protocol -srcPort $CurFWRule.srcPort -srcCidr $CurFWRule.srcCidr -destPort $CurFWRule.destPort -destCidr $CurFWRule.destCidr -action remove
        }
    
        #Adding our import rules
        foreach ($json in $json){
                $result = Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment $json.comment -policy $json.policy -protocol $json.protocol -srcPort $json.srcPort -srcCidr $json.srcCidr -destPort $json.destPort -destCidr $json.destCidr -action add
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Black ('Firewall Rule: ' + '(' + $json.comment + ')' + ' was added to the network' + "`r`n")
                Start-Sleep -Seconds 0.25
        }
    
        #Add our existing rules back on
        foreach ($CurFWRule in $CurFWRules){
            Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment $CurFWRule.comment -policy $CurFWRule.policy -protocol $CurFWRule.protocol -srcPort $CurFWRule.srcPort -srcCidr $CurFWRule.srcCidr -destPort $CurFWRule.destPort -destCidr $CurFWRule.destCidr -action add
        }
        }
        catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
    }
}
###L7FW Rules###
if($optL7FWR.Checked -eq $true){
    #This is for Importing from File
    if($L7json.rules -eq $null){
        try{
        Get-MrkNetworkMXL7FwRule -networkID $NetworkID
        foreach($L7json in $global:L7json){
            $result = Update-MrkNetworkMXL7FwRule -networkId $NetworkID -policy $L7json.policy -type $L7json.type -value $L7json.value -action add
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            Set-ColoredLine $TxtBxOutput Black ('L7 Firewall Rule: ' + '(' + $L7json.value.name + ')' + ' was added to the network' + "`r`n")
        }
        }
        catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
#After rule update, set our json back to its global variable.
$L7json = $Global:L7json
    
}
#This is for Importing from a Network
if($L7json.rules -ne $null){
    try{
        Get-MrkNetworkMXL7FwRule -networkID $NetworkID
        foreach($L7json in $global:L7json.rules){
            $result = Update-MrkNetworkMXL7FwRule -networkId $NetworkID -policy $L7json.policy -type $L7json.type -value $L7json.value -action add
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            Set-ColoredLine $TxtBxOutput Black ('L7 Firewall Rule: ' + '(' + $L7json.value.name + ')' + ' was added to the network' + "`r`n")
    
        }
        #After rule update, set our json back to its global variable.
        $L7json = $Global:L7json
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    
    }
}
}
####Devices#####
if($optDevices.Checked -eq $true){
#Now, Claim Devices, API will attempt to claim any serials added into the new network.
Function Claim-NetDevice{
Set-Orgv1
    
#Begin logging the events in the Text Output
Set-ColoredLine $TxtBxOutput Black ('Attempting to add devices into the network, please wait' + "`r`n")
    
#Build out our loop
$serialnum = 0
do {
    if ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum] -ne ''){
        try{
            Set-ColoredLine $TxtBxOutput Black ('Adding ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) +  ' into the network, please wait' + "`r`n")
            $result = New-MrkDevice -Networkid $NetworkID -serial ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum])
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            Set-ColoredLine $TxtBxOutput Green ('Device: ' +  ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ', was added into the network.' + "`r`n")
                #Check if Tags have been entered, and if they need to be added
                if (($TxtBxDevTag.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Tags: ' + ($TxtBxDevTag.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) +  ' into the network, please wait' + "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + $TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]
                        $tags = ($TxtBxDevTag.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                            
                        $body = @{
                            "tags" =@( $tags.Split("") )
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device tags on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' have been added.' + "`r`n")
                        $tags = $null
                    }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
                #Check if Notes have been entered, and if they need to be added
                if(($TxtBxDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Notes: ' + ($TxtBxDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) + ' to device: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) +  "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum])
                        $body = @{
                            "notes" = ($TxtBxDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device notes on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' have been added.' + "`r`n")
                        }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
                #Check if addresses have been entered, and if they need to be added
                if (($TxtBxDevAddress.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Address: ' + ($TxtBxDevAddress.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) +  ' into the network, please wait' + "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + $TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]
                        $body = @{
                            "address" = ($TxtBxDevAddress.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device address on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' has been added.' + "`r`n")
                    }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
                #Check if names have been entered, and if they need to be added
                if (($TxtBxDevName.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Name: ' + ($TxtBxDevName.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) +  ' into the network, please wait' + "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + $TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]
                        $body = @{
                            "name" = ($TxtBxDevName.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device Name on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' has been added.' + "`r`n")
                    }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
        }
        catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
    
    }
    $serialnum += 1
    
}while ($serialnum -lt $TxtBxSD.Text.Split("").Where({ $_ -ne ""}).Count)
$serialnum = 0
    
Set-Orgv0
    
if ($TxtBxSD.Text -eq ''){
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('No devices were added to MNCT. Skipping Network device claim procedure' + "`r`n")
}
    
}
Claim-NetDevice
}
if($optAlerts.Checked -eq $true){
    Set-Alerts
}
if($optSyslog.Checked -eq $true){
    Set-Syslog
}
###TRS#####
if($optTRS.Checked -eq $true){
    Set-TrafficShaping
}
###Threat Prot####
if($optTProt.Checked -eq $true){
    Set-ThreatProtection
}
###IDS Configuration###
if ($optIDS.Checked -eq $true){
    Set-IDS
}
####Content Filtering#####
if($optCFilter.Checked -eq $true){
    Set-ContentFiltering
}
###Location#######
if($optLoc.Checked -eq $true){
    Set-Location
}
#Custom API
if($optCustomAPI.Checked -eq $true){
    try{
    #Run Code added in the for loop:
    if ($Global:KnownVar -eq "{0}"){
        $KnownVar = $NetworkID
    }
    if ($Global:KnownVar -eq "{1}"){
        $KnownVar = $OrgID
    }
    
    #Create our magic API
    $Global:APIPath = $Global:APIStartPath + $KnownVar + $Global:APIEndPath
    
    #Rebuild out our API URL Data path
    $Global:APIURI = $Global:APIBURL + $Global:APIPath
    
    #PUT Or POST Commandlet
    if (($Global:APIBMethod -eq 'PUT') -or ($Global:APIBMethod -eq 'POST')){
        #Rebuild out the command which is passed to the main portion of MNCT as an expression
        $Global:APICMD = 'Invoke-RestMethod -Method $Global:APIBMethod -Uri $Global:APIURI  -Headers $headers -Body $Global:APIData'
        $result = Invoke-Expression $Global:APICMD
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    }
    
    #GET Commandlet
    if ($Global:APIBMethod -eq 'GET'){
        #Rebuild out the command which is passed to the main portion of MNCT as an expression
        $Global:APICMD = 'Invoke-RestMethod -Method $Global:APIBMethod -Uri $Global:APIURI  -Headers $headers'
        $APIOutput = Invoke-Expression $Global:APICMD
        Set-ColoredLine $TxtBxOutput Black (($APIOutput | ConvertTo-Json) + "`r`n")
        Set-ColoredLine $TxtBxOutput Black ("Running Command: " +  "Invoke-RestMethod -Method" + " " + $Global:APIBMethod + "-Uri " + $Global:APIURI + " -Headers " + $headers + "on Network: " + $TxtNetworkName.Text +  "`r`n")
        $Output = "NetworkName: " + $TxtNetworkName.Text
        Write-Output $Output >> .\APIBuilder\APIGetOutput\APIOutput.txt
        $APIOutput | ConvertTo-Json >> .\APIBuilder\APIGetOutput\APIOutput.txt
        Write-Output "###################################################################" >> .\APIBuilder\APIGetOutput\APIOutput.txt
        Set-ColoredLine $TxtBxOutput Green ("Command" + " on Network: " + $TxtNetworkName.Text +  "now complete!" + "`r`n")
        Start-Sleep -Seconds 0.25
    }
    $KnownVar = $null
}
    catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
    }
}
    #Log any changes to file after they occur:
    ###Export our logs of this event to file####
    $TxtBxOutput.Text >> ('.\Logs\' + $LogFile)
    ###End Log Export#############
    
    Set-ColoredLine $TxtBxOutput Green ('MNCT Network Update Complete!' + "`r`n" + 'Logs can be found in the root log folder for review' + "`r`n")
    }
}
    
    
#Device-based Updates (Single-Network Only)
###Device Tags#
if($optDevTags.Checked -eq $true){
Set-Orgv1
    
Set-ColoredLine $TxtBxOutput Black ('Attempting to add device tags onto the specified devices.' + "`r`n")
    
#Build out our loop
$serialnum = 0
do {
    if ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum] -ne ''){
                #Check if Tags have been entered, and if they need to be added
                if (($TxtBxDevTag.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Tags: ' + ($TxtBxDevTag.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) +  ' into the network, please wait' + "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + $TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]
                        $tags = ($TxtBxDevTag.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                            
                        $body = @{
                            "tags" =@( $tags.Split("") )
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device tags on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' have been added.' + "`r`n")
                        $tags = $null
                    }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
    }
    $serialnum += 1
    
}while ($serialnum -lt $TxtBxSD.Text.Split("").Where({ $_ -ne ""}).Count)
$serialnum = 0
       
Set-ColoredLine $TxtBxOutput Green ('Device tag addition procedure complete for the specified devices.' + "`r`n")
    
Set-Orgv0
}
###Device Address#
if($optDevAddress.Checked -eq $true){
Set-Orgv1
    
Set-ColoredLine $TxtBxOutput Black ('Attempting to add device address information onto the specified devices.' + "`r`n")
    
#Build out our loop
$serialnum = 0
do {
                #Check if addresses have been entered, and if they need to be added
                if (($TxtBxDevAddress.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Address: ' + ($TxtBxDevAddress.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) +  ' into the network, please wait' + "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + $TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]
                        $body = @{
                            "address" = ($TxtBxDevAddress.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device address on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' has been added.' + "`r`n")
                    }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
    $serialnum += 1
    
}while ($serialnum -lt $TxtBxSD.Text.Split("").Where({ $_ -ne ""}).Count)
$serialnum = 0
       
Set-ColoredLine $TxtBxOutput Green ('Device address addition procedure complete for the specified devices.' + "`r`n")
    
Set-Orgv0
}
###Device Name#
if($optDeviceName.Checked -eq $true){
Set-Orgv1
    
Set-ColoredLine $TxtBxOutput Black ('Attempting to add device name information onto the specified devices.' + "`r`n")
    
#Build out our loop
$serialnum = 0
do {
                #Check if names have been entered, and if they need to be added
                if (($TxtBxDevName.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Name: ' + ($TxtBxDevName.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) +  ' into the network, please wait' + "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + $TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]
                        $body = @{
                            "name" = ($TxtBxDevName.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device name on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' has been added.' + "`r`n")
                    }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
    $serialnum += 1
    
}while ($serialnum -lt $TxtBxSD.Text.Split("").Where({ $_ -ne ""}).Count)
$serialnum = 0
       
Set-ColoredLine $TxtBxOutput Green ('Device name addition procedure complete for the specified devices.' + "`r`n")
    
Set-Orgv0
}
###Device Notes#
if($optDevNote.Checked -eq $true){
Set-Orgv1
Set-ColoredLine $TxtBxOutput Black ('Attempting to add device notes onto the specified devices.' + "`r`n")
#Add Notes to Device if they exist
    
#Build out our loop
$serialnum = 0
do {
    if ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum] -ne ''){
                #Check if Notes have been entered, and if they need to be added
                if(($TxtBxDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) -ne ''){
                    try{
                        Set-ColoredLine $TxtBxOutput Black ('Adding Notes: ' + ($TxtBxDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum]) + ' to device: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) +  "`r`n")
                        $GetDeviceTagURI = $BaseURL + '/devices/' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum])
                        $body = @{
                            "notes" = ($TxtBxDN.Text.Split([Environment]::NewLine).Where({ $_ -ne ""})[$serialnum])
                        }
                        $result = Invoke-RestMethod -Method PUT -Uri $GetDeviceTagURI -Headers $headers -body ($body | ConvertTo-Json)
                        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                        Set-ColoredLine $TxtBxOutput Green ('Device notes on: ' + ($TxtBxSD.Text.Split("").Where({ $_ -ne ""})[$serialnum]) + ' have been added.' + "`r`n")
                        }
                    catch{ $RESTError = ParseErrorForResponseBody($_)
                        Get-CurrentLine
                        $break
                    }
                }
        }
    $serialnum += 1
    
}while ($serialnum -lt $TxtBxSD.Text.Split("").Where({ $_ -ne ""}).Count)
$serialnum = 0
    
Set-ColoredLine $TxtBxOutput Green ('Device note addition procedure complete for the specified devices.' + "`r`n")
Set-Orgv0
}
    
}
    
#This allows updates to be applied to all networks in $TxtBxNetListApply
if($ChkUpdateList.Checked -eq $true){
$LogFile = 'MNCTNetUpdateLog-' + (get-date -f yyyy-MM-dd) + '.txt'
'Beginning network creation steps and procedures ' + (get-date -f yyyy-MM-dd) >> ('.\Logs\' + $LogFile)
    
#Blank out our Logging for fresh results
$TxtBxOutput.Text = ''
#Import our Network List to apply update changes to
$NetBulkImportList = ($TxtBxNetListApply.Text.Split([Environment]::NewLine).Where({ $_ -ne ""}) -ne '')
    
#Set our default tag appends before the loop process
$Global:NetTagDefault = $TxtBxNetTag.Text
    
#Define our Organization List
Set-Orgv0
    
#Gather Network Information
try{
    #Grab the total list of networks in the org, then filter down to our selected networks
    $GetNetworkID = $BaseURL + '/organizations/' + $OrgID + '/networks'
    $NetworkList = Invoke-RestMethod -Method GET -Uri $GetNetworkID -Headers $headers
}
catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
}
    
#Set up our Hash table for API Get Requests (Used to build output later)
$Global:APINetworks =@()
$NetworkBody =@()
    
foreach ($NetBulkImportList in $NetBulkImportList){
if ($NetBulkImportList -ne ""){
#Main Loop
    
Get-NetworkID
    
##################################
    
#######NCUU CHECKS###########
if ($NetworkID -ne $null){
###Network Name Change#####
if($optNName.Checked -eq $true){
if($RadNameAppend.Checked -eq $true){
    try{
        #Add our New Name Appended to the end of the current name listed on the network
        if ($RadNameEnd.Checked -eq $true){
            $body  = @{
                "name" = $NetBulkImportList + $TxtBxNameChange.Text
                        }
            Set-ColoredLine $TxtBxOutput Black ('Attempting to change network name from:' + $TxtNetworkName.Text + ' to:' + $NetBulkImportList + $TxtBxNameChange.Text + "`r`n")
        }
    
        #Add our New Name Appended to the front of the current name listed on the network
        if ($RadNameFront.Checked -eq $true){
            $body  = @{
                "name" = $TxtBxNameChange.Text + $NetBulkImportList
                        }
            Set-ColoredLine $TxtBxOutput Black ('Attempting to change network name from:' + $TxtNetworkName.Text + ' to:' + $TxtBxNameChange.Text + $NetBulkImportList + "`r`n")
        }
    
        if (($RadNameFront.Checked -eq $true) -or ($RadNameEnd.Checked -eq $true)) {
            $ChangeNetName = $BaseURL + '/networks/' + $NetworkID
            $ChangeNetName = Invoke-RestMethod -Method PUT -Uri $ChangeNetName -Headers $headers -body ($body | ConvertTo-Json)
            Set-ColoredLine $TxtBxOutput Black ($ChangeNetName + "`r`n")
    
                if ($RadNameEnd.Checked -eq $true){
                    Set-ColoredLine $TxtBxOutput Black ('Network name now changed to:' + ($NetBulkImportList + $TxtBxNameChange.Text) + "`r`n")
                    $TxtNetworkName.Text = ''
                    }
                if ($RadNameFront.Checked -eq $true){
                    Set-ColoredLine $TxtBxOutput Black ('Network name now changed to:' + ($TxtBxNameChange.Text + $NetBulkImportList) + "`r`n")
                    $TxtNetworkName.Text = ''
                    }
        }
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
    }
}
    
}
####VLANS####
if($optVLANs.Checked -eq $true){
    try{
#Grab what current VLANS we have to check if we need to create new entries
$GetNetVLAN = $BaseURL + '/networks/' + $NetworkID + '/vlans'
$VLANList = Invoke-RestMethod -Method Get -Uri $GetNetVLAN -Headers $headers
Set-ColoredLine $TxtBxOutput Black (($VLANList | ConvertTo-Json) + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
    }
try{
#region VLAN1 Commands
#VLAN 1 PUT COMMAND
#First check if we even have valid entries, If there is a VLAN ID in place, we'll continue moving forward
if (($VLANList | Where-Object {$_.id -eq $V1VLAN.Text}).id -eq $V1VLAN.Text){
    if ($V1VLAN.Text -ne ''){
    Set-ColoredLine $TxtBxOutput Black ('Preparing to update first VLAN entry' + "`r`n")
    #If NameOnly is selected
    if($optVNameOnly.Checked -eq $true){
            if($VLANList.id -eq $V1VLAN.Text){
            $body  = @{
                    "id"   = $V1VLAN.Text
                    "name" = $TxtBx1VLANName.Text
                        }
            $UpdateVLANName = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V1VLAN.Text
            $result = Invoke-RestMethod -Method PUT -Uri $UpdateVLANName -Headers $headers -Body ($body | ConvertTo-Json)
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    Set-ColoredLine $TxtBxOutput Green ('Sent PUT request to update first VLAN Entry' + "`r`n")
    Start-Sleep -Seconds 0.25
    }
    }
    #If NameOnly is not Selected (Regular)
    if($optVNameOnly.Checked -eq $false){
        if($VLANList.id -eq $V1VLAN.Text){
        $VlanUpdateSubnet = $true
        foreach($VLANLNum in ($VLANList | Where-Object {$_.id -ne $V1VLAN.Text})){
            if ($VLANLNum.subnet -eq ($TxtBxNet1Range.Text + $TxtCIDR1.Text)){
                $VlanUpdateSubnet = $false
            }
        }
    if ($VlanUpdateSubnet -eq $true){
        if ($ChkIDNS1.Checked -eq $true){
        #Don't continue until we've looped through and allowed $VlanUpdateSubnet to -eq $true
            $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V1VLAN.Text -name $TxtBx1VLANName.Text -subnet ($TxtBxNet1Range.Text + $TxtCIDR1.Text) -applianceIp $TxtAppIP1.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS1.Text, $TxtBxNS12.Text
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
        if ($ChkPDNS1.Checked -eq $true){
            $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V1VLAN.Text -name $TxtBx1VLANName.Text -subnet ($TxtBxNet1Range.Text + $TxtCIDR1.Text) -applianceIp $TxtAppIP1.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
        Set-ColoredLine $TxtBxOutput Green ('Sent PUT request to update first VLAN Entry' + "`r`n")
    }
    if ($VlanUpdateSubnet -eq $false){
    Set-ColoredLine $TxtBxOutput Red ('There was an attempt to update the VLAN over another existing subnet. This action has been cancelled.' + "`r`n")
    }
    Start-Sleep -Seconds 0.25
    }
    }
    Set-ColoredLine $TxtBxOutput Green ('Update on first VLAN entry complete!' + "`r`n")
}
}
    
#If that fails, then check if we need to create a new VLAN
#Create New VLAN for Entry 1
if($optVNameOnly.Checked -eq $false){
    if (($VLANList | Where-Object {$_.id -eq $V1VLAN.Text}).id -ne $V1VLAN.Text){
        if($V1VLAN.Text -ne ''){
            #Don't continue until we've looped through and allowed $VlanCreation to -eq $true
            $VLANCreation = $true
            #First, Check if there's any current subnet conflicts (i.e. there is already a subnet that equals this)
            foreach($VLANLNum in $VLANList.subnet){
                if (($TxtBxNet1Range.Text + $TxtCIDR1.Text) -eq $VLANLNum){
                $VLANCreation = $false
                }
            }
        if ($VLANCreation -eq $true){
            Set-ColoredLine $TxtBxOutput Black ('Preparing to create first VLAN entry' + "`r`n")
            if ($ChkIDNS1.Checked -eq $true){
            $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V1VLAN.Text -name $TxtBx1VLANName.Text -subnet ($TxtBxNet1Range.Text + $TxtCIDR1.Text) -applianceIp $TxtAppIP1.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS1.Text, $TxtBxNS12.Text
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            }
            if ($ChkPDNS1.Checked -eq $true){
            $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V1VLAN.Text -name $TxtBx1VLANName.Text -subnet ($TxtBxNet1Range.Text + $TxtCIDR1.Text) -applianceIp $TxtAppIP1.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            }
            Set-ColoredLine $TxtBxOutput Green ('Creation of first VLAN entry complete!' + "`r`n")
        }
        if ($VLANCreation -eq $false){
            Set-ColoredLine $TxtBxOutput Red ('There is already a network with the same subnet in this network. Please try an new subnet.' + "`r`n")
        }
        }
    }
}
#END First VLAN COMMANDS
#endregion
}
catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
}
try{
#region VLAN2 Commands
#VLAN 2 PUT COMMAND
#First check if we even have valid entries, If there is a VLAN ID in place, we'll continue moving forward
if (($VLANList | Where-Object {$_.id -eq $V2VLAN.Text}).id -eq $V2VLAN.Text){
    if ($V2VLAN.Text -ne ''){
    Set-ColoredLine $TxtBxOutput Black ('Preparing to update second VLAN entry' + "`r`n")
    #If NameOnly is selected
    if($optVNameOnly.Checked -eq $true){
            if($VLANList.id -eq $V2VLAN.Text){
            $body  = @{
                    "id"   = $V2VLAN.Text
                    "name" = $TxtBx2VLANName.Text
                        }
            $UpdateVLANName = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V2VLAN.Text
            $result = Invoke-RestMethod -Method PUT -Uri $UpdateVLANName -Headers $headers -Body ($body | ConvertTo-Json)
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    Set-ColoredLine $TxtBxOutput Green ('Sent PUT request to update second VLAN Entry' + "`r`n")
    Start-Sleep -Seconds 0.25
    }
    }
    #If NameOnly is not Selected (Regular)
    if($optVNameOnly.Checked -eq $false){
        if($VLANList.id -eq $V2VLAN.Text){
        $VlanUpdateSubnet = $true
        foreach($VLANLNum in ($VLANList | Where-Object {$_.id -ne $V2VLAN.Text})){
            if ($VLANLNum.subnet -eq ($TxtBxNet2Range.Text + $TxtCIDR2.Text)){
                $VlanUpdateSubnet = $false
            }
        }
    if ($VlanUpdateSubnet -eq $true){
        if ($ChkIDNS2.Checked -eq $true){
        #Don't continue until we've looped through and allowed $VlanUpdateSubnet to -eq $true
            $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V2VLAN.Text -name $TxtBx2VLANName.Text -subnet ($TxtBxNet2Range.Text + $TxtCIDR2.Text) -applianceIp $TxtAppIP2.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS2.Text, $TxtBxNS22.Text
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
        if ($ChkPDNS2.Checked -eq $true){
            $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V2VLAN.Text -name $TxtBx2VLANName.Text -subnet ($TxtBxNet2Range.Text + $TxtCIDR2.Text) -applianceIp $TxtAppIP2.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
        Set-ColoredLine $TxtBxOutput Green ('Sent PUT request to update second VLAN Entry' + "`r`n")
    }
    if ($VlanUpdateSubnet -eq $false){
        Set-ColoredLine $TxtBxOutput Red ('There was an attempt to update the VLAN over another existing subnet. This action has been cancelled.' + "`r`n")
    }
    Start-Sleep -Seconds 0.25
    }
    }
    Set-ColoredLine $TxtBxOutput Green ('Update on second VLAN entry complete!' + "`r`n")
}
}
    
#If that fails, then check if we need to create a new VLAN
#Create New VLAN for Entry 2
if($optVNameOnly.Checked -eq $false){
    if (($VLANList | Where-Object {$_.id -eq $V2VLAN.Text}).id -ne $V2VLAN.Text){
        if($V2VLAN.Text -ne ''){
            #Don't continue until we've looped through and allowed $VlanCreation to -eq $true
            $VLANCreation = $true
            #second, Check if there's any current subnet conflicts (i.e. there is already a subnet that equals this)
            foreach($VLANLNum in $VLANList.subnet){
                if (($TxtBxNet2Range.Text + $TxtCIDR2.Text) -eq $VLANLNum){
                $VLANCreation = $false
                }
            }
            if ($VLANCreation -eq $true){
                Set-ColoredLine $TxtBxOutput Black ('Preparing to create second VLAN entry' + "`r`n")
                if ($ChkIDNS2.Checked -eq $true){
                    $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V2VLAN.Text -name $TxtBx2VLANName.Text -subnet ($TxtBxNet2Range.Text + $TxtCIDR2.Text) -applianceIp $TxtAppIP2.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS2.Text, $TxtBxNS22.Text
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                }
                if ($ChkPDNS2.Checked -eq $true){
                    $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V2VLAN.Text -name $TxtBx2VLANName.Text -subnet ($TxtBxNet2Range.Text + $TxtCIDR2.Text) -applianceIp $TxtAppIP2.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                }
                Set-ColoredLine $TxtBxOutput Green ('Creation of second VLAN entry complete!' + "`r`n")
            }
            if ($VLANCreation -eq $false){
                Set-ColoredLine $TxtBxOutput Red ('There is already a network with the same subnet in this network. Please try an new subnet.' + "`r`n")
            }
        }
    }
}
#END second VLAN COMMANDS
#endregion
}
catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
}
try{
#region VLAN3 Commands
#VLAN 3 PUT COMMAND
#First check if we even have valid entries, If there is a VLAN ID in place, we'll continue moving forward
if (($VLANList | Where-Object {$_.id -eq $V3VLAN.Text}).id -eq $V3VLAN.Text){
    if ($V3VLAN.Text -ne ''){
    Set-ColoredLine $TxtBxOutput Black ('Preparing to update third VLAN entry' + "`r`n")
    #If NameOnly is selected
    if($optVNameOnly.Checked -eq $true){
            if($VLANList.id -eq $V3VLAN.Text){
            $body  = @{
                    "id"   = $V3VLAN.Text
                    "name" = $TxtBx3VLANName.Text
                        }
            $UpdateVLANName = $BaseURL + '/networks/' + $NetworkID + '/vlans/' + $V3VLAN.Text
            $result = Invoke-RestMethod -Method PUT -Uri $UpdateVLANName -Headers $headers -Body ($body | ConvertTo-Json)
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
    Set-ColoredLine $TxtBxOutput Green ('Sent PUT request to update third VLAN Entry' + "`r`n")
    Start-Sleep -Seconds 0.25
    }
    }
    #If NameOnly is not Selected (Regular)
    if($optVNameOnly.Checked -eq $false){
        if($VLANList.id -eq $V3VLAN.Text){
        $VlanUpdateSubnet = $true
        foreach($VLANLNum in ($VLANList | Where-Object {$_.id -ne $V3VLAN.Text})){
            if ($VLANLNum.subnet -eq ($TxtBxNet3Range.Text + $TxtCIDR3.Text)){
                $VlanUpdateSubnet = $false
            }
        }
    if ($VlanUpdateSubnet -eq $true){
        if ($ChkIDNS3.Checked -eq $true){
        #Don't continue until we've looped through and allowed $VlanUpdateSubnet to -eq $true
            $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V3VLAN.Text -name $TxtBx3VLANName.Text -subnet ($TxtBxNet3Range.Text + $TxtCIDR3.Text) -applianceIp $TxtAppIP3.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS3.Text, $TxtBxNS33.Text
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
        if ($ChkPDNS3.Checked -eq $true){
            $result = Update-MrkNetworkVLAN -networkId $NetworkID -id $V3VLAN.Text -name $TxtBx3VLANName.Text -subnet ($TxtBxNet3Range.Text + $TxtCIDR3.Text) -applianceIp $TxtAppIP3.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        }
        Set-ColoredLine $TxtBxOutput Green ('Sent PUT request to update third VLAN Entry' + "`r`n")
    }
    if ($VlanUpdateSubnet -eq $false){
        Set-ColoredLine $TxtBxOutput Red ('There was an attempt to update the VLAN over another existing subnet. This action has been cancelled.' + "`r`n")
    }
    Start-Sleep -Seconds 0.25
    }
    }
    Set-ColoredLine $TxtBxOutput Green ('Update on third VLAN entry complete!' + "`r`n")
}
}
    
#If that fails, then check if we need to create a new VLAN
#Create New VLAN for Entry 3
if($optVNameOnly.Checked -eq $false){
    if (($VLANList | Where-Object {$_.id -eq $V3VLAN.Text}).id -ne $V3VLAN.Text){
        if($V3VLAN.Text -ne ''){
            #Don't continue until we've looped through and allowed $VlanCreation to -eq $true
            $VLANCreation = $true
            #second, Check if there's any current subnet conflicts (i.e. there is already a subnet that equals this)
            foreach($VLANLNum in $VLANList.subnet){
                if (($TxtBxNet3Range.Text + $TxtCIDR3.Text) -eq $VLANLNum){
                $VLANCreation = $false
                }
            }
            if ($VLANCreation -eq $true){
                Set-ColoredLine $TxtBxOutput Black ('Preparing to create third VLAN entry' + "`r`n")
                if ($ChkIDNS3.Checked -eq $true){
                    $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V3VLAN.Text -name $TxtBx3VLANName.Text -subnet ($TxtBxNet3Range.Text + $TxtCIDR3.Text) -applianceIp $TxtAppIP3.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers $TxtBxNS3.Text, $TxtBxNS33.Text
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                }
                if ($ChkPDNS3.Checked -eq $true){
                    $result = Add-MrkNetworkVLAN -networkId $NetworkID -id $V3VLAN.Text -name $TxtBx3VLANName.Text -subnet ($TxtBxNet3Range.Text + $TxtCIDR3.Text) -applianceIp $TxtAppIP3.Text -dhcpHandling 'Run a DHCP server' -dnsNameservers "upstream_dns"
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                }
                Set-ColoredLine $TxtBxOutput Green ('Creation of third VLAN entry complete!' + "`r`n")
            }
            if ($VLANCreation -eq $false){
                Set-ColoredLine $TxtBxOutput Red ('There is already a network with the same subnet in this network. Please try an new subnet.' + "`r`n")
            }
        }
    }
}
#END third VLAN COMMANDS
#endregion
}
catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
}
if ($V1VLAN.Text -ne '' -or $V2VLAN.Text -ne '' -or $V3VLAN.Text -ne ''){
Set-ColoredLine $TxtBxOutput Green ('VLAN Configuration has now been applied successfully.' + "`r`n")
}
if ($V1VLAN.Text -eq '' + $V2VLAN.Text -eq '' + $V3VLAN.Text -eq ''){
Set-ColoredLine $TxtBxOutput DarkGoldenrod ('VLAN Configuration changes were attempted, however no changes were made due to invalid or unspecified VLAN IDs in MNCT.' + "`r`n")
}
    
}
###SSID Config####
if($optSSID.Checked -eq $true){
function Set-MrkNetworkSSID {
    <#
    .SYNOPSIS
    Sets propeerties on a given Meraki SSID number on a Meraki network
    PUT {orguri}/networks/{networkId}/ssids/{number}
    .DESCRIPTION
    Gets a list of all Meraki SSIDs on a Meraki network. 
    .EXAMPLE
    Set-MrkNetworkSSID -networkId X_112233445566778899 -number 1 -name "Company Network" -enabled $true -authMode psk -
    .PARAMETER networkId
    specify a networkId, find an id using get-MrkNetworks
    .PARAMETER number
    numbers 0 to 14 to identify the SSID hardcoded numeric value to set/update
    .PARAMETER name
    The name of an SSID
    .PARAMETER enabled
    boolean parameter to specify the state of the SSID [$true/$false]
    .PARAMETER authMode
    ('open', 'psk', 'open-with-radius', '8021x-meraki', '8021x-radius')
    .PARAMETER encryptionMode
    ('wpa', 'wep' or 'wpa-eap')
    .PARAMETER psk
    The passkey for the SSID. This param is only valid if the authMode is 'psk'
    .PARAMETER wpaEncryptionMode
    ('WPA1 and WPA2', 'WPA2 only')
    .PARAMETER splashPage
    The type of splash page for the SSID ('None', 'Click-through splash page', 'Billing', 
    'Password-protected with Meraki RADIUS', 'Password-protected with custom RADIUS', 
    'Password-protected with Active Directory', 'Password-protected with LDAP', 'SMS authentication', 
    'Systems Manager Sentry', 'Facebook Wi-Fi', 'Google OAuth' or 'Sponsored guest').
    This attribute is not supported for template children.
    .PARAMETER radiusServers
    The RADIUS 802.1x servers to be used for authentication. This param is only valid if the authMode is 'open-with-radius' or '8021x-radius'
    host  : IP address of your RADIUS server
    port  : UDP port the RADIUS server listens on for Access-requests
    secret: RADIUS client shared secret
    .PARAMETER radiusCoaEnabled
    If true, Meraki devices will act as a RADIUS Dynamic Authorization Server and will respond to RADIUS Change-of-Authorization and 
    Disconnect messages sent by the RADIUS server.
    .PARAMETER radiusFailoverPolicy
    This policy determines how authentication requests should be handled in the event that all of the configured RADIUS servers are unreachable
    ('Deny access' or 'Allow access')
    .PARAMETER radiusLoadBalancingPolicy
    This policy determines which RADIUS server will be contacted first in an authentication attempt and the ordering of any necessary retry attempts
    ('Strict priority order' or 'Round robin')
    .PARAMETER radiusAccountingEnabled
    Whether or not RADIUS accounting is enabled. This param is only valid if the authMode is 'open-with-radius' or '8021x-radius'
    .PARAMETER radiusAccountingServers
    The RADIUS accounting 802.1x servers to be used for authentication. This param is only valid if the authMode is 'open-with-radius' or '8021x-radius' 
    and radiusAccountingEnabled is 'true'
    host   : IP address to which the APs will send RADIUS accounting messages
    port   : Port on the RADIUS server that is listening for accounting messages
    secret : Shared key used to authenticate messages between the APs and RADIUS server
    .PARAMETER ipAssignmentMode
    The client IP assignment mode ('NAT mode','Bridge mode','Layer 3 roaming','Layer 3 roaming with a concentrator','VPN')
    .PARAMETER useVlanTagging
    Direct trafic to use specific VLANs. This param is only valid with 'Bridge mode' and 'Layer 3 roaming'
    .PARAMETER concentratorNetworkId
    The concentrator to use for 'Layer 3 roaming with a concentrator' or 'VPN'.
    .PARAMETER vlanId
    The VLAN ID used for VLAN tagging. This param is only valid with 'Layer 3 roaming with a concentrator' and 'VPN'
    .PARAMETER defaultVlanId
    The default VLAN ID used for 'all other APs'. This param is only valid with 'Bridge mode' and 'Layer 3 roaming'
    .PARAMETER apTagsAndVlanIds
    The list of tags and VLAN IDs used for VLAN tagging. This param is only valid with 'Bridge mode','Layer 3 roaming'
    tags   : Comma-separated list of AP tags
    vlanId : Numerical identifier that is assigned to the VLAN
    .PARAMETER walledGardenEnabled
    Allow access to a configurable list of IP ranges, which users may access prior to sign-on.
    .PARAMETER walledGardenRanges
    Specify your walled garden by entering space-separated addresses, ranges using CIDR notation, domain names, 
    and domain wildcards (e.g. 192.168.1.1/24 192.168.37.10/32 www.yahoo.com *.google.com). Meraki's splash page is automatically included in your walled garden.
    .PARAMETER minBitrate
    The minimum bitrate in Mbps. ('1','2','5.5','6','9','11','12','18','24','36','48','54')
    .PARAMETER bandSelection
    The client-serving radio frequencies. ('Dual band operation','5 GHz band only','Dual band operation with Band Steering')
    .PARAMETER perClientBandwidthLimitUp
    The upload bandwidth limit in Kbps. (0 represents no limit.)
    .PARAMETER perClientBandwidthLimitDown
    The download bandwidth limit in Kbps. (0 represents no limit.)
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$networkId,
        [Parameter(Mandatory,HelpMessage="Provide a number between 0 and 15")][int]$number,
        [Parameter(Mandatory)][string]$name,
        [Parameter(Mandatory)][bool]$enabled,
        [Parameter()][ValidateSet('None', 'Click-through splash page', 'Billing', 'Password-protected with Meraki RADIUS', 'Password-protected with custom RADIUS', 'Password-protected with Active Directory', 'Password-protected with LDAP', 'SMS authentication', 'Systems Manager Sentry', 'Facebook Wi-Fi', 'Google OAuth', 'Sponsored guest')]
        [String]$splashPage,
        [Parameter(Mandatory)][ValidateSet("open","psk","open-with-radius","8021x-meraki","8021x-radius")][String]$authMode,
        [Parameter()][String]$psk,
        [Parameter(Mandatory)][ValidateSet('wpa','wep','wpa-eap')][String]$encryptionMode,
        [Parameter()][ValidateSet('WPA1 and WPA2','WPA2 only')][String]$wpaEncryptionMode,
        [Parameter(Mandatory)][ValidateSet('NAT mode','Bridge mode','Layer 3 roaming','Layer 3 roaming with a concentrator','VPN')][String]$ipAssignmentMode,
        [Parameter()][ValidateSet('1','2','5.5','6','9','11','12','18','24','36','48','54')][int]$minBitrate,
        [Parameter()][bool]$useVlanTagging,
        [Parameter()][int]$vlanId,
        [Parameter()][int]$defaultVlanId,
        [Parameter()][ValidateSet('Dual band operation', '5 GHz band only', 'Dual band operation with Band Steering')][string]$bandSelection,
        [Parameter()][int]$perClientBandwidthLimitUp,
        [Parameter()][int]$perClientBandwidthLimitDown,
        [Parameter(HelpMessage="format 'servername_or_ip,server_port,secret'")][string[]]$radiusServers,
        [Parameter()][bool]$radiusAccountingEnabled,
        [Parameter(HelpMessage="format 'servername_or_ip,server_port,secret'")][string[]]$radiusAccountingServers,
        [Parameter()][bool]$radiusCoaEnabled,
        [Parameter()][ValidateSet('Deny access','Allow access')][string]$radiusFailoverPolicy,
        [Parameter()][Validateset('Strict priority order','Round robin')][string]$radiusLoadBalancingPolicy,
        [Parameter()]$concentratorNetworkId,
        [Parameter()]$walledGardenEnabled,
        [Parameter()]$walledGardenRanges,
        [Parameter()]$apTagsAndVlanIds
    )
    #validate parameter-dependencies for psk, radius type authentication
    if (($authMode -eq '8021x-radius' -or $authMode -eq 'open-with-radius') -and $null -eq $radiusServers){
        $radiusServers=read-host -Prompt "the radiusserver(s) must be provided. Enter the parameters like 'radiusserver1,port,secret', 'radiusserver2,port,secret', '...' ";$PSBoundParameters += @{radiusServers = '1.2.3.4,1234,qwert'}
    }
    if ($authMode -eq 'psk' -and "" -eq $psk){
        $psk = read-host -Prompt "the psk key must be provided when authMode equals 'psk'";
        $PSBoundParameters += @{psk = $psk}
    }
    if($useVlanTagging -and $ipAssignmentMode -notin 'Bridge mode', 'Layer 3 roaming'){
        Write-Host "useVlanTagging is set to TRUE but the ipAssignmentMode is either not set or not one of 'Bridge mode' or 'Layer 3 roaming'"
        Write-Host "change the ipAssignmentMode or useVlanTagging to FALSE and run the command again"
        break
    }
    if($ipAssignmentMode -in 'Bridge mode', 'Layer 3 roaming' -and $defaultVlanId -eq 0){
        $defaultVlanId = read-host -Prompt "the -defaultVlanId parameter must be provided when ipAssignmentMode equals 'Bridge mode' or 'Layer 3 roaming'. Pls type the id number";
        $PSBoundParameters += @{defaultVlanId = $defaultVlanId}
    }
    if($ipAssignmentMode -in 'Layer 3 roaming with a concentrator', 'VPN' -and $vlanId -eq 0){
        $vlanId = read-host -Prompt "the -vlanId parameter must be provided when ipAssignmentMode equals 'Bridge mode' or 'Layer 3 roaming'. Pls type the id number";
        $PSBoundParameters += @{vlanId = $vlanId}
    }
    
    $body = [PSCustomObject]@{}
    #add the other properties to the $body as noteproperties based on parameter value present or not
    foreach ($key in $PSBoundParameters.keys){
        if($key -eq 'radiusServers' -or $key -eq 'radiusAccountingServers'){
            $valArray = @()
            foreach($serverParam in $PSBoundParameters.item($key)){
                #format like 'servername/ip','serverport','secret'
                $server = $serverParam.split(",")[0]
                $port = $serverParam.split(",")[1]
                $secret = $serverParam.split(",")[2]
                if ($null -eq $secret){$secret = Read-Host -Prompt 'provide the radius-secret for server $server'}
                $value = [pscustomobject]@{
                    host = $server
                    port = $port
                    secret = $secret
                }
                $valArray += $value
            }
            $body | Add-Member -MemberType NoteProperty -Name $key -Value $valArray
        } elseif ($key -ne 'networkId') {
            $body | Add-Member -MemberType NoteProperty -Name $key -Value $PSBoundParameters.item($key)
        }
    }
    #$body | convertto-json
    $request = Invoke-MrkRestMethod -Method PUT -ResourceID ('/networks/' + $networkId + '/ssids/' + $number) -body $body
    return $request
}
$Global:Continue = $true
############SSID CHECKS###############
#Checks that there isnt a PSK and Open config on the SSID, various failsafes
Set-ColoredLine $TxtBxOutput Black ('Validating SSID configuration checks before applying.' + "`r`n")
    
Validate-SSIDs
    
############END SSID CHECKS###########
    
if ($Global:Continue -eq $true){
#First SSID Creation and Checks
#The first SSID entry will always equal 0
#First, Check if there's an entry in the SSID Name, if so, we'll process this and begin building out the SSID configuration
#####WPA Secured configuration#####
$SSIDFile0Loc = '.\SSID\0.txt'
$SSIDFILE0 = (Get-Content $SSIDFile0Loc | ConvertFrom-Json)
#####Open Network configuration####
$SSIDFile1Loc = '.\SSID\1.txt'
$SSIDFILE1 = (Get-Content $SSIDFile1Loc | ConvertFrom-Json)
    
New-SSID
    
Set-ColoredLine $TxtBxOutput Green ('SSID update completed successfully.' + "`r`n")
}
    
}
###Net Tags#####
#Do two different options depending if we're overwriting the tags or just appending new tags
#Net Tag Overwrites
if($optNTag.Checked -eq $true -and $RadTagOverwrite.Checked -eq $true){
if($NTagOptSubnet.Checked -eq $true){
#Add Network subnets of a network to tags
#Grab what current VLANS we have to check if we need to create new entries
try{
$GetVLANSubnets = $BaseURL + '/networks/' + $NetworkID + '/vlans'
$VLANSubnets = Invoke-RestMethod -Method Get -Uri $GetVLANSubnets -Headers $headers
$break
}
catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
    }
#Log
Set-ColoredLine $TxtBxOutput Black ($VLANSubnets + "`r`n")
    
$TxtBxNetTag.Text = $Global:NetTagDefault + ' ' + $VLANSubnets.subnet
}
Set-ColoredLine $TxtBxOutput Black ('Beginning to update network tags on network:' + $NetBulkImportList + "`r`n")
$body  = @{
        "tags" = $TxtBxNetTag.Text
}
try{
#Send the Request with the pertinent information:
$TagUpdateURI = $BaseURL + '/networks/' + $NetworkID
$request = Invoke-RestMethod -Method PUT -Uri $TagUpdateURI -Headers $headers -Body ($body | ConvertTo-Json)
Set-ColoredLine $TxtBxOutput Black (($request | ConvertTo-Json) + "`r`n")
#return the request
Set-ColoredLine $TxtBxOutput Green ('Network Tags: ' + $TxtBxNetTag.Text + ' have been added.' + "`r`n")
}
catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
    }
}
#Net Tag Appends
if($optNTag.Checked -eq $true -and $RadTagAppend.Checked -eq $true){
if($NTagOptSubnet.Checked -eq $true){
#Add Network subnets of a network to tags
#Grab what current VLANS we have to check if we need to create new entries
try{
$GetVLANSubnets = $BaseURL + '/networks/' + $NetworkID + '/vlans'
$VLANSubnets = Invoke-RestMethod -Method Get -Uri $GetVLANSubnets -Headers $headers
Set-ColoredLine $TxtBxOutput Black (($VLANSubnets | ConvertTo-Json) + "`r`n")
    
$TxtBxNetTag.Text = $Global:NetTagDefault + ' ' + ($VLANSubnets | Where-Object { $_.name -ne "Guest" } | Where-Object { $_.name -ne "Guests" }).subnet
}
catch{ $RESTError = ParseErrorForResponseBody($_)
        if ($VLANSubnets.networkID -ne $NetworkID){
            Set-ColoredLine $TxtBxOutput Black ("You cannot updates VLAN subnets to a network  that contains a single LAN" + "`r`n")
        }
        if ($VLANSubnets.networkID -eq $NetworkID){
        Get-CurrentLine
        $break
        }
    }
}
    
Set-ColoredLine $TxtBxOutput Black ('Beginning to update network tags on network:' + $NetBulkImportList + "`r`n")
    
try{
#Grab our existing network Tags to apply the following changes to
$GetNetTags = $BaseURL + '/organizations/' + $OrgID + '/networks'
$request = Invoke-RestMethod -Method GET -Uri $GetNetTags -Headers $headers
$NetTags = ($request | Where-Object {$_.name -eq $NetBulkImportList}).tags
Set-ColoredLine $TxtBxOutput Black (($request | ConvertTo-Json) + "`r`n")
Set-ColoredLine $TxtBxOutput Black ($NetTags + "`r`n")
    
$body  = @{
        "tags" = ($TxtBxNetTag.Text + $NetTags)
}
#Send the Request with the pertinent information:
$TagUpdateURI = $BaseURL + '/networks/' + $NetworkID
$request = Invoke-RestMethod -Method PUT -Uri $TagUpdateURI -Headers $headers -Body ($body | ConvertTo-Json)
Set-ColoredLine $TxtBxOutput Black (($request | ConvertTo-Json) + "`r`n")
#return the request
Set-ColoredLine $TxtBxOutput Green ('Network Tags: ' + ($TxtBxNetTag.Text + $NetTags) + ' have been added.' + "`r`n")
}
catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
    }
}
###FW Rules#####
if($optFWR.Checked -eq $true){
    #Check to see if FWR was checked, but the top and bottom options were not selected. In this case we will default.
    if (($optFWRBottom.Checked -eq $false) -and ($optFWRTop.Checked -eq $false) -and ($optFWRRemove.Checked -eq $false)){
        $optFWRBottom.Checked = $true
    }
    #Apply rules to the bottom
    if ($optFWRBottom.Checked -eq $true){
        try{
        $result = Get-MrkNetworkMXL3FwRule -networkId $NetworkID
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Black ('Beginning to add L3 FW rules to Network: ' + $NetBulkImportList  + "`r`n")
        #Delete the catch all deny, then auto apply it to the bottom after the new rules have been added
        Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment "Catch All Deny" -policy deny -protocol any -srcPort any -srcCidr any -destPort any -destCidr any -action remove
        Set-ColoredLine $TxtBxOutput Black ('Moving Default Catch all deny rule to bottom of ruleset' + "`r`n")
        #Update Mrk Network MX FW
                foreach ($json in $json){
                $result = Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment $json.comment -policy $json.policy -protocol $json.protocol -srcPort $json.srcPort -srcCidr $json.srcCidr -destPort $json.destPort -destCidr $json.destCidr -action add
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Black ('Firewall Rule: ' + '(' + $json.comment + ')' + ' was added to the network' + "`r`n")
                }
        #Add back the catch all deny, apply it as the last rule
        Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment "Catch All Deny" -policy deny -protocol any -srcPort Any -srcCidr Any -destPort Any -destCidr Any -action add
        Set-ColoredLine $TxtBxOutput Green ('All rules have now been added.' + "`r`n")
        #After rule update, set our json back to its global variable.
        $json = $Global:json
        Set-ColoredLine $TxtBxOutput Green ('Network: ' + $NetBulkImportList + " firewall rule update complete!" + "`r`n")
        }
        catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
            }
    }
        
    #Apply rules to the top
    if ($optFWRTop.Checked -eq $true){
        try{
        #Grab our current rules, then we reapply them after adding our import
        $CurFWRules = Get-MrkNetworkMXL3FwRule -networkId $NetworkID
        Set-ColoredLine $TxtBxOutput Black (($CurFWRules | ConvertTo-Json) + "`r`n")
        Set-ColoredLine $TxtBxOutput Black ('Beginning to add L3 FW rules to Network: ' + $NetBulkImportList  + "`r`n")
        #Remove the existing, then re-add back after the application of the import rules
        foreach ($CurFWRule in $CurFWRules){
            Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment $CurFWRule.comment -policy $CurFWRule.policy -protocol $CurFWRule.protocol -srcPort $CurFWRule.srcPort -srcCidr $CurFWRule.srcCidr -destPort $CurFWRule.destPort -destCidr $CurFWRule.destCidr -action remove
        }
    
        #Adding our import rules
        foreach ($json in $json){
                $result = Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment $json.comment -policy $json.policy -protocol $json.protocol -srcPort $json.srcPort -srcCidr $json.srcCidr -destPort $json.destPort -destCidr $json.destCidr -action add
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Black ('Firewall Rule: ' + '(' + $json.comment + ')' + ' was added to the network' + "`r`n")
        }
    
        #Add our existing rules back on
        foreach ($CurFWRule in $CurFWRules){
            Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment $CurFWRule.comment -policy $CurFWRule.policy -protocol $CurFWRule.protocol -srcPort $CurFWRule.srcPort -srcCidr $CurFWRule.srcCidr -destPort $CurFWRule.destPort -destCidr $CurFWRule.destCidr -action add
        }
        Set-ColoredLine $TxtBxOutput Green ('Network: ' + $NetBulkImportList + " firewall rule update complete!" + "`r`n")
        }
        catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
            }
    }
    
    #Remove FW Rules
    if ($optFWRRemove.Checked -eq $true){
            try{
                $result = Get-MrkNetworkMXL3FwRule -networkId $NetworkID
                if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                Set-ColoredLine $TxtBxOutput Red ('Beginning to REMOVE L3 FW rules from Network: ' + $NetBulkImportList  + "`r`n")
                #Update Mrk Network MX FW
                foreach ($json in $json){
                    $result = Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment $json.comment -policy $json.policy -protocol $json.protocol -srcPort $json.srcPort -srcCidr $json.srcCidr -destPort $json.destPort -destCidr $json.destCidr -action remove
                    if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
                    Set-ColoredLine $TxtBxOutput Red ('Firewall Rule: ' + '(' + $json.comment + ')' + ' was removed from the network' + "`r`n")
                #After rule update, set our json back to its global variable.
                $json = $Global:json
                Set-ColoredLine $TxtBxOutput Green ('Network: ' + $NetBulkImportList + " firewall rule removal complete!" + "`r`n")
                }
            }
        catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
            }
    }
    
    }
#L7FW Rules####
if($optL7FWR.Checked -eq $true){
#This is for Importing from File
if($L7json.rules -eq $null){
    try{
        $result = Get-MrkNetworkMXL7FwRule -networkID $NetworkID
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Black ('Beginning to add L7 FW rules to Network: ' + $NetBulkImportList  + "`r`n")
        foreach($L7json in $global:L7json){
            $result = Update-MrkNetworkMXL7FwRule -networkId $NetworkID -policy $L7json.policy -type $L7json.type -value $L7json.value -action add
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            Set-ColoredLine $TxtBxOutput Black ('L7 Firewall Rule: ' + '(' + $L7json.value.name + ')' + ' was added to the network' + "`r`n")
        }
        #After rule update, set our json back to its global variable.
        $L7json = $Global:L7json
        Set-ColoredLine $TxtBxOutput Green ('Network: ' + $NetBulkImportList + " firewall rule update complete!" + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
}
    
#This is for Importing from a Network
if($L7json.rules -ne $null){
    try{
        $result = Get-MrkNetworkMXL7FwRule -networkID $NetworkID
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Black ('Beginning to add L7 FW rules to Network: ' + $NetBulkImportList  + "`r`n")
        foreach($L7json in $global:L7json.rules){
        $result = Update-MrkNetworkMXL7FwRule -networkId $NetworkID -policy $L7json.policy -type $L7json.type -value $L7json.value -action add
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Black ('L7 Firewall Rule: ' + '(' + $L7json.value.name + ')' + ' was added to the network' + "`r`n")
    
        }
        #After rule update, set our json back to its global variable.
        $L7json = $Global:L7json
        Set-ColoredLine $TxtBxOutput Green ('Network: ' + $NetBulkImportList + " firewall rule update complete!" + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
        }
}
}
if($optAlerts.Checked -eq $true){
    Set-Alerts
}
if($optSyslog.Checked -eq $true){
    Set-Syslog
}
###TRS#####
if($optTRS.Checked -eq $true){
    Set-TrafficShaping
}
###Threat Prot####
if($optTProt.Checked -eq $true){
    Set-ThreatProtection
}
###IDS Configuration###
if ($optIDS.Checked -eq $true){
    Set-IDS
}
####Content Filtering#####
if($optCFilter.Checked -eq $true){
    Set-ContentFiltering
}
###Location#######
if($optLoc.Checked -eq $true){
    Set-Location
}
    
if($optCustomAPI.Checked -eq $true){
    try{
        #Run Code added in the for loop:
            if ($Global:KnownVar -eq "{0}"){
            $KnownVar = $NetworkID
            }
            if ($Global:KnownVar -eq "{1}"){
            $KnownVar = $OrgID
            }
    
        #Create our magic API
        $Global:APIPath = $Global:APIStartPath + $KnownVar + $Global:APIEndPath
    
        #Rebuild out our API URL Data path
        $Global:APIURI = $Global:APIBURL + $Global:APIPath
    
            #PUT Or POST Commandlet
            if (($Global:APIBMethod -eq 'PUT') -or ($Global:APIBMethod -eq 'POST')){
            #Rebuild out the command which is passed to the main portion of MNCT as an expression
            $Global:APICMD = 'Invoke-RestMethod -Method $Global:APIBMethod -Uri $Global:APIURI  -Headers $headers -Body $Global:APIData'
            $result = Invoke-Expression $Global:APICMD
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            }
    
            #GET Commandlet
            if ($Global:APIBMethod -eq 'GET'){
            #Rebuild out the command which is passed to the main portion of MNCT as an expression
            $Global:APICMD = 'Invoke-RestMethod -Method $Global:APIBMethod -Uri $Global:APIURI  -Headers $headers'
            $APIOutput = Invoke-Expression $Global:APICMD
            #transform the APIOutput back into Json, which wraps it around the network name as JSON that it was pulled from
    
            $NetworkAPI =@{
                "$NetBulkImportList" = $APIOutput
            }
            Set-ColoredLine $TxtBxOutput Black (($APIOutput | ConvertTo-Json) + "`r`n")
    
            Set-ColoredLine $TxtBxOutput Black ("Running Command: " +  "Invoke-RestMethod -Method" + " " + $Global:APIBMethod + "-Uri " + $Global:APIURI + " -Headers " + $headers + "on Network: " + $NetBulkImportList +  "`r`n")
            Set-ColoredLine $TxtBxOutput Green ("Command" + " on Network: " + $NetBulkImportList +  "now complete!" + "`r`n")
            Start-Sleep -Seconds 0.25
    
            $NetworkBody = @(
                    $NetworkAPI
            )
                
    
            $Global:APINetworks += $NetworkBody
    
            }
    
        $KnownVar = $null
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
}
}
}
}
#Build total JSON config after a full GET loop was made
$Global:APINetworks | ConvertTo-Json -Depth 100 >> '.\APIBuilder\APIGetOutput\APIOutput.txt'
    
#Global Var cleanup
$Global:APINetworks = $null
    
#Update our network lists after batch update if it was ran
if($RadNameAppend.Checked -eq $true){
Set-ColoredLine $TxtBxOutput Black ('Updating our network name lists after name changes' + "`r`n")
    try{
        #Update our name Lists
        #Grab our network ID for the new network names
        $GetNetNameIndex = $BaseURL + '/organizations/' + $OrgID + '/networks'
        $request = Invoke-RestMethod -Method GET -Uri $GetNetNameIndex -Headers $headers
        $NetworkNameIndex = ($request).Name
        $TxtNetworkName.Items.Clear()
        $TxtNetworkName.Items.AddRange(($NetworkNameIndex | Sort-Object))
    
        #Add this List to our bulk network apply Textbox as well
        $NetListImports = ($NetworkNameIndex | Sort-Object)
        $TxtBxNetList.Text = ''
        foreach ($NetListImports in $NetListImports){
        $TxtBxNetList.Text = $TxtBxNetList.Text + $NetListImports
        $TxtBxNetList.Text += "`r`n"
        }
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
    try{
        #Grab our network ID for the new network names on the import section
        $GetNetNameImportIndex = $BaseURL + '/organizations/' + $OrgID + '/networks'
        $request = Invoke-RestMethod -Method GET -Uri $GetNetNameImportIndex -Headers $headers
        $NetworkImportIndex = ($request).Name
        $TxBxNetNameImport.Items.Clear()
        $TxBxNetNameImport.Items.AddRange(($NetworkImportIndex | Sort-Object))
        #Reset our Net List as it will no longer equal the correct names.
        $TxtBxNetListApply.Text = ''
        Set-ColoredLine $TxtBxOutput Green ('Network list updates complete!' + "`r`n")
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
            Get-CurrentLine
            $break
        }
}
    
###Export our logs of this event to file####
$TxtBxOutput.Text >> ('.\Logs\' + $LogFile)
###End Log Export#############
Set-ColoredLine $TxtBxOutput Green ('MNCT Network Update Complete!' + "`r`n" + 'Logs can be found in the root log folder for review' + "`r`n")
}
    
#Notify the GUI a process has ended.
Update-MNCTStatus -Running $false
    
})
#########UPDATE NETWORK CONF BTN########
    
####Create Network######################
$BtnCreateNetwork.Add_Click({
PreNetCreationChecks
if($Global:Continue -eq $true){
$LogFile = 'MNCTNetLog-' + (get-date -f yyyy-MM-dd) + '.txt'
'Beginning network creation steps and procedures ' + (get-date -f yyyy-MM-dd) >> ('.\Logs\' + $LogFile)
#Notify the GUI a process is about to start
Update-MNCTStatus -Running $true
    
#Create the Network
New-Network
    
#We're setting a variable that will try to eliminate the default VLAN only if VLAN 1 is not being used by one of our new VLANs
$global:HasDefaultVLAN = $true
    
#Continuing on if it was able to find our new network, if so create our VLANS, etc.
if ($null -ne $Global:NetworkID){
New-VLAN
    
#Add any Network devices by serial into the new network
Claim-NetDevice
    
###Begin to add any imports into the new network
Set-IDS
Set-Alerts
Set-Syslog
Set-TrafficShaping
Set-Location
Set-ContentFiltering
Set-ThreatProtection
    
#region L3FW Adds
try{
    Get-MrkNetworkMXL3FwRule -networkId $NetworkID
    #Update Mrk Network MX FW
    foreach ($json in $json){
        $result = Update-MrkNetworkMXL3FwRule -networkId $NetworkID -comment $json.comment -policy $json.policy -protocol $json.protocol -srcPort $json.srcPort -srcCidr $json.srcCidr -destPort $json.destPort -destCidr $json.destCidr -action add
        if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
        Set-ColoredLine $TxtBxOutput Black ('Firewall Rule: ' + '(' + $json.comment + ')' + ' was added to the network' + "`r`n")
        Start-Sleep -Seconds 0.5
    }
}
catch{ $RESTError = ParseErrorForResponseBody($_)
    Get-CurrentLine
    $break
}
    
#endregion
    
#region L7FW Adds
#L7 FW Rule apply
#This is for Importing from File
if($L7json.rules -eq $null){
    try{
        Get-MrkNetworkMXL7FwRule -networkID $NetworkID
        foreach($L7json in $global:L7json){
            $result = Update-MrkNetworkMXL7FwRule -networkId $NetworkID -policy $L7json.policy -type $L7json.type -value $L7json.value -action add
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            Set-ColoredLine $TxtBxOutput Black ('L7 Firewall Rule: ' + '(' + $L7json.value.name + ')' + ' was added to the network' + "`r`n")
    
        }
    #After rule update, set our json back to its global variable.
    $L7json = $Global:L7json
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
}
#This is for Importing from a Network
if($L7json.rules -ne $null){
    try{
        Get-MrkNetworkMXL7FwRule -networkID $NetworkID
        foreach($L7json in $global:L7json.rules){
            $result = Update-MrkNetworkMXL7FwRule -networkId $NetworkID -policy $L7json.policy -type $L7json.type -value $L7json.value -action add
            if ($ChkVerbose.Checked -eq $true){Set-ColoredLine $TxtBxOutput Black (($result | ConvertTo-Json) + "`r`n")}
            Set-ColoredLine $TxtBxOutput Black ('L7 Firewall Rule: ' + '(' + $L7json.value.name + ')' + ' was added to the network' + "`r`n")
    
        }
        #After rule update, set our json back to its global variable.
        $L7json = $Global:L7json
    }
    catch{ $RESTError = ParseErrorForResponseBody($_)
        Get-CurrentLine
        $break
    }
}
#endregion
    
#VPN Processing and Configuration
#First, just check if we even selected for VPN configuration. If so, then process it, otherwise skip
if($Chk1VLANVPN.Checked -or $Chk2VLANVPN.Checked -or $Chk3VLANVPN.Checked -eq $true){
    Set-Site2SiteVPN
}
    
if($Chk1VLANVPN.Checked + $Chk2VLANVPN.Checked + $Chk3VLANVPN.Checked -eq $false){
    Set-ColoredLine $TxtBxOutput DarkGoldenrod ('Skipping VPN processing as there were no VPN assignments made in MNCT.' + "`r`n")
}
    
#region SSID Creation
New-SSID
    
###Export our logs of this event to file####
$TxtBxOutput.Text >> ('.\Logs\' + $LogFile)
###End Log Export#############
    
Set-ColoredLine $TxtBxOutput Green ('MNCT Network Creation Complete!' + "`r`n" + 'Logs can be found in the root log folder for review' + "`r`n")
#FIN
}
    
#Notify the GUI a process has ended.
Update-MNCTStatus -Running $false
    
}
})
[void]$MerakiNetworkConfigurationTool.ShowDialog()
    
