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
        Things to change to deploy in your environment:
        Line 36: replace x with clientID of your reigstered app. See https://bit.ly/3KApKhJ for more info.
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
            $ResponseBody    
        }
            

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
            $ResponseBody    
        }
            

        }
}