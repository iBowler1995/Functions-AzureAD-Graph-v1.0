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

    <#
		IMPORTANT:
        ===========================================================================
        This script is provided 'as is' without any warranty. Any issues stemming 
        from use is on the user.
        ===========================================================================
		.DESCRIPTION
		This function will remove an Azure AD Group Member.
        Things to change to fit your environment:
        Line 45: Update clientId with your application Id. See https://docs.microsoft.com/en-us/graph/auth-v2-user for more info
		===========================================================================
		.PARAMETER UPN
		REQUIRED - Email/UserPrincipalName of user to remove
        .PARAMETER All
        Optional switch to remove specified user from all statically assigned groups (will not remove from dynamic, because dynamic)
        .PARAMETER Group
        displayName of the group to remove user from
        .PARAMETER Multi
        Optional switch to indicate we intend to remove the user from multiple groups. Must be used with -File parameter
        .PARAMETER File
        Location of the text file with multiple groups (one per line) 
		===========================================================================
		.EXAMPLE
		Remove-AADGroupMember -UPN bjameson@example.com -Group Azure-Test <--- Removes bjameson@example.com from the group Azure-Test
        Remove-AADGroupMember -UPN bjameson@example.com -Multi -File C:\Temp\groups.txt <--- Removes bjameson@example.com from all groups in the text file
        Remove-AADGroupMember -UPN bjameson@example.com -All <--- Removes user from all statically assigned
	#>

    $token = Get-MsalToken -clientid x -tenantid organizations
    $global:header = @{'Authorization' = $token.createauthorizationHeader()}
    
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

        $GroupsUri = "https://graph.microsoft.com/v1.0/users/$($User.Id)/transitiveMemberOf"
        $GroupRequest = Invoke-WebRequest -Uri $GroupsUri -Headers $Header -Method Get
        $Groups = $GroupRequest | convertfrom-Json
        foreach ($Item in $Groups.value){

            $RemoveFrom = Get-AADGroup -Name $Item.displayName
            $UsertoRemove = Get-AADUser -UPN tmctesty@verisma.com
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