Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#region GUI Configuration

$MABuilder                       = New-Object system.Windows.Forms.Form
$MABuilder.ClientSize            = New-Object System.Drawing.Point(791,144)
$MABuilder.text                  = "Meraki API Builder"
$MABuilder.TopMost               = $false
$MABuilder.icon                  = ".\icon.ico"

$LblApiBuilder                   = New-Object system.Windows.Forms.Label
$LblApiBuilder.text              = "Meraki API Builder"
$LblApiBuilder.AutoSize          = $true
$LblApiBuilder.width             = 25
$LblApiBuilder.height            = 10
$LblApiBuilder.location          = New-Object System.Drawing.Point(122,12)
$LblApiBuilder.Font              = New-Object System.Drawing.Font('Segoe UI',14)

$ComboAPICmd                     = New-Object system.Windows.Forms.ComboBox
$ComboAPICmd.text                = "PUT"
$ComboAPICmd.width               = 100
$ComboAPICmd.height              = 20
@('PUT','POST','GET','DELETE') | ForEach-Object {[void] $ComboAPICmd.Items.Add($_)}
$ComboAPICmd.location            = New-Object System.Drawing.Point(9,72)
$ComboAPICmd.Font                = New-Object System.Drawing.Font('Segoe UI',10)

$BtnImportConfig                 = New-Object system.Windows.Forms.Button
$BtnImportConfig.text            = "Import Data"
$BtnImportConfig.width           = 101
$BtnImportConfig.height          = 39
$BtnImportConfig.location        = New-Object System.Drawing.Point(8,98)
$BtnImportConfig.Font            = New-Object System.Drawing.Font('Segoe UI',10)

$TxtBxAPIPath                    = New-Object system.Windows.Forms.TextBox
$TxtBxAPIPath.multiline          = $false
$TxtBxAPIPath.text               = "/networks/"
$TxtBxAPIPath.width              = 72
$TxtBxAPIPath.height             = 20
$TxtBxAPIPath.location           = New-Object System.Drawing.Point(119,72)
$TxtBxAPIPath.Font               = New-Object System.Drawing.Font('Segoe UI',10)

$LblAPIExample                   = New-Object system.Windows.Forms.Label
$LblAPIExample.text              = "Example: /networks/{networkid}/appliance/contentFiltering"
$LblAPIExample.AutoSize          = $true
$LblAPIExample.width             = 25
$LblAPIExample.height            = 10
$LblAPIExample.location          = New-Object System.Drawing.Point(119,47)
$LblAPIExample.Font              = New-Object System.Drawing.Font('Segoe UI',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))

$RadVersion0                     = New-Object system.Windows.Forms.RadioButton
$RadVersion0.text                = "Version 0"
$RadVersion0.AutoSize            = $true
$RadVersion0.width               = 104
$RadVersion0.height              = 20
$RadVersion0.location            = New-Object System.Drawing.Point(18,7)
$RadVersion0.Font                = New-Object System.Drawing.Font('Segoe UI',10)

$RadVersion1                     = New-Object system.Windows.Forms.RadioButton
$RadVersion1.text                = "Version 1+"
$RadVersion1.AutoSize            = $true
$RadVersion1.width               = 104
$RadVersion1.height              = 20
$RadVersion1.location            = New-Object System.Drawing.Point(18,39)
$RadVersion1.Font                = New-Object System.Drawing.Font('Segoe UI',10)

$BtnBuildAPI                     = New-Object system.Windows.Forms.Button
$BtnBuildAPI.text                = "Build API Command"
$BtnBuildAPI.width               = 199
$BtnBuildAPI.height              = 39
$BtnBuildAPI.location            = New-Object System.Drawing.Point(119,98)
$BtnBuildAPI.Font                = New-Object System.Drawing.Font('Segoe UI',10)

$PnlVariableInfo                 = New-Object system.Windows.Forms.Panel
$PnlVariableInfo.height          = 136
$PnlVariableInfo.width           = 242
$PnlVariableInfo.location        = New-Object System.Drawing.Point(544,5)
$PnlVariableInfo.BackColor       = [System.Drawing.ColorTranslator]::FromHtml("#dedede")

