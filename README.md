# TPE-Module
**A simple, small, cheap and relatively easy to build module to control 3 PWM driven and 2 binary (on/off) outputs via WIFI and a webinterface** (designed for controlling 3 vibrators and 2 other custom modules, especially in BDSM plays, that's why there is a password protection available)

Runs on any newer ESP8266 module running NodeMCU (the ones with more RAM than the first version, usually featuring 4MB flash)
I recommend an integer version of NodeMCU, the floatingpoint accurate version might most probably use too much RAM.

To flash NodeMCU to your module you can use programs like [esptool.py](https://github.com/themadinventor/esptool/blob/master/esptool.py)

To access the NodeMCU filesystem you can use programs like [ESPlorer](http://esp8266.ru/esplorer/)
You need it to upload the Lua server program, the two configuration files (ESPWIFI.conf and ESPWebserver.conf) and any sequence files. You also need it to test (execute) the Lua server program before renaming it so it gets executed automatically at startup (broken init.lua files might brick your module and force you to re-flash NodeMCU to un-brick it).

In case you change anything in the Lua server program, remember to compress the Lua program for uploading it using [Luasrcdiet](http://esp8266.ru/esplorer/) (otherwise it will most likely bust the modules RAM when executing).

Documentation is not finished by now, I hope this README, the comments, the images and 3D-drawings provided suffice. Browse the project, it consists of only a few files separated into a software and a hardware part.

The Module with an attached vibrating bullet can look like this:

![Module photos](https://github.com/OlexOlex/TPE-Module/blob/master/Hardware%2BChassis/Pictures/IMG_20160630_033513.jpg)

The website can look like this in english, there is an english and a german sample config file available (enable or disable any output, name anything as you wish. The "Unlock" and "Beep" are just an example, you need to attach a custom module to an output port in order to get any functionality from the two binary outputs)

![Main website screenshot](https://github.com/OlexOlex/TPE-Module/blob/master/Software/Pictures/English_website_v1.0.png) ![Status and turn-off website screenshot](https://github.com/OlexOlex/TPE-Module/blob/master/Software/Pictures/English_website_status_wifi_v1.1.png)

## Features:
* Provides a **WIFI-accesspoint** and/or **connects to a (list of) WIFI(s)**, e.g. control it via your home WIFI or outside via the accesspoint
* **Control via web page** in most modern browsers on most systems in the same network (Tested on linux and Android 4.4, only Windows seems to make trouble) - you can also control it with anything that can send HTTP-POST request, e.g. with curl or wget from a linux server, e.g. in a cronjob or bash-/shellscript on a Raspberry Pi
* **No need for a dedicated app**, call the webpage from the private browsing window of your business cell phone and no traces are left, "Is my platform supported?" is answered by "If it has a browser and network access, most probably yes"
* Controls up to **three vibrators** or other things/external modules 0 - 1023 (though the  1-150 are usually useless for vibrators) or runs sequences on the vibrators that are defined in customizable sequence files
* Controls up to **two other external modules** like e-stim, a magnetic (un)lock, a beeper, etc. (gives a short on-signal)
* Nearly everything of the website as well as the WIFI options can be **customized by 2 configuration files** on the integrated primitive filesystem (sadly / luckily not like a USB-stick, you need an easy to use free Java software for access: ESPlorer) 
* Supports many **custom sequences for vibrators** (at least 5 - limited only by NodeMCUs buffer size of 1460 Byte for each output IP packet. This might change in newer versions to even smaller packets) Each sequence is a file in the filesystem with a simple and easy format, available sequence files are autodetected on boot. Name these files as you want the sequences to be shown in the drop down menus
* Runs at least for **13 hours idling** (WIFI acesspoint running, one client connected, simultaniously connected to a WIFI network, a few website requests) with a 3,7V 1200mAh LiPo battery (uses approx. 90mA in idle). Without a client connected to the accesspoint, it runs over 14 hours. It **lasts longer than 30 hours** idling when it does not provide an accesspoint. After that, charge it for 1.5 hours with 1A and you are good to go.
* Turns on on 1 sec button press, you can **turn it off on the website only** - or customize the hardware by using a switch to turn it on and off
* Tick "Turn all off" and then press "Set values" to turn all outputs off (kind of lazy off or "emergency off")
* Configurable **password protection** (enable it by defining a password in the server config file, for disabling password protection make the line defining it a comment)
* **86x51x21,5mm** in size - smaller than a pack of cigaretts. Depending on your skills and the features you want your module to have, you can build it in different cases.
* "Status" page that shows you (roughly!) the current battery voltage and lets you turn off the module (with a voltage divider of 1.5k Ohm to 4.7k Ohm and a multiplication by 4 (as shown/done in the files) below a measured supply voltage of 3000mV the battery will drain quickly (10-15 minutes remain with a 1.5Ah LiPo cell)
* Access it in the local network at its IP, http://[your configured servername here] or its "node-XXXXX" name if the registering of the host name did not work, or http://192.168.4.1 if your device is connected to the modules' accesspoint
* Sockets provide ground, battery voltage and the signal (on = tied to ground, max 0.5A each, max ~3A alltogether until the battery protection turns off power. off = no potential) when the module is turned on, so you can permanently **power external modules/cirquits if needed**, or **run a motor directly** between the signal line and the battery voltage line
* Charge it and access the integrated file system by the integrated usb-serial-adapter with a common **micro USB** cable
* **Noncommercially open source** - details see Licence.txt (tl;dr: No guarantees on anything, use at your own risk, if you think it's good, buy me a beer when we meet or be a good guy in general. In case you want to use it commercially, contact me and we'll find an agreement)
* Material cost: **approximately 14€** for me when buying the stuff in China. Buy it at Aliexpress and then wait for 1.5 months for the items to arrive. (For me two never arrived, I got a refund and got them somewhere else, that is why the ULN2003 module is replaced by a single ULN2003A chip in the photos) A list of the parts is in an OpenOffice spreadsheet in the Hardware+Chassis directory, Ebay and other sources might be good sources as well)
* **Relatively easy to build, most parts are premanufactured ready-to-use-modules**, the connectors are common 3.5mm stereo jacks
* Any simple 3-4V vibrating device with a remote control on a cable can easily be converted to fit this module (and if you solder a socket to the original remote control, you can still use the device with the original remote control )

### Disadvantages:
* Does not (yet?) work with browsers on Windows (tested on Windows 8.1 with Internet Explorer, Google Chrome and Firefox)
* If a browser/system splits an HTTP-POST request to multiple packets (one the HTTP-request, one containing the POST-parameters) it might not work or need a page reload after every request to display the current settings (quickfix for you might be to change a forms request type from POST to GET at two places where the code returns a webpage and change the standard mapping for POST requests to the alternative GET variant)
* It sometimes takes a while until the router knows the device under its configured name, so it might take some time until you can access it at http://[your configured servername here] - once NodeMCU behaviour seems to have changed at that point as well

### Minor "not as perfect as it could be" properties:
* The module runs a Lua interpreter, which was not designed for running a webserver on it, but this project does so. So the current state is close to busting the modules RAM
* "compiling" the script to a .lc file to speed up execution time makes it bigger, thus exceeds the RAM and does not execute at all
* the ESP8266 Module does only support at maximum 4 client devices connected to its WIFI accesspoint
* The voltage reading is rough (only real numbers, no float numbers available for multiplication in the integer version of nodeMCU which is needed for reducing RAM usage)
* The requests are unencrypted HTTP-POST requests - no ssl encryption used
* The Lua-interpreter-firmware (NodeMCU) is still under (heavy?) development, so some functionalities change (for the voltage measuring standard source and the hostname setup I experienced it), and before acessing the filesystem via ESPlorer, you might need to send the =node.heap() command ("Heap"-button) a few times to synchronize the connection
* You could crash the system and force it to reboot by malicously manufactured requests. Requires advanced knowledge.


## Material used for this "full feature" Model:
Detailed information and sample links to the product pages of some online shops are provided in an OpenOffice spreadsheet in the "Hardware" directory. (I got most of it on Aliexpress, Ebay, Amazon and other sources might work as well)
* ESP8266 module ESP-12 (or ESP-12E / ESP-12F) 
* TP4056 micro-USB LiPo charging board with overcurrent and undervoltage protection (not just safe charging but safe discharging as well)
* CP2102 micro-USB to serial adapter (or another 3.3V compatible one)
* ULN2003A chip or module for driving the outputs
* AMS1117 3.3V 800mA voltage regulator (yes, the cheap ones might only reach 2.9V on a close-to-empty battery, but the module runs even with 2.4V, so any cheap one will suffice)
* 3,7V single cell LiPo battery (without any further protection circuit) 62,8mm x 30,3mm x 7,3mm 1200mAh
* ABS plastic box 86x50x21,5mm (or 85x50x21,5mm according to other vendors) or similar
* Button (pus = on, no push = off), a waterproof one might be good
* 5 sockets for 3.5mm stereo audio jacks - use the threaded ones, they are better for glueing to the chassis and can be screwed to the chassis when you drill the outer half of the mounting hole with a larger drill
* Resistors (7x 4,7kOhm, 2x 1,5kOhm)
* 1 Diode (Germanium, silicon may result in a higher voltage drop)
* Cables (a few thicker ones for the main power, thinner ones for the signals)
* 1 N-Channel (MOS)FET transistor (I used an AOD407)
* 1 NPN Transistor (used one of the primitive BC108 ones, but likely any one turning on at 3.3V or lower will work)
* Additionally you might want dust covers for the micro-USB port and the sockets, a "prototyping" pcb (no breadboard) and shrinking tube might be useful as well
* For building a small bullet vibrator a common mobile phone vibration motor and some tube, shrinking tube and a rubber foot/etc for a case + a 2 wire cable

### Tools needed:
* A soldering iron and some solder
* A side cutter or strong scissors for cutting wires, a wire stripper might be handy, but if you are carefully or handy, you don't need one
* An electric drilling machine (a vertical drilling machine is even more useful)
* A 5mm steel drill for drilling the holes for the 3,5mm sockets to stick through the case, optionally an 8mm steel drill to widen the front of the holes to screw the nuts to the sockets
* A steel drill with the same diameter as the buttons' shaft (or a smaller one and a milling cutter/file for enlargening the hole)
* A 4mm drill and/or milling cutter for drilling the hole for the micro-USB socket (multiple holes next to each other becoming a slot)
* A trianglular or semi-circle file for cleaning the hole for the micro-USB socket
* Waterproof glue and hot glue or similar to glue the components safely together and to the case (two component resin or silicon might work as well)
* Something to measure and mark where to drill the holes in the case

## How to build one:
* Build the hardware by wiring everything together (don't use the chassis yet)
* Get an image of the NodeMCU firmware, e.g. the copy provided in this project or get a new one, e.g. at http://nodemcu-build.com/ (!!!*dev branch*!!! many functionalities are not available in the old "stable" branch)
* Flash this image on your ESP-module by turning it on while having a wire between GND ("Minus") and GPIO0 -keep the power button pressed or shortened so it does not turn off again! You can remove the wire from GPIO0 a few moments after tunring the module on. You also might want to have the battery disconnected for this step for security reasons.
* Reboot the module by releasing the power button/shorting, removing the wire to GPIO0 (if you did not allready), and pressing/shorting the power button again (keep presssed/shortened).
* Upload the server Lua script (compressed by Luasrcdiet), the config files and any sequence file you want using e.g. ESPlorer. You might need to request the currently free heap space a few times before the connection is properly synchronized ("Heap"-button in ESPlorer). If you get weird characters but nothing works, close the serial port, change the baud rate (9600 or 115200 most likely) and open it again, then try again reading the free heap space.
* To test it, execute the server script by reloading the file list in ESPlorer ("Reload" button) and click on the file to run it
* If there are no error messages in ESPlorer, your module does not turn off after releasing the button/removing the shorting and there is a WIFI named "remoteWIFI", it works. Try connecting to the WIFI using the password of the WIFI configuration file ("pwd") and test the output sockets (default website passwords: in the english condfg file: mypassword, in the german config file: meinPasswort)
* Change the name of the server Lua script to "init.lua", change your configuration files as you wish and upload them, turn off the module and restart it
* If everything works, assemble the hardware in the chassis to find out and mark where you want to drill the holes (you need a hole for every 3.5mm socket, one for the button, and a slot for the micro-USB socket). Then drill the holes, next assemble and fix everything to the chassis. Don't forget to test if everything works. Additionally you can seal everything with glue and hot glue or whatever you think is useful, so no water can get in the module, or at least hardly any. Be careful though, you do not want to get any glue in the micro-USB socket.
* Have fun

Questions? Ask me via olexolex at gmx dot de.

## Tested on the following platforms:
Worked on
* Android 4.4 - Android Browser, Firefox
* Kubuntu Linux - Firefox, Chromium
* Linux command line - curl

Changing settings did not work on
* Windows 8.1 - Firefox, Google Chrome, Internet Explorer


## Licence

See [Licence.txt](https://github.com/OlexOlex/TPE-Module/blob/master/Licence.txt)
