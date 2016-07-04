# TPE-Module
A simple, small, cheap and relatively easy to build module to control 3 PWM driven and 2 binary (on/off) outputs via WIFI and a webinterface (designed for controlling 3 vibrators and 2 other custom modules, especially in BDSM plays, that's why there is a password protection available)

Runs on any newer ESP8266 module (the ones with more RAM than the first version) with 4MB flash running NodeMCU (I recommend an integer version, the floatingpoint accurate version might use too much RAM).

To flash NodeMCU to your module you can use programs like [esptool.py](https://github.com/themadinventor/esptool/blob/master/esptool.py)

To access the NodeMCU filesystem you can use programs like [ESPlorer](http://esp8266.ru/esplorer/), you need it to upload the program, the two configuration files (ESPWIFI.conf and ESPWebserver.conf) and sequence files, and to test (execute) the Lua server program before renaming it so it gets executed automatically at startup.

In case you change anything in the program, remember to compress the Lua program for uploading it using [Luasrcdiet](http://esp8266.ru/esplorer/) (otherwise it will bust the modules RAM when executing).

Documentation not finished by now, I hope this README, the comments and the images provided suffice. Browse the project, it consists of only a few files separated into a software and a hardware part.

![Module photos](https://github.com/OlexOlex/TPE-Module/blob/master/Hardware%2BChassis/Pictures/IMG_20160630_033513.jpg)
![Website photo](https://github.com/OlexOlex/TPE-Module/blob/master/Software/Pictures/German_website_v1.0/Hauptseite_post_Einstellungen.png)

## Features:
* Provides a **WIFI-accesspoint** and/or **connects to a (list of) WIFI(s)**
* **Control via web page** in any modern browser (Tested with Firefox, Chrome and Android 4.4 browser)
* Controls up to **three vibrators** or other things/external modules 0 - 1023 (though the  1-150 are usually useless for vibrators) or runs sequences on the vibrators that are defined in customizable sequence files
* Controls up to **two other external modules** like e-stim, a magnetic (un)lock, a beeper, etc. (gives a short on-signal)
* Nearly everything of the website as well as the WIFI options can be **customized by 2 configuration files** on the integrated primitive filesystem (sadly / luckily not like a USB-stick, you need an easy to use free Java software for access: ESPlorer) 
* Supports many (at least 5 - limited only by buffer size for the IP packet) **custom sequences for vibrators** (each one is a file in the filesystem, simple and easy format, autodetected on boot)
* Runs at least for **13 hours idling** (WIFI acesspoint running, logged into a WIFI network, a few website requests) with a 3,7V 1200mAh LiPo battery
* Turns on on 1 sec button press, you can **turn it off on the website only**
* Tick "All Off" ("Alles Aus" in the the german configured screenshots) and send it to turn all outputs off (except for the module)
* Configurable **password protection** (enable it by defining a password in the server config file or make the line defining it a comment for disabling password protection)
* **86x51x21,5mm** in size - smaller than a pack of cigaretts
* "Status" page that shows you the current battery voltage and lets you turn off the module
* Access it in the local network at http://[your configured servername here] or 192.168.4.1 if your device is connected to the modules accesspoint
* Sockets provide ground, battery voltage and the signal (on = tied to ground, max 0.5A, off = no potential) when the module is turned on, so you can permanently power external modules/cirquits if needed, or run a motor directly between the signal line and the battery voltage line
* Charge it and access the integrated file system by the integrated usb-serial-adapter with a common **micro USB** cable
* **Noncommercially open source under the licence stated below** (tl;dr: No guarantees on anything, use at your own risk, if you think it's good, buy me a beer when we meet. In case you want to use it commercially, contact me and we'll find an agreement)
* Material cost: **~14€** for me when buying the stuff in China (bought at Aliexpress and then waited for 1.5 Months for the items. I got a cheap offer for the battery, you might have to pay 2-3€ more. A list of the parts is in an OpenOffice spreadsheet in the Hardware+Chassis directory, Ebay and other sources might be good sources as well)
* **Relatively easy to build, most parts are premanufactured ready-to-use-modules**, the connectors are common 3.5mm stereo jacks
* Any simple 3-4V device with a remote control on a cable can easily be converted to fit this module (and if you add a socket to the original remote control, you can still plug it back)

### Disadvantages:
* The module runs a Lua interpreter, which was not designed for running a webserver on it, but this project does so. So the current state is close to busting the modules RAM
* The Lua-interpreter-firmware (NodeMCU) is still under (heavy?) development, so some functionalities change (especially for the voltage measuring standard source I experienced it), and before acessing the filesystem via ESPlorer, you might need to send the =node.heap() command ("Heap"-button) a few times to synchronize the connection
* It sometimes takes a while until the router knows the device under its configured name, so it might take some time until you can access it at http://[your configured servername here] (once NodeMCU behaviour seems to have changed at that point as well)
* The requests are unencrypted HTTP-POST requests - no ssl encryption used

## How to build one:
* Build the hardware by wiring everything together (don't use the chassis yet)
* Get an image of the NodeMCU firmware, e.g. at http://nodemcu-build.com/
* Flash this image on your ESP-module by turning it on while having a wire between GND ("Minus") and GPIO0 (and keep the on button pressed or shortened so it does not turn off again)
* Reboot the module by releasing the on button/shorting, remove the wire to GPIO0, and pressing/shorting the on button again (hold it)
* Upload the server Lua script (compressed by Luasrcdiet), the config files and any sequence file you want using e.g. ESPlorer (you might need to request the current heap space a few times before the connection is properly synchronized)
* To test it, execute the server script by reloading the file list in ESPlorer, right click on the file and run it
* If there are no error messages in ESPlorer, your module does not turn off after releasing the button/removing the shorting and there is a WIFI named "SGWIFI", it works. Try connecting to the WIFI using the password of the WIFI configuration file and test the output sockets
* Change the name of the server Lua script to "init.lua", change your configuration files as you wish and upload them, turn off the module and restart it
* If everything works, assemble the hardware in the chassis (you need a hole for every 3.5mm socket, the button and a slot for the micro-USB socket). Additionally you can seal everything with glue and hot glue or whatever you think is useful, so no water can get in the module
* Have fun


## Licence

Noncommercial redistribution and use in source with or without modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain this copyright notice, this list of conditions and the following disclaimer.
* If you think this project is good, buy me a beer when we meet. Or make a donation to an NGO like the red cross or an NGO supporting environmental protection (one you think is supporting, not just annoying people). Or make our world better in some other way :)

USE AT YOUR OWN RISK! THIS SOFTWARE IS PROVIDED ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL OLEX BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE

For commercial use ask me (Olex) and we will find an agreement.

All trademarks belong to their respective owners.
