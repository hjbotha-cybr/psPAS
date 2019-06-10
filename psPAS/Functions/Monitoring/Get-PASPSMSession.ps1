function Get-PASPSMSession {
	<#
.SYNOPSIS
Get details of Live PSM Sessions

.DESCRIPTION
Returns the details of active PSM sessions.

.PARAMETER liveSessionId
The ID of an active session to get details of.

.PARAMETER Limit
The number of sessions that are returned in the list.

.PARAMETER Sort
The sort can be done by each property on the recording file:
 - RiskScore
 - FileName
 - SafeName
 - FolderName
 - PSMVaultUserName
 - FromIP
 - RemoteMachine
 - Client
 - Protocol
 - AccountUserName
 - AccountAddress
 - AccountPlatformID
 - PSMStartTime
 - TicketID
The sort can be in ascending or descending order.
To sort in descending order, specify "-" before the recording property by which to sort.

.PARAMETER Offset
Determines which recording results will be returned, according to a specific place in the returned list. This value
defines the recording's place in the list and how many results will be skipped.

.PARAMETER Search
Returns recordings that are filtered by properties that contain the specified search text.

.PARAMETER Safe
Returns recordings from a specific safe

.PARAMETER FromTime
Returns recordings from a specific date

.PARAMETER ToTime
Returns recordings from a specific date

.PARAMETER Activities
Returns recordings with specific activities.

.EXAMPLE
Get-PASPSMSession

Lists all Live PSM Sessions.

.EXAMPLE
Get-PASPSMSession -liveSessionId 123_45

Returns details of active PSM Session with Id 123_45

.INPUTS
All parameters can be piped by property name

.OUTPUTS
SessionToken, WebSession, BaseURI are passed through and
contained in output object for inclusion in subsequent
pipeline operations.
Output format is defined via psPAS.Format.ps1xml.
To force all output to be shown, pipe to Select-Object *

.NOTES
Minimum CyberArk Version 9.10
For querying sessions by ID, Required CyberArk Version is 10.6

.LINK

#>
	[CmdletBinding(DefaultParameterSetName = "byQuery")]
	param(
		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true,
			ParameterSetName = "bySessionID"
		)]
		[string]$liveSessionId,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true,
			ParameterSetName = "byQuery"
		)]
		[ValidateNotNullOrEmpty()]
		[int]$Limit,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true,
			ParameterSetName = "byQuery"
		)]
		[ValidateSet("RiskScore", "FileName", "SafeName", "FolderName", "PSMVaultUserName", "FromIP", "RemoteMachine",
			"Client", "Protocol", "AccountUserName", "AccountAddress", "AccountPlatformID", "PSMStartTime", "TicketID",
			"-RiskScore", "-FileName", "-SafeName", "-FolderName", "-PSMVaultUserName", "-FromIP", "-RemoteMachine",
			"-Client", "-Protocol", "-AccountUserName", "-AccountAddress", "-AccountPlatformID", "-PSMStartTime",
			"-TicketID"
		)]
		[string]$Sort,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true,
			ParameterSetName = "byQuery"
		)]
		[int]$Offset,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true,
			ParameterSetName = "byQuery"
		)]
		[string]$Search,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true,
			ParameterSetName = "byQuery"
		)]
		[string]$Safe,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true,
			ParameterSetName = "byQuery"
		)]
		[int]$FromTime,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true,
			ParameterSetName = "byQuery"
		)]
		[int]$ToTime,

		[parameter(
			Mandatory = $false,
			ValueFromPipelinebyPropertyName = $true,
			ParameterSetName = "byQuery"
		)]
		[string]$Activities
	)

	BEGIN {
		$MinimumVersion = [System.Version]"9.10"
		$RequiredVersion = [System.Version]"10.6"
	}#begin

	PROCESS {

		#Create URL for Request
		$URI = "$Script:BaseURI/$Script:PVWAAppName/API/LiveSessions"

		If($PSCmdlet.ParameterSetName -eq "bySessionID") {

			Assert-VersionRequirement -ExternalVersion $Script:ExternalVersion -RequiredVersion $RequiredVersion

			$URI = "$URI/$liveSessionId"

		}

		ElseIf($PSCmdlet.ParameterSetName -eq "byQuery") {

			Assert-VersionRequirement -ExternalVersion $Script:ExternalVersion -RequiredVersion $MinimumVersion

			#Get Parameters to include in request
			$boundParameters = $PSBoundParameters | Get-PASParameter

			#Create Query String, escaped for inclusion in request URL
			$queryString = ($boundParameters.keys | ForEach-Object {

					"$_=$($boundParameters[$_] | Get-EscapedString)"

				}) -join '&'

			if($queryString) {

				#Build URL from base URL
				$URI = "$URI`?$queryString"

			}

		}

		#send request to PAS web service
		$result = Invoke-PASRestMethod -Uri $URI -Method GET -WebSession $Script:WebSession

		If($result) {

			#Return Results
			$result.LiveSessions |

			Add-ObjectDetail -typename psPAS.CyberArk.Vault.PSM.Session

		} #process

	}

	END {}#end

}