$LblKnownVars                    = New-Object system.Windows.Forms.Label
$LblKnownVars.text               = "MNCT Known Variables:"
$LblKnownVars.AutoSize           = $true
$LblKnownVars.width              = 25
$LblKnownVars.height             = 10
$LblKnownVars.location           = New-Object System.Drawing.Point(49,7)
$LblKnownVars.Font               = New-Object System.Drawing.Font('Segoe UI',10)

$LblNetworkVar                   = New-Object system.Windows.Forms.Label
$LblNetworkVar.text              = "{networkid} = {0}"
$LblNetworkVar.AutoSize          = $false
$LblNetworkVar.width             = 190
$LblNetworkVar.height            = 14
$LblNetworkVar.location          = New-Object System.Drawing.Point(8,31)
$LblNetworkVar.Font              = New-Object System.Drawing.Font('Segoe UI',10)

$LblOrgVar                       = New-Object system.Windows.Forms.Label
$LblOrgVar.text                  = "{organizationid} = {1}"
$LblOrgVar.AutoSize              = $false
$LblOrgVar.width                 = 168
$LblOrgVar.height                = 17
$LblOrgVar.location              = New-Object System.Drawing.Point(9,57)
$LblOrgVar.Font                  = New-Object System.Drawing.Font('Segoe UI',10)

$ComboKnownVar                   = New-Object system.Windows.Forms.ComboBox
$ComboKnownVar.text              = "{0}"
$ComboKnownVar.width             = 100
$ComboKnownVar.height            = 20
@('{0}','{1}') | ForEach-Object {[void] $ComboKnownVar.Items.Add($_)}
$ComboKnownVar.location          = New-Object System.Drawing.Point(196,72)
$ComboKnownVar.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$TxtBxAPIPathEnd                 = New-Object system.Windows.Forms.TextBox
$TxtBxAPIPathEnd.multiline       = $false
$TxtBxAPIPathEnd.text            = "/webhooks/httpServers"
$TxtBxAPIPathEnd.width           = 228
$TxtBxAPIPathEnd.height          = 20
$TxtBxAPIPathEnd.location        = New-Object System.Drawing.Point(303,72)
$TxtBxAPIPathEnd.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$lblImportSuccess                = New-Object system.Windows.Forms.Label
$lblImportSuccess.text           = "API is now built!"
$lblImportSuccess.AutoSize       = $true
$lblImportSuccess.visible        = $false
$lblImportSuccess.width          = 25
$lblImportSuccess.height         = 10
$lblImportSuccess.location       = New-Object System.Drawing.Point(143,9)
$lblImportSuccess.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$lblImportSuccess.ForeColor      = [System.Drawing.ColorTranslator]::FromHtml("#67cd3c")

$PnlStatusInfo                   = New-Object system.Windows.Forms.Panel
$PnlStatusInfo.height            = 33
$PnlStatusInfo.width             = 254
$PnlStatusInfo.location          = New-Object System.Drawing.Point(284,5)
$PnlStatusInfo.BackColor         = [System.Drawing.ColorTranslator]::FromHtml("#cfcfcf")

$BtnImportAPICall                = New-Object system.Windows.Forms.Button
$BtnImportAPICall.text           = "Import API Call"
$BtnImportAPICall.width          = 99
$BtnImportAPICall.height         = 39
$BtnImportAPICall.location       = New-Object System.Drawing.Point(325,98)
$BtnImportAPICall.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$BtnSaveAPICall                  = New-Object system.Windows.Forms.Button
$BtnSaveAPICall.text             = "Save API Call"
$BtnSaveAPICall.width            = 99
$BtnSaveAPICall.height           = 39
$BtnSaveAPICall.location         = New-Object System.Drawing.Point(433,98)
$BtnSaveAPICall.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$MABuilder.controls.AddRange(@($LblApiBuilder,$ComboAPICmd,$BtnImportConfig,$TxtBxAPIPath,$LblAPIExample,$RadVersion0,$RadVersion1,$BtnBuildAPI,$PnlVariableInfo,$ComboKnownVar,$TxtBxAPIPathEnd,$PnlStatusInfo,$BtnImportAPICall,$BtnSaveAPICall))
$PnlVariableInfo.controls.AddRange(@($LblKnownVars,$LblNetworkVar,$LblOrgVar))
$PnlStatusInfo.controls.AddRange(@($lblImportSuccess))

