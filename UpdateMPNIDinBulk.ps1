Install-Module -Name PartnerCenter -AllowClobber -Scope CurrentUser

$inputcsvfile= ""
$mpnid= ""

$inputcsvfile= Read-Host -Prompt "Enter Full path of CSV file"
$mpnid= Read-Host -Prompt "Enter new MPND"

if (-not $inputcsvfile) {
     Write-Warning "It is necessary to enter a CSV File.";
     return;
}elseif ($inputcsvfile.Length -le 8){
    Write-Warning "File Path is less than 8 characteres, make sure path is correct";
    return;
}else{
    if (-not $mpnid) {
         Write-Warning "It is necessary to enter new MPNID.";
         return;
    }else {
        Write-Host "Please check columns in the entered CSV file are named as: ms_customer_id, ms_subscription_id" -ForegroundColor red -BackgroundColor White
        Write-Host "Additionally, during the execution, you will be requested to enter Partner Center credentials." -ForegroundColor red -BackgroundColor White
        Pause
        }
}

$delimiter = ","
	
$csvdata = Import-CSV -Path $inputcsvfile -Delimiter $delimiter

If ($csvdata -ne $null)
{
    $lineid = 0;
    foreach ($line in $csvdata) 
    {
	    $lineid++;
	    $comment =""
        $resultValue1 = @()
        $resultValue2 = @()
		
	    Add-Member -InputObject $line -MemberType NoteProperty -Name "Error" -Value $comment
	    Write-Host "Line $($lineid) $($comment)"		
    }
	
    Connect-PartnerCenter
    $partnerID = $mpnid
    $lineid = 0;
    foreach ($line in $csvdata) 
    {
	    $lineid++;
	    $comment = ""
	    if ($line.ms_customer_id -ne $null -and $line.ms_subscription_id -ne $null)
	    {
		    try {
			    $mssubs = Get-PartnerCustomerSubscription -CustomerId $line.ms_customer_id -SubscriptionId $line.ms_subscription_id | Select-Object FriendlyName, OfferName, SubscriptionId, CommitmentEndDate, Quantity, Status, PartnerId
							
			    if ($mssubs.Status -eq "Active")
			    {
				    if ($mssubs.PartnerId -ne $partnerID)
					    {
						    $setresponse = Set-PartnerCustomerSubscription -CustomerId $line.ms_customer_id -SubscriptionId $line.ms_subscription_id -PartnerId $partnerID
						    $comment = "successful - MPNID Changed"
					    } else {
						    $comment = "unsuccessful - MPNID Already set"
					    }
			    }else{
				    $comment = "unsuccessful - Subscription is not Active in MSPC"
			    }			
		    } catch {
			    $comment = "unsuccessful - Error fetching MS data"
		    }
	    } else {
			    $comment = "unsuccessful - Information cannot be retrieved"
		    }
	    Add-Member -InputObject $line -MemberType NoteProperty -Name "Comment" -Value $comment
	    Write-Host "Line $($lineid) $($comment)"
    }
    $newfile = $inputcsvfile -replace ".csv$","-result.csv"
    $csvdata | export-csv -Path $newfile -Delimiter $delimiter -NoTypeInformation
    Write-Host "Process Completed, result exported in " $newfile
} else {
    Write-Host "CSV file does not have data"
}
