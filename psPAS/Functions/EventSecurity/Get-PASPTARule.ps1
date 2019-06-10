Function Get-PASPTARule {
	<#
	.SYNOPSIS
	Returns risky activities rules from PTA

	.DESCRIPTION
	Returns risky activities rules configured in PTA

	.EXAMPLE
Get-PASPTARule

	Returns all risky activities rules from PTA

	.NOTES
	Minimum Version CyberArk 10.4
	#>
	[CmdletBinding()]
	param(	)

	BEGIN {
		$MinimumVersion = [System.Version]"10.4"
	}#begin

	PROCESS {

		Assert-VersionRequirement -ExternalVersion $Script:ExternalVersion -RequiredVersion $MinimumVersion

		#Create request URL
		$URI = "$Script:BaseURI/$Script:PVWAAppName/API/pta/API/Settings"

		#Send request to web service
		$result = Invoke-PASRestMethod -Uri $URI -Method GET -WebSession $Script:WebSession

		If($result) {

			#Return Results
			$result.riskyActivities |

			Add-ObjectDetail -typename psPAS.CyberArk.Vault.PTA.Rule

		}

	}#process

	END {}#end
}