#Set GUI Window Preferences
$MABuilder.FormBorderStyle = 'Fixed3D'
$MABuilder.MaximizeBox = $false
#End GUI Window Preferences


#endregion

#region Startup Defaults
$Global:APIDataUploaded = $false
#endregion

#region Action Objects
 #Import our JSON API Data
$BtnImportConfig.Add_Click({
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::CurrentDirectory + '\APIBuilder\SavedAPIData\'
    Filter = 'Import Data (*.txt)|*.txt'
    Title = 'Select API Builder Import Data'}
$FileBrowser.ShowDialog()
if($FileBrowser.FileName -ne ''){
$Global:APIData = (Get-Content $FileBrowser.FileName)
$Global:APIDataUploaded = $true
}
})
#Save our API Call
$BtnSaveAPICall.Add_Click({
$FileBrowser = New-Object System.Windows.Forms.SaveFileDialog -Property @{ 
    InitialDirectory = [Environment]::CurrentDirectory + '\APIBuilder\SavedAPICalls\'
    Filter = 'API Call (*.txt)|*.txt'
    Title = 'Save API Call As'}
$FileBrowser.ShowDialog()
$APISaveInfo =  $FileBrowser.FileName
if ($RadVersion0.Checked -eq $true){
    "0" >> $APISaveInfo
}
if ($RadVersion1.Checked -eq $true){
    "1" >> $APISaveInfo
}
$ComboAPICmd.Text >> $APISaveInfo
$TxtBxAPIPath.Text >> $APISaveInfo
$ComboKnownVar.Text >> $APISaveInfo
$TxtBxAPIPathEnd.Text >> $APISaveInfo

})
#Import our API Call
$BtnImportAPICall.Add_Click({
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::CurrentDirectory + '\APIBuilder\SavedAPICalls\'
    Filter = 'API Call (*.txt)|*.txt'
    Title = 'Select API Call'}
$FileBrowser.ShowDialog()
if($FileBrowser.FileName -ne ''){
$APICallImport = (Get-Content $FileBrowser.FileName)
if (($APICallImport[0]) -eq "0"){
    $RadVersion0.Checked = $true
    $RadVersion1.Checked = $false
}
if (($APICallImport[0]) -eq "1"){
    $RadVersion0.Checked = $false
    $RadVersion1.Checked = $true
}
$ComboAPICmd.Text = $APICallImport[1]
$TxtBxAPIPath.Text = $APICallImport[2]
$ComboKnownVar.Text = $APICallImport[3]
$TxtBxAPIPathEnd.Text = $APICallImport[4]
}
})
$BtnBuildAPI.Add_Click({
#IF = PUT OR POST Commands
 if ($Global:APIData -ne $null){
    if (($ComboAPICmd.Text -eq 'PUT') -or ($ComboAPICmd.Text -eq 'POST')){
        #Only continue if we have one of them selected
        if ($RadVersion0.Checked -ne $false + $RadVersion1.Checked -ne $false){
            #We're using Version 0 of the Meraki API
            if ($RadVersion0.Checked -eq $true){
                 $Global:APIBURL = $Global:BaseURL.Substring(0,$Global:BaseURL.Length -1)
                 $Global:APIBURL = $Global:APIBURL + "0"
            }
            #We're using Version 1 of the Meraki API
            if ($RadVersion1.Checked -eq $true){
                $Global:APIBURL = $Global:BaseURL.Substring(0,$Global:BaseURL.Length -1)
                $Global:APIBURL = $Global:APIBURL + "1"
            }
            if ($Global:APIDataUploaded -eq $true){
                  #Set up our global variables as our selected variable
                  $Global:KnownVar = $ComboKnownVar.Text
                  $Global:APIStartPath = $TxtBxAPIPath.Text
                  $Global:APIEndPath = $TxtBxAPIPathEnd.Text

                  #Create our magic API
                  $Global:APIPath = $Global:APIStartPath + $Global:KnownVar + $Global:APIEndPath

                  #Our built out API URL Data path
                  $Global:APIURI = $Global:APIBURL + $Global:APIPath
                  #Create our Invoke Method
                  $Global:APIBMethod = $ComboAPICmd.Text
    
                  #Build out the command which is passed to the main portion of MNCT as an expression
                  $Global:APICMD = 'Invoke-RestMethod -Method $Global:APIBMethod -Uri $Global:APIURI  -Headers $headers -Body $Global:APIData'
                  $lblImportSuccess.visible = $true
            }
        }
    }
 }
 
#IF = DELETE Command
 if ($Global:APIData -ne $null){
    if ($ComboAPICmd.Text -eq 'DELETE'){
        #Only continue if we have one of them selected
        if ($RadVersion0.Checked -ne $false + $RadVersion1.Checked -ne $false){
            #We're using Version 0 of the Meraki API
            if ($RadVersion0.Checked -eq $true){
                 $Global:APIBURL = $Global:BaseURL.Substring(0,$Global:BaseURL.Length -1)
                 $Global:APIBURL = $Global:APIBURL + "0"
            }
            #We're using Version 1 of the Meraki API
            if ($RadVersion1.Checked -eq $true){
                $Global:APIBURL = $Global:BaseURL.Substring(0,$Global:BaseURL.Length -1)
                $Global:APIBURL = $Global:APIBURL + "1"
            }
            if ($Global:APIDataUploaded -eq $true){
                  #Set up our global variables as our selected variable
                  $Global:KnownVar = $ComboKnownVar.Text
                  $Global:APIStartPath = $TxtBxAPIPath.Text
                  $Global:APIEndPath = $TxtBxAPIPathEnd.Text

                  #Create our magic API
                  $Global:APIPath = $Global:APIStartPath + $Global:KnownVar + $Global:APIEndPath

                  #Our built out API URL Data path
                  $Global:APIURI = $Global:APIBURL + $Global:APIPath
                  #Create our Invoke Method
                  $Global:APIBMethod = $ComboAPICmd.Text
    
                  #Build out the command which is passed to the main portion of MNCT as an expression
                  $Global:APICMD = 'Invoke-RestMethod -Method $Global:APIBMethod -Uri $Global:APIURI  -Headers $headers -Body $Global:APIData'
                  $lblImportSuccess.visible = $true
            }
        }
    }
 }

#IF = GET Command
    if ($ComboAPICmd.Text -eq 'GET'){
        if ($RadVersion0.Checked -ne $false + $RadVersion1.Checked -ne $false){
            #We're using Version 0 of the Meraki API
            if ($RadVersion0.Checked -eq $true){
                 $Global:APIBURL = $Global:BaseURL.Substring(0,$Global:BaseURL.Length -1)
                 $Global:APIBURL = $Global:APIBURL + "0"
            }
            #We're using Version 1 of the Meraki API
            if ($RadVersion1.Checked -eq $true){
                $Global:APIBURL = $Global:BaseURL.Substring(0,$Global:BaseURL.Length -1)
                $Global:APIBURL = $Global:APIBURL + "1"
            }
            #Next, we now build out the command but we're not looking to see if data is imported, simply just build out the command
            #Set up our global variables as our selected variable
            $Global:KnownVar = $ComboKnownVar.Text
            $Global:APIStartPath = $TxtBxAPIPath.Text
            $Global:APIEndPath = $TxtBxAPIPathEnd.Text

            #Create our magic API
            $Global:APIPath = $Global:APIStartPath + $Global:KnownVar + $Global:APIEndPath

            #Our built out API URL Data path
            $Global:APIURI = $Global:APIBURL + $Global:APIPath
            #Create our Invoke Method
            $Global:APIBMethod = $ComboAPICmd.Text
    
            #Build out the command which is passed to the main portion of MNCT as an expression
            $Global:APICMD = 'Invoke-RestMethod -Method $Global:APIBMethod -Uri $Global:APIURI  -Headers $headers'
            $lblImportSuccess.visible = $true
        }
    }


})
#endregion

[void]$MABuilder.ShowDialog()