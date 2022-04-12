function Get-AADGroup {

    <#
		IMPORTANT:
        ===========================================================================
        This script is provided 'as is' without any warranty. Any issues stemming 
        from use is on the user.
        ===========================================================================
		.DESCRIPTION
		Gets an Azure AD Group
        Things to change to deploy in your environment:
        Line 34: replace x with clientID of your reigstered app. See https://bit.ly/3KApKhJ for more info.
		===========================================================================
		.PARAMETER All
		Lists all AAD groups by displayName.
		.PARAMETER Name
		The displayName of the group to get.
		===========================================================================
		.EXAMPLE
		Get-AADGroup -All <--- This will return all AzureAD groups
		Get-AADGroup -Name Azure-Test <--- This will return the group Azure-Test
	#>

    [cmdletbinding()]
    param(

        [Parameter()]
        [Switch]$All,
        [Parameter()]
        [String]$Name

    )
    
    $token = Get-MsalToken -clientid x -tenantid organizations
    $global:header = @{'Authorization' = $token.createauthorizationHeader();'ConsistencyLevel' = 'eventual'}
    
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