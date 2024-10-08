$feedUrl = "https://wonderspodcast.libsyn.com/rss"
$outDir = $Global:PodcastPath + [IO.Path]::DirectorySeparatorChar + "Wonders of the World"

# Number of digits in the season and episodes
$seasonPadding = 2
$episodePadding = 3

# Should I include season and episode in the filename? What about pubdate? 
$skipSeasonEpisode = $false
$includePubDate = $false

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
    if ($item.enclosure.url.Length -eq 0) { continue }
    
    # Get the real title from the feed
    $realTitle = $item.title[0]

    $episodeTitle = $realTitle -replace "^\d+\w? - ",""
    
    # If Season or Episode exists then capture them with some padding
    # Only do this if I haven't set the toggle above to skip
    if (!$skipSeasonEpisode) {
        if ($item.season) { $seasonNumber = "S{0:d$seasonPadding}" -f [int]$item.season } else { $seasonNumber = "" }
        if ($item.episode) { $episodeNumber = "E{0:d$episodePadding}" -f [int]$item.episode } else { $episodeNumber = "" }
    
        # Add a space if either the season or episode exists
        if ($seasonNumber.Length -eq 0 -and $episodeNumber.Length -eq 0) { $spacer = "" } else { $spacer = " " }

    } else {
        # Initialize these variables coz sometimes I copy paste the scripts
        $seasonNumber = ""
        $episodeNumber = ""
        $spacer = ""
    }

    if ($includePubDate) { $pubDate = Get-Date $item.pubDate -Format "yyyyMMddHHmm " } else { $pubDate = "" }
    
    # Generate the title
    $title = "${pubDate}${seasonNumber}${episodeNumber}${spacer}$episodeTitle"

    # The download Url
    $downloadUrl = $item.enclosure.url

    # Figure out the output file name
    $outputFile = "${outDir}/${title}.mp3"
    # This is what the iCloud cached file looks like; skip re-download if I find this
    $icloudFile = "${outDir}/.${title}.mp3.icloud"
    
    # Check if the output file exists; download if it doesn't
    if ((Test-Path -Path $outputFile) -or (Test-Path -Path $icloudFile)) {
        Write-Host "Skipping $outputFile as it already exists"
    } else {
        Write-Host "Downloading $downloadUrl as $outputFile"
        Invoke-WebRequest -Uri "$downloadUrl" -OutFile $outputFile
    }
}