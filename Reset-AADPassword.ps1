function Reset-AADPassword {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$UPN,
        [Parameter()]
        [String]$NewPwd,
        [Parameter()]
        [Switch]$Random
    )

    <#
		IMPORTANT:
        ===========================================================================
        This script is provided 'as is' without any warranty. Any issues stemming 
        from use is on the user.
        ===========================================================================
		.DESCRIPTION
		Resets AAD user password and sets to ChangeAtNextLogon
        Things to change to fit your environment:
        Line 36: Update clientId with your application Id. See https://docs.microsoft.com/en-us/graph/auth-v2-user for more info
		===========================================================================
		.PARAMETER UPN
        REQUIRED - Email/userPrincipalName of user to enable
        .PARAMETER NewPwd
        Specifies new password for user (only use if you have a strong password to use)
        .PARAMETER Random
        Will generate random strong password
		===========================================================================
		.EXAMPLE
		Reset-AADPassword -UPN bjameson@example.com -Random <--- Generates random password for bjameson@example.com and sets to ChangeAtNextLogon
	#>

        
    $token = Get-MsalToken -clientid x -tenantid organizations
    $global:header = @{'Authorization' = $token.createauthorizationHeader()}

    Function GenerateStrongPassword ([Parameter(Mandatory = $true)][int]$PasswordLength)
{
    Add-Type -AssemblyName System.Web
    $PassComplexCheck = $false
    do
    {
        $newPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength, 3)
        If (($newPassword -cmatch "[A-Z\p{Lu}\s]") `
            -and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
            -and ($newPassword -match "[\d]") `
            -and ($newPassword -match "[^\w]")
        )
        {
            $PassComplexCheck = $True
        }
    }
    While ($PassComplexCheck -eq $false)
    return $newPassword
}

    If ($Random) {

        $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
        $Password = GenerateStrongPassword(12)
        Set-Clipboard -Value $Password
        Write-Host "Password copied to clipboard!" -f Green
        $Body = @{

            "passwordProfile" = @{

                "forceChangePasswordNextSignIn" = $True;
                "password" = $Password

            }

        }
        $JSON = $Body | ConvertTo-Json
        try {
            Invoke-RestMethod -Uri $Uri -body $JSON -Headers $Header -ContentType "application/Json" -Method Patch
        }
        catch{
            $ResponseResult = $_.Exception.Response.GetResponseStream()
            $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
            $ResponseBody = $ResponseReader.ReadToEnd()
            }
            $ResponseBody

    }
    elseif (!$Random -and $NewPwd) {

        $Uri = "https://graph.microsoft.com/v1.0/users/$UPN"
        $Body = @{

            "passwordProfile" = @{

                "forceChangePasswordNextSignIn" = $True;
                "password" = $NewPwd

            }

        }
        $JSON = $Body | ConvertTo-Json
        try {
            Invoke-RestMethod -Uri $Uri -body $JSON -Headers $Header -ContentType "application/Json" -Method Patch
        }
        catch{
            $ResponseResult = $_.Exception.Response.GetResponseStream()
            $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
            $ResponseBody = $ResponseReader.ReadToEnd()
            }
            $ResponseBody

        }
}