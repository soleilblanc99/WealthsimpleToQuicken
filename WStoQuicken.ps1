
param (
    [string]$InputFile,
    [string]$OutputFile
)

# Import credit card statement
$creditCardData = Import-Csv $InputFile

# Prepare output array
$bankingTransactions = @()

foreach ($row in $creditCardData) {
    # Transaction types that require a minus sign
    $minusTypes = @("Purchase", "Interest", "Fee", "Cash  Advance")
    $amount = $row.'amount'
    if ($minusTypes -contains $row.'type') {
        # Add minus if not already present
        if ($amount -notmatch "^-") {
            $amount = "-" + $amount
        }
    }

    $newRow = [PSCustomObject]@{
        date             = $row.'transaction_date'
        payee            = $row.'details'
        'fipayee-unused' = ""
        amount           = $amount
        'debit/credit'   = ""
        category         = $row.'type'
        account          = "WS VIP Credit Card"
        tag              = ""
        memo             = ""
        chknum           = ""
    }
    $bankingTransactions += $newRow
}

# Export to new CSV
$bankingTransactions | Export-Csv $OutputFile -NoTypeInformation

Write-Host "Conversion complete. Output saved to $OutputFile"
