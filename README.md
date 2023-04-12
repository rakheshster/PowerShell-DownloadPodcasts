# What's this?
I listen to the [Empire](https://podcasts.apple.com/gb/podcast/empire/id1639561921) podcast and wanted to download its episodes so I have a copy somewhere. Yay RSS. 

Couldn't figure out an easy way of doing this. So I created some PowerShell to do this. It's RSS (XML) after all. Download the feed, parse it, download the episodes and name them how I want. 

Then I expanded it to download some more podcasts I have listened to in the past. The result is what you see in this repo. 

I ❤️ PowerShell.

# Note
I try to keep the scripts as similar to each other as possible. In most of them the only change is how I grab the real title from the feed. Additionally I define some variables in the beginning of these scripts that define how I manipulate the title to add a season number, episode number, or publication date. 