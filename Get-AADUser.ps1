function Get-AADUser {

    [cmdletbinding()]
    param(

        [Parameter()]
        [Switch]$All,
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
		Gets an Azure AD User
        Things to change to deploy in your environment:
        Line 34: replace x with clientID of your reigstered app. See https://bit.ly/3KApKhJ for more info.
		===========================================================================
		.PARAMETER All
		Lists all AAD users by displayName.
		.PARAMETER Name
		The displayName of the user to get.
		===========================================================================
		.EXAMPLE
		Get-AADUser -All <--- This will return all AzureAD users
		Get-AADUser -UPN bjameson@example.com <--- This will return the user bjameson@example.com
	#>

    $token = Get-MsalToken x -tenantid organizations
    $global:header = @{'Authorization' = $token.createauthorizationHeader()}

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
            $ResponseBody    
        }
            

    }
    else {

        Write-Host "Please specify individual user or use All switch."

    }

}
