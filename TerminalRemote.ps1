$terminal = $null

function Start-Terminal ($terminal = $null)
{
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo    
    if ($terminal)  {
        $startInfo.FileName = $terminal
    }
    else {
        $startInfo.FileName = "c:\Windows\System32\cmd.exe"        
        $startInfo.Arguments = "dir"
    }
    #$startInfo.Arguments = New_Function

    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.RedirectStandardInput = $true
    $startInfo.ErrorDialog = $false
    $startInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8


    

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $process.EnableRaisingEvents = $true

    $global:errorEvent = Register-ObjectEvent -InputObject $process -EventName "ErrorDataReceived" `
    -Action `
    {
        param
        (
            [System.Object] $sender,
            [System.Diagnostics.DataReceivedEventArgs] $e
        )
        if ($e.Data)
        {
            Write-Host -ForegroundColor Red $e.Data
        }
    }

    $global:outputEvent = Register-ObjectEvent -InputObject $process -EventName "OutputDataReceived" `
    -Action `
    {
        param
        (
            [System.Object] $sender,
            [System.Diagnostics.DataReceivedEventArgs] $e
        )
        if ($e.Data)
        {
            Write-Host $e.Data
        }
    }
            

    $process.Start() | Out-Null
    $process.BeginOutputReadLine()
    $process.BeginErrorReadLine()

#     $process.WaitForExit()   
    
     Write-Host -ForegroundColor Magenta "Process '$($process.Path)' started and ID is '$($process.Id)'"
     $global:terminal = $process
}

function Invoke-Terminal($cmd)
{
    if (!$global:terminal)
    {
        Start-Terminal
    }
    Write-Host -ForegroundColor Yellow $cmd
    $terminal.StandardInput.WriteLine($cmd)
}

function Close-Terminal()
{
    Write-Host -ForegroundColor Magenta "Terminating '$($process.Path)' started with ID '$($process.Id)'"

    Unregister-Event -SourceIdentifier $global:outputEvent.Name
    Unregister-Event -SourceIdentifier $global:errorEvent.Name

    $global:terminal.Close()  
}



