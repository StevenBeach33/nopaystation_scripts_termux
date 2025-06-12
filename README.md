# nopaystation\_scripts

A shell script collection which downloads nopaystation PS Vita stuff.
There are several scripts. One to download all \*.tsv files of NoPayStation. The other are for downloading games, updates
or all DLC of a PS Vita game, PSM or PSP games.

## Supported Operating Systems
* GNU/Linux
* FreeBSD
* Windows 10 with WSL should also work but it's untested
* Termux

## nopaystation\_scripts Installation

```bash
git clone https://github.com/StevenBeach33/nopaystation_scripts_termux.git && cd nopaystation_scripts_termux && bash setup.sh && source ~/.bashrc
```

## Script examples and description 

### nps\_tsv.sh
To download all of tsv from nopaystation and store it in `tsv` folder.
It automatically executed while installation process.

### nps\_game.sh
With this script you can download and unpack a PS Vita game and move it to /sdcard/NPS/PSV_GAME folder.
The first parameter is the path to \*.tsv file and the second is the game's title ID.
It also changes the region name into TV format (NTSC, PAL, ...)
For example:
```bash
bash nps_game.sh tsv/PSV_GAMES.tsv GAME_ID
```
I can recommend [this](http://renascene.com/psv/) site for searching title IDs.

### nps\_update.sh (not tested)
With this script you can download the latest or all available PS Vita game updates.
There is a optional first parameter "-a" and the second is the game's title ID.
It will be zipped and move to /sdcard/NPS/PSV_UPDATE folder.
For example:
```bash
bash nps_update.sh [-a] GAME_ID
```

### nps\_dlc.sh
This script downloads every DLC found for a specific title ID with available zRIF key.
Every DLC will be zipped and move to /sdcard/NPS/PSV_DLC folder.
For example:
```bash
bash nps_dlc.sh tsv/PSV_DLCS.tsv GAME_ID
```

### nps\_psm.sh (not tested)
With this script you can download a PSM game.
The first parameter is the path to \*.tsv file and the second is the game's title ID.
It will zipped game and move to /sdcard/NPS/PSM folder.
It also changes the region name into TV format (NTSC, PAL, ...)
For example:
```bash
bash nps_psm.sh tsv/PSM_GAMES.tsv GAME_ID
```

### nps\_psp.sh (not tested)
With this script you can download a PSP game.
The first parameter is the path to your \*.tsv file and the second is the game's title ID.
It move the \*.iso file to /sdcard/NPS/PSP directory.
For example:
```bash
bash nps_psp.sh tsv/PSP_GAMES.tsv GAME_ID
```
I can recommend [this](http://renascene.com/psp/) site for searching title IDs.

### nps\_bundle.sh (not tested)
This script downloads the game, every update and dlc found for a specific title ID with available zRIF key.
It puts the DLC and the Updates in a dedicated folder named like the generated zip and optionally creates a torrent for the game,
updates and dlc folders. In fact it uses the three scripts from above, combines them and download everything available for a game.
You need to have nps\_game.sh, nps\_update.sh, nps\_dlc.sh in your $PATH variable to get it working.

You need to symlink them to **${HOME}/bin/**, **/usr/local/bin** or **/usr/bin/**.
This is explained in the *Installation* Section above

If you want to do some additional steps after running *nps_bundle.sh*, you can add a post script named *nps_bundle_post.sh* to the directory where you run *nps_bundle.sh* from the command line.
It has to be executable to run. *nps_bundle.sh* runs the post script with the game name as the first parameter.
Your script can handle the parameter with the variable **$1** in your (shell) script.
You can use this to automate your upload process with an script which adds the torrent to your client or move it and
set the correct permissions to the file.
All files are named like **$1**.
For example the update and dlc directories
* ${1}_update
* ${1}_dlc

or the torrent files
* ${1}.torrent
* ${1}_update.torrent
* ${1}_dlc.torrent

If you call the script with "-a", it will download all updates instead of the latest only. Additionally you can set the parameter [-c]
to enable torrent creating. If you use this you can add source flag after it.
when creating torrent files with to use with private trackers.
To use this feature you need to have mktorrent installed in version 1.1+!
For example:
```bash
./nps_bundle.sh [-a] -t PCSE00986 -c "http://announce.url" -d "/path/to/directory/containing/the/tsv/files" [-c] [<SOURCE FLAG>]
```

## nps\_region.sh (not tested)
This works pretty much the same as **nps_bundle.sh** but downloads all base games of a specific region.
It creates a subdirectory in your current working directory for the region you mentioned. Valid regions are *US* *JP* *EU* *ASIA*.
There is also a post hook implemented with the file name *./nps_region_post.sh* like *nps\_bundle*. The name of the collection directory
is overgiven to the post script as the first parameter.
For more informations and help about the script just call it with the *--help* parameter or look at the code.

Example:
```bash
$ ./nps_region.sh -r ASIA -t game -d /path/to/directory/containing/the/tsv/files [-c http://announce.url] [-s <SOURCE>] [-a]
```

### pyNPU.py
This little python program helps you downloading updates and generating changelogs for your games.
Just use the "-h" parameter to get all parameters and examples. It's useful for checking changelogs and generating download links.

# ToDos
* add command line parameters to control the behaviour of the download scripts (downloading/compressing only)
* compare the whole download + compression process of pkg2zip vs. pkg2zip without zipping + torrent7z compressing
