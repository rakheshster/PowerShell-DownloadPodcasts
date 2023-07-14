$feedUrl = "https://feeds.megaphone.fm/VMP1850856004"
$outDir = $Global:PodcastPath + [IO.Path]::DirectorySeparatorChar + "Phoebe Reads A Mystery"

# This one is a bit different in that I store the episodes in sub-folders per book

# === Typically there should be nothing to change past this point ===
# === Except any changes to the title identifier in the loop below ===
if (!(Test-Path -Path "$outDir" -PathType Container)) {
    New-Item -Path "$outDir" -ItemType Directory
}

try {
    $webRequest = Invoke-WebRequest -Uri $feedUrl -ErrorAction Stop
    if ($webRequest.StatusCode -ne 200) {
        Write-Error "Something went wrong. StatusCode $($webRequest.StatusCode) - $($webRequest.StatusDescription)"
    }
    
} catch {
    Write-Error "Something went wrong: $($_.Exception.Message)"
}

$xmlContent = [xml]$webRequest.Content

foreach ($item in $xmlContent.rss.Channel.item) {
    $bookAndTitle = $item.title -split "\s*-\s*|\s*:\s*"
    $book = $bookAndTitle[0]
    $title = $bookAndTitle[1]

    if ($title.Length -eq 0) {
        $title = $book
        $book = "Specials"
    }

    $pubDate = Get-Date $item.pubDate -Format "yyyyMMddHHmm "

    # The download Url
    $downloadUrl = $item.enclosure.url

    # Figure out the output file name
    if (!(Test-Path "${outDir}/${book}")) {
        New-Item -Path "${outDir}/${book}" -ItemType Container
    }

    $outputFile = "${outDir}/${book}/${pubDate}${title}.mp3"
    # This is what the iCloud cached file looks like; skip re-download if I find this
    $icloudFile = "${outDir}/${book}/.${pubDate}${title}.mp3.icloud"
    
    # Check if the output file exists; download if it doesn't
    if ((Test-Path -Path $outputFile) -or (Test-Path -Path $icloudFile)) {
        Write-Host "Skipping $outputFile as it already exists"
    } else {
        Write-Host "Downloading $downloadUrl as $outputFile"
        Invoke-WebRequest -Uri "$downloadUrl" -OutFile $outputFile
    }
}