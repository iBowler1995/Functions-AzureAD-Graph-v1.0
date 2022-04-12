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
		Things to change to deploy in your environment:
		Line 42 - replace x with clientID of your reigstered app. See https://bit.ly/3KApKhJ for more info.
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
		
		$token = Get-MsalToken -clientid x -tenantid organizations
		$global:header = @{ 'Authorization' = $token.createauthorizationHeader() }
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