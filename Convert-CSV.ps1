<#
.SYNOPSIS
  
Convert-CSV [[-Path] <string>] [-NewDelimiter] <char> [[-OriginalDelimiter] <char>] [[-Encoding] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]

.DESCRIPTION
  
.PARAMETER Confirm
  
.PARAMETER Encoding
  
.PARAMETER NewDelimiter
  
.PARAMETER OriginalDelimiter
  
.PARAMETER Path
  
.PARAMETER WhatIf
  
#>
function Convert-CSV {

    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias('FullName')]
        [String]
        $Path,

        [Parameter(Mandatory=$true)]
        [Char]
        $NewDelimiter,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias('Delimiter')]
        [ValidateNotNullOrEmpty()]
        [Char]
        $OriginalDelimiter = (Get-Culture).TextInfo.ListSeparator,

        [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
        [String]
        $Encoding = 'UTF8'
    )

    process
    {
        if ($OriginalDelimiter -ne $NewDelimiter -and ([Byte]$OriginalDelimiter) -ne 0)
        {
            $message = "Changing delimiter from '{0}' to '{1}'" -f $OriginalDelimiter, $NewDelimiter
            if ($PSCmdlet.ShouldProcess($message, $Path))
            {
                (Import-CSV -Path $Path -Delimiter $OriginalDelimiter -Encoding $Encoding) |
                  Export-CSV -Path $Path -Delimiter $NewDelimiter -Encoding $Encoding
            }
        }
    }

}
