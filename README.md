# CSGO Protector

A module for Counter-Strike: Global Offensive, written in 2019 as a commissioned project.

Overall, given my skills at the time, I would say the project is decent. There is probably something to learn here, at least if you manage to figure out how everything works.

Most of the descriptive comments are in Russian. I don't want to change that, as I wish to leave everything as it is.

# Description

The main task of this project was to integrate a custom server list into the game's server browser. This couldn't be done by simply changing the masterserver in the VDF file, but it became possible by patching the RevEmu, which was used in the builds that utilized this project. However, even this wasn't straightforward, as the emulator was protected by Themida. Fortunately, the protection configuration left much to be desired.

I highly recommend checking out the file `Xander.RevFix.pas` if you're interested in my efforts to fix SteamID generation. The file contains a detailed explanation of how it works, although the language is still Russian.

# Main Features

* Implementation of a custom SteamID generation algorithm
* Replacing the server list in the "Internet" and "Friends" tabs
* Fixing game crashes when querying game servers
* Implementation of a custom server sorting algorithm in the server browser
* Hiding itself by erasing MZ headers and unlinking from the module list
* Fun export feature
* Many utility modules that are useful for learning

# License

You are free to use this project and its knowledge in your work, however, I would be very grateful if you would refer to me.