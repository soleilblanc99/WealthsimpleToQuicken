
param (
    [string]$InputFile,
    [string]$OutputFile
)

function Show-Usage {
    Write-Host "Usage:"
    Write-Host "    .\Convert-CreditCardToBanking.ps1 -InputFile <source.csv> -OutputFile <destination.csv>"
    Write-Host ""
    Write-Host "Description:"
    Write-Host "    Converts a credit card statement CSV to a banking transaction CSV format."
    Write-Host "    - The account field is set to 'WS VIP Credit Card'."
    Write-Host "    - The debit/credit field is left empty."
    Write-Host "    - For transaction types 'Purchase', 'Interest', 'Fee', or 'Cash  Advance',"
    Write-Host "      a minus sign is added to the amount if not already present."
    Write-Host ""
    Write-Host "Example:"
    Write-Host "    .\Convert-CreditCardToBanking.ps1 -InputFile credit-card-statement-transactions-2025-12-01.csv -OutputFile BankingTransactionsOutput.csv"
}

# If no parameters are provided, show usage and exit
if ($PSBoundParameters.Count -eq 0 -or !$InputFile -or !$OutputFile -or $InputFile -eq "-h" -or $InputFile -eq "--help") {
    Show-Usage
    exit
}

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
