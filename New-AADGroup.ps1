function New-AADGroup {

    [CmdletBinding()]
    param (
        
        [Parameter(Mandatory = $True)]
        [String]$Name,
        [Parameter(Mandatory = $True)]
        [String]$Nickname,
        [Parameter(Mandatory = $True)]
        [Boolean]$Unified,
        [Parameter()]
        [Boolean]$MailEnabled,
        [Parameter()]
        [String]$Description

    )

    <#
		IMPORTANT:
        ===========================================================================
        This script is provided 'as is' without any warranty. Any issues stemming 
        from use is on the user.
        ===========================================================================
		.DESCRIPTION
		Creates an Azure AD Group
        Things to change to deploy in your environment:
        Line 45: replace x with clientID of your reigstered app. See https://bit.ly/3KApKhJ for more info.
		===========================================================================
		.PARAMETER Name
		REQUIRED - DisplayName of the group to be
		.PARAMETER NickName
		REQUIRED - Mail nickname; no spaces. Ex: JimB
        .PARAMETER Unified
        REQUIRED - If true, will create an M365 group. If false, will create standard assigned group
        .PARAMETER MailEnabled
        If true, will enable mail for group. If false, will not enable mail for group. (Only Unified/M365 groups can have mail enabled.)
        .PARAMETER Description
        Optional description of group
		===========================================================================
		.EXAMPLE
		New-AADGroup -Name Azure-Test -Nickname AzureT -Unified:false -Mailenabled:false <--- Creates new standard assigned group named Azure-Test with the nickname AzureT
	#>

    $token = Get-MsalToken -clientid x -tenantid organizations
    $global:header = @{'Authorization' = $token.createauthorizationHeader();'ConsistencyLevel' = 'eventual'}

    If (($Unified -eq $False) -and ($Description) -and (!$MailEnabled)) {

        $Hash = @{

            "displayName" = $Name;
            "mailNickname" = $Nickname; #for later notes: spaces in nickname must be represented by %20
            "mailEnabled" = $False;
            "securityEnabled" = $True;
            "description" = $Description

        }
        $Body = $Hash | ConvertTo-Json
        $Uri = "https://graph.microsoft.com/v1.0/groups"
        Try {

            Invoke-RestMethod -Uri $Uri -Body $body -Headers $header -ContentType "application/Json" -Method Post

        }
        catch{
            $ResponseResult = $_.Exception.Response.GetResponseStream()
            $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
            $ResponseBody = $ResponseReader.ReadToEnd()
            $ResponseBody    
        }
            

    }
    elseif (($Unified -eq $False) -and (!$description) -and (!$MailEnabled)) {

        $Hash = @{

            "displayName" = $Name;
            "mailNickname" = $Nickname;
            "mailEnabled" = $False;
            "securityEnabled" = $True

        }
        $Body = $Hash | ConvertTo-Json
        $Uri = "https://graph.microsoft.com/v1.0/groups"
        Try {

            Invoke-RestMethod -Uri $Uri -Body $body -Headers $header -ContentType "application/Json" -Method Post

        }
        catch{
            $ResponseResult = $_.Exception.Response.GetResponseStream()
            $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
            $ResponseBody = $ResponseReader.ReadToEnd()
            $ResponseBody    
        }
            

    }
    elseif (($Unified -eq $True) -and ($Description) -and ($MailEnabled)) {

        $Hash = @{

            "displayName" = $Name;
            "mailNickname" = $Nickname; #for later notes: spaces in nickname must be represented by %20
            "mailEnabled" = $True;
            "groupTypes" = @("Unified");
            "securityEnabled" = $True;
            "description" = $Description

        }
        $Body = $Hash | ConvertTo-Json
        $Uri = "https://graph.microsoft.com/v1.0/groups"
        try {
        
            Invoke-RestMethod -Uri $Uri -Body $body -Headers $header -ContentType "application/Json" -Method Post

        }
        catch{
            $ResponseResult = $_.Exception.Response.GetResponseStream()
            $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
            $ResponseBody = $ResponseReader.ReadToEnd()
            $ResponseBody    
        }
            

    }
    elseif (($Unified -eq $True) -and (!$Description) -and ($MailEnabled)){

        $Hash = @{

            "displayName" = $Name;
            "mailNickname" = $Nickname; #for later notes: spaces in nickname must be represented by %20
            "mailEnabled" = $True;
            "groupTypes" = @("Unified");
            "securityEnabled" = $True;

        }
        $Body = $Hash | ConvertTo-Json
        $Uri = "https://graph.microsoft.com/v1.0/groups"
        try {
        
            Invoke-RestMethod -Uri $Uri -Body $body -Headers $header -ContentType "application/Json" -Method Post

        }
        catch{
            $ResponseResult = $_.Exception.Response.GetResponseStream()
            $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
            $ResponseBody = $ResponseReader.ReadToEnd()
            $ResponseBody    
        }
            

    }

}