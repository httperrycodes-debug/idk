# Haddaway What Is Love - Auto Player with Volume Lock
# Kill switch: Press + to stop and quit

Add-Type -AssemblyName presentationCore
Add-Type -AssemblyName System.Windows.Forms

# --- Download the MP3 ---
$rawUrl = "https://raw.githubusercontent.com/httperrycodes-debug/idk/refs/heads/main/Haddaway%20-%20What%20Is%20Love%20(Official%204K%20Video).mp3"
$outputPath = "$env:TEMP\whatislove.mp3"

Invoke-WebRequest -Uri $rawUrl -OutFile $outputPath


# --- Set system volume to 100% ---
$shell = New-Object -ComObject WScript.Shell

# Press VolumeUp 50 times to ensure max volume
for ($i = 0; $i -lt 50; $i++) {
    $shell.SendKeys([char]175)
    Start-Sleep -Milliseconds 20
}


# --- Play the MP3 ---
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([Uri]$outputPath)
$player.Volume = 1.0
$player.Play()


# --- Volume lock loop + kill switch ---
while ($true) {
    # Re-push volume up every 500ms to counter any reduction
    for ($i = 0; $i -lt 3; $i++) {
        $shell.SendKeys([char]175)
        Start-Sleep -Milliseconds 20
    }

    # Check for + key kill switch
    if ([System.Console]::KeyAvailable) {
        $key = [System.Console]::ReadKey($true)
        if ($key.KeyChar -eq '+') {
            Write-Host "Kill switch activated. Stopping..."
            $player.Stop()
            $player.Close()
            exit
        }
    }

    Start-Sleep -Milliseconds 500
}
