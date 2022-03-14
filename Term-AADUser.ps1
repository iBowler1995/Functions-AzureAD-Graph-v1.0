function Term-AADUser {

    [CmdletBinding()]
    param (
        [Parameter()]
        [String]$UPN
    )

    <#
		IMPORTANT:
        ===========================================================================
        This script is provided 'as is' without any warranty. Any issues stemming 
        from use is on the user.
        ===========================================================================
		.DESCRIPTION
		This function will terminate an AAD user in the following ways:
        *Adds Z_TERM_ to front of user's displayname (changeable at line 767)
        *Removes all user licenses
        *Removes user from all statically assigned groups
        *Disables user
        Things to change to fit your environment:
        Line 31: Update clientId with your application Id. See https://docs.microsoft.com/en-us/graph/auth-v2-user for more info
		===========================================================================
		.PARAMETER UPN
		REQUIRED - Email/userPrincipalName of user to be termed
		===========================================================================
		.EXAMPLE
		Term-AADUser -UPN bjameson@example.com <--- Terms bjameson@example.com
	#>

    $token = Get-MsalToken -clientid x -tenantid organizations
    $global:header = @{'Authorization' = $token.createauthorizationHeader()}
    function Remove-AADGroupMember {

        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $True)]
            [String]$UPN,
            [Parameter()]
            [Switch]$All,
            [Parameter()]
            [String]$Group,
            [Parameter()]
            [Switch]$Multi,
            [Parameter()]
            [String]$File
        )
        
        function Get-AADUser {
    
            [cmdletbinding()]
            param(
        
                [Parameter()]
                [Switch]$All,
                [Parameter()]
                [String]$UPN
        
            )
            
            
        
            If ($All) {
         
                $uri = "https://graph.microsoft.com/v1.0/users"
                $Users = While (!$NoMoreUsers) {
        
                    Try {
                        
                        $GetUsers = Invoke-RestMethod -uri $uri -headers $header -method GET
    
                    }
                    catch{
                        $ResponseResult = $_.Exception.Response.GetResponseStream()
                        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                        $ResponseBody = $ResponseReader.ReadToEnd()
                        }
                        $ResponseBody
                    $getUsers.value
                    If ($getUsers."@odata.nextlink") {
        
                        $uri = $getUsers."@odata.nextlink"
        
                    }
                    Else {
                    
                        $NoMoreUsers = $True
        
                    }
                }
                $NoMoreUsers = $False
                $Users| select displayName | sort displayName
        
            }
            elseif ($UPN -ne $Null) {
        
                $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
                Try{
                    
                    Invoke-RestMethod -Uri $Uri -Headers $header -Method Get
    
                }
                catch{
                    $ResponseResult = $_.Exception.Response.GetResponseStream()
                    $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                    $ResponseBody = $ResponseReader.ReadToEnd()
                    }
                    $ResponseBody
        
            }
            else {
        
                Write-Host "Please specify individual group or use All switch."
        
            }
        
        }
        function Get-AADGroup {
    
            [cmdletbinding()]
            param(
        
                [Parameter()]
                [Switch]$All,
                [Parameter()]
                [String]$Name
        
            )
            
            If ($All) {
        
                $uri = "https://graph.microsoft.com/v1.0/groups"
                $Groups = While (!$NoMoreGroups) {
        
                    Try{
                        
                        $GetGroups = Invoke-RestMethod -uri $uri -headers $header -method GET
    
                    }
                    catch{
                        $ResponseResult = $_.Exception.Response.GetResponseStream()
                        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                        $ResponseBody = $ResponseReader.ReadToEnd()
                        }
                        $ResponseBody
                    $getGroups.value
                    If ($getGroups."@odata.nextlink") {
        
                        $uri = $getGroups."@odata.nextlink"
        
                    }
                    Else {
                    
                        $NoMoreGroups = $True
        
                    }
                }
                $NoMoreGroups = $False
                $Groups | select displayName | sort displayName
        
            }
            elseif ($Name -ne $Null) {
        
                $Uri = "https://graph.microsoft.com/v1.0/groups"
                $Groups = While (!$NoMoreGroups) {
        
                    Try{
                        
                        $GetGroups = Invoke-RestMethod -uri $uri -headers $header -method GET
    
                    }
                    catch{
                        $ResponseResult = $_.Exception.Response.GetResponseStream()
                        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                        $ResponseBody = $ResponseReader.ReadToEnd()
                        }
                        $ResponseBody
                    $getGroups.value
                    If ($getGroups."@odata.nextlink") {
        
                        $uri = $getGroups."@odata.nextlink"
        
                    }
                    Else {
                    
                        $NoMoreGroups = $True
        
                    }
                }
                $NoMoreGroups = $False
                $Groups | where {$_.displayName -eq $Name}
        
            }
            else {
        
                Write-Host "Please specify individual group or use All switch."
        
            }
        
        }
    
        If ($all){
    
            $GroupsUri = "https://graph.microsoft.com/v1.0/users/$UPN/transitiveMemberOf"
            $GroupRequest = Invoke-RestMethod -Uri $GroupsUri -Headers $Header -Method Get
            $Groups = $GroupRequest | convertfrom-Json
            foreach ($Item in $Groups.value){
    
                $RemoveFrom = Get-AADGroup -Name $Item.displayName
                $UsertoRemove = Get-AADUser -UPN $UPN
                $RemoveFromUri = "https://graph.microsoft.com/v1.0/groups/$($RemoveFrom.Id)/members/$($UsertoRemove.Id)/`$ref"
                Try{
    
                    Invoke-RestMethod -Uri $RemoveFromUri -Headers $header -Method "Delete"
    
                }
                catch{
                    $ResponseResult = $_.Exception.Response.GetResponseStream()
                    $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                    $ResponseBody = $ResponseReader.ReadToEnd()
                    $ResponseBody
                }
    
            }
    
        }
        elseIf (($Group -ne $Null) -and (!$Multi)) {
    
            $UsertoRemove = Get-AADUser -UPN tmctesty@verisma.com
            $RemoveFrom = Get-AADGroup -Name $item
            $RemoveFromUri = "https://graph.microsoft.com/v1.0/groups/$($RemoveFrom.Id)/members/$($UsertoRemove.Id)/`$ref"
            Try{
            
                Invoke-RestMethod -Uri $RemoveFromUri -Headers $header -Method "Delete"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
        
        }
        else {
    
            
            $Groupstoremove = Get-Content $File
            foreach ($G in $Groupstoremove) {
    
                $UsertoRemove = Get-AADUser -UPN $UPN
                $RemoveFrom = Get-AADGroup -Name $G
                $RemoveFromUri = "https://graph.microsoft.com/v1.0/groups/$($RemoveFrom.Id)/members/$($UsertoRemove.Id)/`$ref"
                Try {
                
                    Invoke-RestMethod -Uri $RemoveFromUri -Headers $header -Method "Delete"
    
                }
                catch{
                    $ResponseResult = $_.Exception.Response.GetResponseStream()
                    $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                    $ResponseBody = $ResponseReader.ReadToEnd()
                    }
                    $ResponseBody
    
            }
    
        }
    
    }
    function Disable-AADUser {

        [cmdletbinding()]
        param(
    
            [Parameter()]
            [String]$UPN
    
        )

        $uri = "https://graph.microsoft.com/v1.0/users/$UPN"
        $Body = @{"accountEnabled" = $false} | ConvertTo-Json
        Try {
    
            Invoke-RestMethod -Uri $Uri -Body $body -Headers $Header -Method Patch -ContentType "application/Json"
    
        }
        catch{
            $ResponseResult = $_.Exception.Response.GetResponseStream()
            $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
            $ResponseBody = $ResponseReader.ReadToEnd()
            }
            $ResponseBody
    }
    function Remove-AADUserLicense {

        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $True)]
            [String]$UPN,
            [Parameter()]
            [Switch]$All,
            [Parameter()]
            [Switch]$E3,
            [Parameter()]
            [Switch]$E5,
            [Parameter()]
            [Switch]$ExchangeStd,
            [Parameter()]
            [Switch]$ExchangeEnt,
            [Parameter()]
            [Switch]$Stream,
            [Parameter()]
            [Switch]$Essentials,
            [Parameter()]
            [Switch]$AutomateFree,
            [Parameter()]
            [Switch]$AutomatePro,
            [Parameter()]
            [Switch]$PBIFree,
            [Parameter()]
            [Switch]$PBIPro,
            [Parameter()]
            [Switch]$ProjectPrem,
            [Parameter()]
            [Switch]$ProjectPro,
            [Parameter()]
            [Switch]$Visio,
            [Parameter()]
            [Switch]$WStore
        )

        $E3SkuId = "05e9a617-0261-4cee-bb44-138d3ef5d965"
        $E5SkuId = "06ebc4ee-1bb5-47dd-8120-11324bc54e06"
        $ExStdSkuId = "4b9405b0-7788-4568-add1-99614e613b69"
        $ExEntSkuId = "19ec0d23-8335-4cbd-94ac-6050e30712fa"
        $StreamSkuId = "1f2f344a-700d-42c9-9427-5cea1d5d7ba6"
        $EssentSkuId = "3b555118-da6a-4418-894f-7df1e2096870"
        $FlowFreeSkuId = "f30db892-07e9-47e9-837c-80727f46fd3d"
        $FlowProSkuId = "bc946dac-7877-4271-b2f7-99d2db13cd2c"
        $PBIFreeSkuId = "a403ebcc-fae0-4ca2-8c8c-7a907fd6c235"
        $PBIProSkuId = "f8a1db68-be16-40ed-86d5-cb42ce701560"
        $ProjPremSkuId = "09015f9f-377f-4538-bbb5-f75ceb09358a"
        $ProjProSkuId = "53818b1b-4a27-454b-8896-0dba576410e6"
        $VisioSkuId = "c5928f49-12ba-48f7-ada3-0d743a3601d5"
        $WStoreSkuId = "6470687e-a428-4b7a-bef2-8a291ad947c9"
    
        If ($E3) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($E3SkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
        }
        If ($E5) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($E5SkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
        }
        If ($ExchangeStd) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($ExStdSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
        }
        If ($ExchangeEnt) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($ExEntSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
        }
        If ($Stream) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($StreamSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
        }
        If ($Essentials) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($EssentSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
        }
        If ($AutomateFree) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($FlowFreeSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
        }
        If ($AutomatePro) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($FlowProSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
        }
        If ($PBIFree) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($PBIFreeSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
    
        }
        If ($PBIPro) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($PBIProSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
    
        }
        If ($ProjectPrem) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($ProjPremSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
    
        }
        If ($ProjectPro) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($ProjProSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
    
        }
        If ($Visio) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($VisioSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
    
        }
        If ($WStore) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @()
                removeLicenses = @($WStoreSkuId)
    
            }
            $JSON = $Body | Convertto-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
    
        }
        If ($All) {
    
            $detailUri = "https://graph.microsoft.com/v1.0/users/$UPN/licenseDetails"
            $Licenses = Invoke-RestMethod -Uri $detailUri -Headers $Header -Method Get
            foreach ($License in $Licenses) {
    
                $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
                $Body = @{
    
                    addLicenses = @()
                    removeLicenses = @($License.Value.SkuId)
        
                }
                $JSON = $Body | Convertto-Json
                Try {
        
                    Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
        
                }
                catch{
                    $ResponseResult = $_.Exception.Response.GetResponseStream()
                    $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                    $ResponseBody = $ResponseReader.ReadToEnd()
                    }
                    $ResponseBody
    
            }
    
        }
    
    }
    function Get-AADUser {

        [cmdletbinding()]
        param(
    
            [Parameter()]
            [Switch]$All,
            [Parameter()]
            [String]$UPN
    
        )

    
        If ($All) {
     
            $uri = "https://graph.microsoft.com/v1.0/users"
            $Users = While (!$NoMoreUsers) {
    
                $GetUsers = Invoke-RestMethod -uri $uri -headers $header -method GET
                $getUsers.value
                If ($getUsers."@odata.nextlink") {
    
                    $uri = $getUsers."@odata.nextlink"
    
                }
                Else {
                
                    $NoMoreUsers = $True
    
                }
            }
            $NoMoreUsers = $False
            $Users| select displayName | sort displayName
    
        }
        elseif ($UPN -ne $Null) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
            Try {
            
                Invoke-RestMethod -Uri $Uri -Headers $header -Method Get
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                }
                $ResponseBody
    
        }
        else {
    
            Write-Host "Please specify individual group or use All switch."
    
        }
    
    }
    
    $User = Get-AADUser -UPN $UPN
    $NewName = "Z_Term_$($User.displayName)"
    $displayUri = "https://graph.microsoft.com/v1.0/users/$UPN"
    $displayBody = @{

        "displayName" = $NewName

    }
    $displayJSON = $displayBody | ConvertTo-Json
    Try {
        
        Write-Host "Renaming user $($User.displayName)..." -f White
        Invoke-RestMethod -Uri $displayUri -Headers $header -Method Patch -Body $displayJSON -ContentType "application/Json"
        Write-Host "User renamed to $($User.displayName)." -f Green
        Write-host "===========" -f Green

    }
    catch{
        $ResponseResult = $_.Exception.Response.GetResponseStream()
        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
        $ResponseBody = $ResponseReader.ReadToEnd()
        }
        $ResponseBody


    Write-Host "Removing $UPN from all groups..." -f White
    Try {

        Remove-AADGroupMember -UPN $UPN -All | Out-Null
        Write-Host "User $UPN removed from all groups." -f Green
        Write-host "============" -f Green

    }
    catch{
        $ResponseResult = $_.Exception.Response.GetResponseStream()
        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
        $ResponseBody = $ResponseReader.ReadToEnd()
        }
        $ResponseBody

    Write-Host "Removing all licenses for user $UPN..." -f White
    Try {

        Remove-AADUserLicense -UPN $UPN -All | Out-Null
        Write-Host "All licenses for user $UPN removed." -f Green
        Write-host "============" -f Green

    }
    catch{
        $ResponseResult = $_.Exception.Response.GetResponseStream()
        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
        $ResponseBody = $ResponseReader.ReadToEnd()
        }
        $ResponseBody

    Write-Host "Disabling user $UPN..."-f White
    Try {

        Disable-AADUser -UPN $UPN | Out-Null
        Write-Host "User $UPN disabled." -f Green

    }
    catch{
        $ResponseResult = $_.Exception.Response.GetResponseStream()
        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
        $ResponseBody = $ResponseReader.ReadToEnd()
        }
        $ResponseBody

    
}