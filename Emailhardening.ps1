# PowerShell Script to add DMARC, SPF, and DKIM TXT records for a domain in Windows DNS

function Add-DnsTxtRecord {
    param (
        [string]$ZoneName,
        [string]$RecordName,
        [string]$RecordValue
    )

    try {
        Add-DnsServerResourceRecord -ZoneName $ZoneName `
            -Name $RecordName `
            -Txt `
            -DescriptiveText $RecordValue `
            -ErrorAction Stop

        Write-Host "✅ Added TXT record: $RecordName.$ZoneName -> $RecordValue" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to add $RecordName TXT record for $ZoneName. Error: $_" -ForegroundColor Red
    }
}

# Get domain input from user
$domain = Read-Host "Enter your domain (e.g., example.com)"

# Confirm before applying
Write-Host "`nThis script will attempt to add the following DNS records:"
Write-Host "- SPF   : v=spf1 include:$domain -all"
Write-Host "- DKIM  : selector1._domainkey (placeholder)"
Write-Host "- DMARC : v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@$domain; pct=100"
$confirmation = Read-Host "`nProceed? (Y/N)"
if ($confirmation -ne "Y") {
    Write-Host "Aborted by user." -ForegroundColor Yellow
    exit
}

# SPF record (at root)
$spf = "v=spf1 include:$domain -all"
Add-DnsTxtRecord -ZoneName $domain -RecordName "@" -RecordValue $spf

# DKIM placeholder (assumes selector1)
$dkim = "v=DKIM1; k=rsa; p=MIIB...YourPublicKeyHere...AQAB"
Add-DnsTxtRecord -ZoneName $domain -RecordName "selector1._domainkey" -RecordValue $dkim

# DMARC record
$dmarc = "v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@$domain; pct=100"
Add-DnsTxtRecord -ZoneName $domain -RecordName "_dmarc" -RecordValue $dmarc

Write-Host "`n🎉 DNS Records Created (or attempted). Verify them using external tools like MXToolbox or Dig." -ForegroundColor Cyan
