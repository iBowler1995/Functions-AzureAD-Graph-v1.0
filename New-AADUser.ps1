function New-AADUser {

    [CmdletBinding()]
    Param(
    [Parameter(Mandatory = $True)]
    [String]$FName,
    [Parameter(Mandatory = $True)]
    [String]$LName,
    [Parameter(Mandatory = $True)]
    [String]$Title,
    [Parameter(Mandatory = $True)]
    [String]$Office,
    [Parameter(Mandatory = $True)]
    [String]$Manager,
    [Parameter(Mandatory = $True)]
    [String]$Dept,
    [Parameter()]
    [String]$Mobile,
    [Parameter()]
    [String]$Group,
    [Parameter()]
    [Switch]$Multi,
    [Parameter()]
    [String]$File,
    [Parameter()]
    [Switch]$E3,
    [parameter()]
    [Switch]$E5,
    [Parameter()]
    [Switch]$ExchangeStd,
    [Parameter()]
    [Switch]$ExchangeEnt,
    [Parameter()]
    [Switch]$PBIFree,
    [Parameter()]
    [Switch]$PBIPro,
    [Parameter()]
    [Switch]$Visio
    )

    <#
        IMPORTANT:
        ===========================================================================
        This script is provided 'as is' without any warranty. Any issues stemming 
        from use is on the user.
        ===========================================================================
		.DESCRIPTION
		Creates new AzureAD User, assigning specified licenses and groups

        Things to change to work for your environment:
        Line 1188: add your company's domain name after @ for full email address
        Lines 1221 and 1226: replace x with your company name
        Line 96: replace x with clientID of your reigstered app. See https://bit.ly/3KApKhJ for more info.
        ===========================================================================
		.PARAMETER FName
		New user's first name
		.PARAMETER LName
        New user's last name
        .PARAMETER Title
        New user's title
        .PARAMETER Office
        New user's office location
        .PARAMETER Manager
        New user's manager
        .PARAMETER Dept
        New user's department
        .PARAMETER Mobile
        New user's mobile number, if applicable
        .PARAMETER Group
        Specifies displayname of a single group to add new user to
        .PARAMETER Multi
        Switch for adding new user to multiple groups
        .PARAMETER File
        Path to text file containing all the groups new user is to be added to
        .PARAMETER E3
        Switch that assigns Microsoft 365 E3 license to new user
        .PARAMETER E5
        Switch that assigns Microsoft 365 E5 license to new user
        .PARAMETER ExchangeStd
        Switch that assigns Microsoft 365 ExchangeOnline Standard (Plan 1) license to new user
        .PARAMETER ExchangeEnt
        Switch that assigns Microsoft 365 ExchangeOnline Enterprise (Plan 2) license to new user
        .PARAMETER PBIFree
        Switch that assigns Microsoft 365 PowerBI (free) license to new user
        .PARAMETER PBIPro
        Switch that assigns Microsoft 365 PowerBI Pro license to new user
        .PARAMETER Visio
        Switch that assigns Microsoft 365 Visio license to new user
        ===========================================================================
		.EXAMPLE
		New-AADUser -FName Bob -LName Jameson -Title Sr. System's Administrator -Office CA -Manager alex@contoso.com -Dept IT -Mobile 999-999-9999 -Multi -File C:\Temp\Groups.txt -E5 -PBIPro -Visio
        ^--- The above example creates a new user named Bob Jameson, email bjameson@contoso.com, and assign the specified properties to him
	#>

    $token = Get-MsalToken -clientid x -tenantid organizations
	$global:header = @{ 'Authorization' = $token.createauthorizationHeader() }
    function Add-AADGroupMember
	{
		
		[cmdletbinding()]
		param (
			
			[Parameter(Mandatory = $True)]
			[String]$UPN,
			[Parameter()]
			[String]$Group,
			[Parameter()]
			[Switch]$Multi,
			[Parameter()]
			[String]$File
		)

		<#
        IMPORTANT:
        ===========================================================================
        This script is provided 'as is' without any warranty. Any issues stemming 
        from use is on the user.
        ===========================================================================
		.DESCRIPTION
		Adds user to AzureAD Group
        ===========================================================================
		.PARAMETER Group
		DisplayName of the group (how you see it in the GUI)
		.PARAMETER User
		User's email
        .PARAMETER Multi
        Use this switch if you have multiple groups to add a user to. Must be used in conjunction with File parameter
        .PARAMETER File
        Specifies the text file where you store each of the groups you want to add users to
        ===========================================================================
		.EXAMPLE
		Add-AADGroupMember -Group "Azure-Test" -User bob@Contoso.com <--- This will add Bob to the Azure-Test
        Add-AADGroupMember -User bob@contoso.com -Multi -File "C:\Temp\Groups.txt" This will parse the txt file and add user to all groups in it, if they exist
	#>
		
		function Get-AADUser
		{
			
			[cmdletbinding()]
			param (
				
				[Parameter()]
				[Switch]$All,
				[Parameter()]
				[String]$UPN
				
			)
			
			If ($All)
			{
				
				$uri = "https://graph.microsoft.com/v1.0/users"
				$Users = While (!$NoMoreUsers)
				{
					
					Try {

						$GetUsers = Invoke-RestMethod -uri $uri -headers $Header -method GET
						$getUsers.value
						If ($getUsers."@odata.nextlink")
						{
							
							$uri = $getUsers."@odata.nextlink"
							
						}
						Else
						{
							
							$NoMoreUsers = $True
							
						}

					}
					catch{
						$ResponseResult = $_.Exception.Response.GetResponseStream()
						$ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
						$ResponseBody = $ResponseReader.ReadToEnd()
						$ResponseBody
					}

				}
				$NoMoreUsers = $False
				$Users | select displayName | sort displayName
				
			}
			elseif ($UPN -ne $Null)
			{
				
				Try {

					$Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
					Invoke-RestMethod -Uri $Uri -Headers $Header -Method Get

				}
				catch{
                    $ResponseResult = $_.Exception.Response.GetResponseStream()
                    $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                    $ResponseBody = $ResponseReader.ReadToEnd()
                    $ResponseBody
                }
				
			}
			else
			{
				
				Write-Host "Please specify individual group or use All switch."
				
			}
			
		}
		function Get-AADGroup
		{
			
			[cmdletbinding()]
			param (
				
				[Parameter()]
				[Switch]$All,
				[Parameter()]
				[String]$Name
				
			)
			
			If ($All)
			{
				
				$uri = "https://graph.microsoft.com/v1.0/groups"
				$Groups = While (!$NoMoreGroups)
				{
					
					Try {

						$GetGroups = Invoke-RestMethod -uri $uri -headers $Header -method GET
						$getGroups.value
						If ($getGroups."@odata.nextlink")
						{
							
							$uri = $getGroups."@odata.nextlink"
							
						}
						Else
						{
							
							$NoMoreGroups = $True
							
						}

					}
					catch{
						$ResponseResult = $_.Exception.Response.GetResponseStream()
						$ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
						$ResponseBody = $ResponseReader.ReadToEnd()
						$ResponseBody
					}

				}
				$NoMoreGroups = $False
				$Groups | select displayName | sort displayName
				
			}
			elseif ($Name -ne $Null)
			{
				
				$Uri = "https://graph.microsoft.com/v1.0/groups"
				$Groups = While (!$NoMoreGroups)
				{
					
					Try {

						$GetGroups = Invoke-RestMethod -uri $uri -headers $Header -method GET
						$getGroups.value
						If ($getGroups."@odata.nextlink")
						{
							
							$uri = $getGroups."@odata.nextlink"
							
						}
						Else
						{
							
							$NoMoreGroups = $True
							
						}

					}
					catch{
						$ResponseResult = $_.Exception.Response.GetResponseStream()
						$ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
						$ResponseBody = $ResponseReader.ReadToEnd()
						$ResponseBody
					}

				}
				$NoMoreGroups = $False
				$Groups | where { $_.displayName -eq $Name }
				
			}
			else
			{
				
				Write-Host "Please specify individual group or use All switch."
				
			}
			
		}
		
		
		If (($Group -ne $Null) -and (!$Multi))
		{
			
			Try {

				$UserToAdd = Get-AADUser -UPN $UPN
				$AddTo = Get-AADGroup -Name $Group
				$AddtoUri = "https://graph.microsoft.com/v1.0/groups/$($AddTo.Id)/members/`$ref"
				$Body = @{ "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($UserToAdd.Id)" } | ConvertTo-Json
				Invoke-RestMethod -Uri $AddtoUri -Headers $Header -Method "Post" -ContentType "application/json" -Body $Body

			}
			catch{
				$ResponseResult = $_.Exception.Response.GetResponseStream()
				$ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
				$ResponseBody = $ResponseReader.ReadToEnd()
				$ResponseBody
			}
			
		}
		else
		{
			
			
			$GroupsToAdd = Get-Content $File
			foreach ($G in $GroupsToAdd)
			{
				
				Try {

					$UserToAdd = Get-AADUser -UPN $UPN
					$AddTo = Get-AADGroup -Name $G
					$AddtoUri = "https://graph.microsoft.com/v1.0/groups/$($AddTo.Id)/members/`$ref"
					$Body = @{ "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($UserToAdd.Id)" } | ConvertTo-Json
					Invoke-RestMethod -Uri $AddtoUri -Headers $Header -Method "Post" -ContentType "application/json" -Body $Body

				}
				catch{
                    $ResponseResult = $_.Exception.Response.GetResponseStream()
                    $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                    $ResponseBody = $ResponseReader.ReadToEnd()
                    $ResponseBody
                }
				
			}
			
		}
		
	}
    ###########################################################################
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
        
                    Try {
                    
                        $GetGroups = Invoke-RestMethod -uri $uri -headers $header -method GET
    
                    }
                    catch{
                        $ResponseResult = $_.Exception.Response.GetResponseStream()
                        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                        $ResponseBody = $ResponseReader.ReadToEnd()
                        $ResponseBody    
                    }
                        
                    $getGroups.value
                    If ($getGroups."@odata.nextlink") {
            
                        $uri = $getGroups."@odata.nextlink"
            
                    }
                    Else {
                        
                        $NoMoreGroups = $True
            
                    }
                        $NoMoreGroups = $False
                        $Groups | select displayName | sort displayName
        
                }
            elseif ($Name -ne $Null) {
        
                $Uri = "https://graph.microsoft.com/v1.0/groups"
                $Groups = While (!$NoMoreGroups) {
        
                    Try {
                        
                        $GetGroups = Invoke-RestMethod -uri $uri -headers $header -method GET
    
                    }
                    catch{
                        $ResponseResult = $_.Exception.Response.GetResponseStream()
                        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                        $ResponseBody = $ResponseReader.ReadToEnd()
                        $ResponseBody    
                    }
                        
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
    
        
        If (($Group -ne $Null) -and (!$Multi)) {
    
            $UserToAdd = Get-AADUser -UPN $UPN
            $AddTo = Get-AADGroup -Name $Group
            $AddtoUri = "https://graph.microsoft.com/v1.0/groups/$($AddTo.Id)/members/`$ref"
            $Body = @{"@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($UserToAdd.Id)"} | ConvertTo-Json
            Try {
            
                Invoke-RestMethod -Uri $AddtoUri -Headers $header -Method "Post" -ContentType "application/json" -Body $Body
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
        
        }
        else {
    
            
            $GroupsToAdd = Get-Content $File
            foreach ($G in $GroupsToAdd) {
    
                $UserToAdd = Get-AADUser -UPN $UPN
                $AddTo = Get-AADGroup -Name $G
                $AddtoUri = "https://graph.microsoft.com/v1.0/groups/$($AddTo.Id)/members/`$ref"
                $Body = @{"@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($UserToAdd.Id)"} | ConvertTo-Json
                Try{
    
                    Invoke-RestMethod -Uri $AddtoUri -Headers $header -Method "Post" -ContentType "application/json" -Body $Body
    
                }
                catch{
                    $ResponseResult = $_.Exception.Response.GetResponseStream()
                    $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                    $ResponseBody = $ResponseReader.ReadToEnd()
                    $ResponseBody    
                }
                    
    
            }
    
        }
    
    }
    ###########################################################################
    function Assign-AADUserLicense {

        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $True)]
            [String]$UPN,
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
    
                addLicenses = @(@{"skuId" = $E3SkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
        }
        If ($E5) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $E5SkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
        }
        If ($ExchangeStd) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $ExStdSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
        }
        If ($ExchangeEnt) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $ExEntSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
        }
        If ($Stream) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $SteamSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
        }
        If ($Essentials) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $EssentSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
        }
        If ($AutomateFree) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $FlowFreeSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
        }
        If ($AutomatePro) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $FlowProSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
        }
        If ($PBIFree) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $PBIFreeSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
    
        }
        If ($PBIPro) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $PBIProSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
    
        }
        If ($ProjectPrem) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $ProjPremSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
    
        }
        If ($ProjectPro) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $ProjProSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody   
            }
               
    
    
        }
        If ($Visio) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $VisioSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
    
        }
        If ($WStore) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense"
            $Body = @{
    
                addLicenses = @(@{"skuId" = $WStoreSkuId})
                removeLicenses = @()
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Start-Sleep -S 2
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Post -ContentType "application/Json"            
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
    
        }
    
    }
    ###########################################################################
    function Update-AADUser {

        [CmdletBinding()]
        Param(
            [Parameter(Mandatory = $True)]
            [String]$UPN,
            [Parameter()]
            [String]$FName,
            [Parameter()]
            [String]$LName,
            [Parameter()]
            [String]$Title,
            [Parameter()]
            [String]$Office,
            [Parameter()]
            [String]$Manager,
            [Parameter()]
            [String]$Dept,
            [Parameter()]
            [String]$Mobile,
            [Parameter()]
            [String]$Company,
            [Parameter()]
            [Switch]$Location
    
        )
    
        If ($FName){
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
            $Body = @{
    
                "givenName" = $FName
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Patch -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody
            }
            
        }
        If ($LName){
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
            $Body = @{
    
                "surname" = $LName
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Patch -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody
            }
            
        }
        If ($Title){
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
            $Body = @{
    
                "jobTitle" = $Title
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Patch -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody
            }
            
        }
        If ($Office){
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
            $Body = @{
    
                "officeLocation" = $Office
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Patch -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody
            }
            
        }
        If ($Manager){
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN/manager/`$ref"
            $Body = @{
    
                "@odata.id" = "https://graph.microsoft.com/v1.0/users/$Manager"
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Put -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody
            }
            
        }
        If ($Dept){
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
            $Body = @{
    
                "department" = $Dept
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Patch -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody
            }
            
        }
        If ($Mobile){
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
            $Body = @{
    
                "mobilePhone" = $Mobile
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Patch -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody
            }
           
        }
        If ($Location) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
            $Body = @{
    
                "usageLocation" = "US"
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Patch -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody
            }
            
    
        }
        If ($Company) {
    
            $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
            $Body = @{
    
                "companyName" = $Company
    
            }
            $JSON = $Body | ConvertTo-Json
            Try {
    
                Invoke-RestMethod -Uri $Uri -Body $JSON -Headers $Header -Method Patch -ContentType "application/Json"
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody
            }
            
    
        }
    }


    #################################################
    #Generating a secure password
    function GenerateStrongPassword
    {
        param (
            [Parameter(Mandatory)]
            [ValidateRange(4, [int]::MaxValue)]
            [int]$length,
            [int]$upper = 1,
            [int]$lower = 1,
            [int]$numeric = 1,
            [int]$special = 1
        )
        if ($upper + $lower + $numeric + $special -gt $length)
        {
            throw "number of upper/lower/numeric/special char must be lower or equal to length"
        }
        $uCharSet = "ABCDEFGHJKMNPQRSTUWXYZ"
        $lCharSet = "abcdfhjkmnrstuwxyz"
        $nCharSet = "23456789"
        $sCharSet = "/*-+!?=@_"
        $charSet = ""
        if ($upper -gt 0) { $charSet += $uCharSet }
        if ($lower -gt 0) { $charSet += $lCharSet }
        if ($numeric -gt 0) { $charSet += $nCharSet }
        if ($special -gt 0) { $charSet += $sCharSet }
        $charSet = $charSet.ToCharArray()
        $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
        $bytes = New-Object byte[]($length)
        $rng.GetBytes($bytes)
        $result = New-Object char[]($length)
        for ($i = 0; $i -lt $length; $i++)
        {
            $result[$i] = $charSet[$bytes[$i] % $charSet.Length]
        }
        $password = (-join $result)
        $valid = $true
        if ($upper -gt ($password.ToCharArray() | Where-Object { $_ -cin $uCharSet.ToCharArray() }).Count) { $valid = $false }
        if ($lower -gt ($password.ToCharArray() | Where-Object { $_ -cin $lCharSet.ToCharArray() }).Count) { $valid = $false }
        if ($numeric -gt ($password.ToCharArray() | Where-Object { $_ -cin $nCharSet.ToCharArray() }).Count) { $valid = $false }
        if ($special -gt ($password.ToCharArray() | Where-Object { $_ -cin $sCharSet.ToCharArray() }).Count) { $valid = $false }
        if (!$valid)
        {
            $password = RandomPassword $length $upper $lower $numeric $special
        }
        return $password
    }
    
    #################################################
    $Password = GenerateStrongPassword(12)
    Set-Clipboard -Value $Password
    Write-Host "Password copied to clipboard!" -f Green
    #################################################
    #Creating the User
    $Initial = $FName.SubString(0,1)
    $UPN = "$Initial$LName@domain.com"
    $Uri = "https://graph.microsoft.com/v1.0/users"
    $body = @{

        "accountEnabled" = $true;
        "displayName" = "$FName $LName";
        "mailNickname" = "$Initial$LName";
        "passwordProfile" = @{

            "forceChangePasswordNextSignIn" = $True;
            "password" = $Password

        };
        "userPrincipalName" = $UPN

    }
    $JSON = $Body | ConvertTo-Json
    Try {

        Write-Host "Creating user $FName $LName..." -f White
        Invoke-RestMethod -Uri $Uri -Body $JSON -Header $Header -Method Post -ContentType "application/Json" | Out-Null
        Write-Host "================================" -f Green

    }
    catch{
        $ResponseResult = $_.Exception.Response.GetResponseStream()
        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
        $ResponseBody = $ResponseReader.ReadToEnd()
    }
    $ResponseBody
    Start-Sleep -s 5
    If ($Mobile) {

        Update-AADUser -UPN $UPN -FName $FName -LName $LName -Company x -Title $Title -Office $Office -Manager $Manager -Dept $Dept -Mobile $Mobile -Location | out-null

    }
    else{

        Update-AADUser -UPN $UPN -FName $FName -LName $LName -Company x -Title $Title -Office $Office -Manager $Manager -Dept $Dept -Location | out-null

    }
    
    Write-Host "User $Fname $LName created successfully." -f Green
    Write-Host "================================" -f Green
    #################################################

    #Updating the manager
    Start-Sleep -s 4
    Write-Host "Assigning manager $Manager to user $FName $LName..." -f White
    Update-AADUser -UPN $UPN -Manager $Manager | Out-Null
    Write-Host "================================" -f Green
    Write-Host "Manager $Manager assigned to user $FName $LName." -f Green
    Write-Host "================================" -f Green
    Start-Sleep -s 3

    #################################################

    #Assigning Licenses
    If ($E3) {

        Write-Host "Assigning Microsoft 365 E3 license to $FName $LName..." -f White
        Assign-AADUserLicense -UPN $UPN -E3 | Out-Null

    }
    If ($E5) {

        Write-Host "Assigning Microsoft 365 E5 license to $FName $LName..." -f White
        Assign-AADUserLicense -UPN $UPN -E5 | Out-Null

    }
    If ($ExchangeStd){

        Write-Host "Assigning Exchange Online Standard (Plan 1) license to $FName $LName..." -f White
        Assign-AADUserLicense -UPN $UPN -ExchangeStd | Out-Null

    }
    If ($ExchangeEnt){

        Write-Host "Assigning Exchange Online Enterprise (Plan 2) license to $FName $LName..." -f White
        Assign-AADUserLicense -UPN $UPN -ExchangeEnt | Out-Null

    }
    If ($PBIFree){

        Write-Host "Assigning PowerBI Free license to $FName $LName..." -f White
        Assign-AADUserLicense -UPN $UPN -PBIFree | Out-Null

    }
    If ($PBIPro){

        Write-Host "Assigning PowerBI Pro license to $FName $LName..." -f White
        Assign-AADUserLicense -UPN $UPN -PBIPro | Out-Null
 
    }
    If ($Visio){

        Write-Host "Assigning Visio license to $FName $LName..." -f White
        Assign-AADUserLicense -UPN $UPN -Visio | Out-Null

    }
    Write-Host "================================" -f Green

    #################################################

    #Adding to groups
    If ($Multi) {

        If ($File -ne $Null -and $File -ne ""){

            $Fetch = Get-content $File
            foreach ($Line in $Fetch) {

                Write-Host "Adding user $FName $LName to group $Line..." -f White
                Add-AADGroupMember -UPN $UPN -Group $Line | Out-Null
                Write-Host "================================" -f Green
                Write-Host "User $FName $LName added to group $Line." -f Green
                Write-Host "================================" -f Green

        }

        }
        else {
            
            Write-Host "No file specified." -f Red

        }

    }
    elseif ($Group -ne $Null -and $Group -ne ""){

        Write-Host "Adding user $FName $LName to group $Group..." -f White
        Add-AADGroupMember -UPN $UPN -Group $Group | Out-Null
        Write-Host "================================" -f Green
        Write-Host "User $FName $LName added to group $Group." -f Green

    }
}