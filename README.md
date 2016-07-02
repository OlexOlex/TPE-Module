# TPE-Module
A simple, small and cheap to build module to control 3 PWM driven and 2 binary (on/off) outputs via WIFI and a webinterface.
Runs on any newer ESP8266 module (the ones woth more RAM) with 4MB flash running NodeMCU (I recommend an integer version).
Access the NodeMCU filesystem via ESPlorer or other programs to upload the program, the two configuration files (ESPWIFI.conf and ESPWebserver.conf) and sequence files.
Compress the Lua program for uploading it using Luasrcdiet (otherwise it will bust the modules RAM).

Documentation not finished by now, I hope the comments and images suffice.

![Module photos](https://github.com/OlexOlex/TPE-Module/blob/master/Hardware%2BChassis/Pictures/IMG_20160630_033513.jpg)

## Features:
* Provides a **WIFI-accesspoint** and/or **connects to a (list of) WIFI(s)**
* **Control via web page** in any modern Browser (Tested with Firefox, Chrome, Android Browser)
* Controls up to **three vibrators** or other things/external modules 0 - 1023 (though the lower 200 are usually useless for vibrators) or runs sequences on the vibrators
* Controls up to **two other external modules** like e-shocking, a magnetic (un)lock, a beeper, etc. (gives a short on-signal)
* Nearly everything of the website as well as the WIFI options can be **customized by 2 configuration files** on the integrated primitive filesystem (sadly / luckily not like a USB-stick, you need an easy to use free Java software for access: ESPlorer) 
* Supports many (at least 5 - limited only by buffer size for the IP packet) **custom sequences for vibrators** (each one is a file in the filesystem, simple and easy format, autodetected on boot)
* Runs at least for **13 hours idling** (WIFI acesspoint running, logged into a WIFI network, a few website requests) with a 3,7V 1200mAh LiPo battery
* Turns on on 1 sec button press, you can **turn it off on the website only**
* Tick "All Off" ("Alles Aus" in the the german configured screenshots) and send it to turn everything of (except for the module)
* Configurable **password protection** (enable it by defining a password in the server config file or make the line defining it a comment for disabling password protection)
* **86x51x21,5mm** in size - smaller than a pack of cigaretts
* "Status" page that shows you the current battery voltage and lets you turn off the module
* Access it in the local network at http://[your configured servername here] or 192.168.4.1 if your device is connected to the modules accesspoint
* Sockets provide ground, battery voltage and the signal (on = tied to ground, max 0.5A, off = no potential) when the module is on, so you can permanently power external modules/cirquits if needed or run a motor directly between the signal line and the battery voltage line
* Charge it with a common **micro USB** cable, upload further files by the integrated usb-serial-adapter
* **Noncommercially open source under the beerware-license** (No guarantees on anything, use at your own risk, if you think it's good, buy me a beer when we meet. In case you want to use it commercially, contact me and we'll find an agreement)
* Material cost: **~14€** for me when buying the stuff in China (Aliexpress and then wait for 1.5 Months - I got a cheap offer for the battery, you might have to pay 2-3€ more. A list of the parts is in an OpenOffice spreadsheet in the Hardware+Chassis directory)
* **Relatively easy to build, most parts are premanufactured ready-to-use-modules**, the connectors are common 3.5mm stereo jacks
* Any simple 3-4V device with a remote control on a cord can easily be converted to fit this module (and if you add a socket to the original remote control, you can still plug it back)

### Disadvantages:
* The module runs a Lua interpreter, which was not designed for running a webserver on it, but this project does so. So the current state is close to busting the modules RAM
* The requests are unencrypted HTTP-POST requests - no ssl encryption 
* The Lua-interpreter-firmware (NodeMCU) is still under (heavy?) development, so some functionalities change (especially for the voltage measuring standard source I experienced it)
* It sometimes takes a while until the router knows the device under its configured name, so it might take some time until you can access it at http://[your configured servername here]

