# How to build a module (Text not finished, under onstruction!)


## Material you need, in brackets the things used for the full-feature-model:
Detailed information and sample links to the product pages of some online shops are provided in an OpenOffice spreadsheet in the "Hardware" directory. (I got all of it on Aliexpress. Ebay, Amazon and other sources might work as well)
* 1 ESP8266 module, ESP-12 is fitting best at the time (or ESP-12E / ESP-12F)
* 1 battery charging module working as a UPS and a fitting battery (TP4056 micro-USB LiPo charging board with overcurrent and undervoltage protection and a 3,7V single cell LiPo battery without any further protection circuit 62,8mm x 30,3mm x 7,3mm 1200mAh)
* 1 3.3V compatible micro-USB to serial adapter (CP2102 board)
* 1 FET- or transistor array chip (ULN2003A) or module for driving the outputs
* 1 3.3V >300mA voltage regulator (AMS1117) yes, the cheap ones might only reach 2.9V on a close-to-empty battery, but the module runs even with 2.4V, so any cheap one will suffice
* 1 case, which does not shield WIFI (ABS plastic box 86x50x21,5mm or 85x50x21,5mm)
* 1 push button (push = on, no push = off), a waterproof one might be good
* up to 5 sockets for the devices you want to connect if you don't solder their wires directly to the transistor array (5 threaded sockets for 3.5mm stereo audio jacks threaded ones, they are better for glueing to the chassis and can be screwed to the chassis)
* 7 Resistors 4,7kOhm
* 2 Resistors 1,5kOhm
* 1 Diode (Germanium diode!, silicon may result in a too high voltage drop)
* Cables (a few thicker ones for the main power, thinner ones for the signals are good)
* 1 N-Channel (MOS)FET transistor (AOD407)
* 1 NPN Transistor (BC108, likely any one turning on at 2.9V or lower will work)
Optionally:
* dust covers for the micro-USB port and the sockets
* 1 "prototyping" pcb (no breadboard) for the transistor array chip and possibly the power controlling cirquit
* For building a small bullet vibrator the vibrating bullet of a common two-battery-remote controlled vibrating bullet and a 3.5mm stereo audio jack


## Tools needed for the full feature module:
* A soldering iron and some solder wire
* A side cutter or strong scissors for cutting wires, a wire stripper might be handy, too.
* An electric drilling machine (a vertical drilling machine is even more useful)
* A 5mm steel drill for drilling the holes for the 3,5mm sockets to stick through the case, optionally an 8mm steel drill to widen the front of the holes to screw the nuts to the sockets
* A steel or wood drill with the same diameter as the buttons' shaft (or a smaller one and a milling cutter/file for enlargening the hole)
* A 4mm drill and/or milling cutter for drilling the holes for the micro-USB socket (multiple holes next to each other becoming a slot)
* A trianglular or semi-circle file for cleaning the hole for the micro-USB socket
* Waterproof glue and hot glue or similar, to glue the components safely together and to the case (two component resin or silicon might work as well)
* Something to measure and mark where to drill the holes in the case


## Software Tools needed
* A program to flash binaries to a ESP8266 chip (e.g. [esptool.py](https://github.com/themadinventor/esptool/blob/master/esptool.py) )
* A program to comunicate with NodeMCU, upload files, etc (e.g. [ESPlorer](http://esp8266.ru/esplorer/) )


## How to build one:
* Build the hardware by wiring everything together. Use the chassis only for checking the components' later placement, so everything will fit. For wiring, see [the poor wiring diagram for beginners](https://github.com/OlexOlex/TPE-Module/blob/master/Hardware%2BChassis/Module_Wiring.pdf)
* Get an image of the NodeMCU firmware, e.g. [the copy provided](https://github.com/OlexOlex/TPE-Module/tree/master/Software/NodeMCU-image) in this project, or get a new one, e.g. at http://nodemcu-build.com/ (!!!*dev branch*!!! many functionalities are not available in the old "stable" branch)
* Prepare everything for flashing this image to the module, get your flashing program ready (e.g. on linux in the terminal: ./esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash 0x00000000 ./nodemcu-dev-17-modules-2016-04-24-23-38-30-integer.bin )
* Boot your ESP-module to flash mode (so it accepts new firmare images) by turning it on while having a wire between GND ("Minus") and GPIO0 - keep the power button pressed or shortened so it does not turn off again! You can remove the wire from GPIO0 a few moments after tunring the module on. You also might want to have the battery disconnected for this step for safety reasons.
* Run the flash program
* Reboot the module by releasing the power button/shorting, removing the wire to GPIO0 (if you did not allready), and pressing/shorting the power button again (keep presssed/shortened again).
* Upload the server Lua script (the compressed version!), the config files and any sequence files you want. You might need to request the currently free heap space a few times before the connection is properly synchronized ("Heap"-button in ESPlorer). If you get weird characters but nothing works, close the serial port, change the baud rate (9600 or 115200 most likely) and open it again, then try again reading the free heap space multiple times.
* To test it, execute the server script ( reload the file list in ESPlorer ("Reload" button) and click on the file to run it)
* If there are no error messages in ESPlorer, your module does not turn off after releasing the button/removing the shorting and there is a WIFI named "remoteWIFI", it works. Try connecting to the WIFI using the password of the WIFI configuration file ("password") and test the output sockets (default website passwords: in the english condfg file: mypassword, in the german config file: meinPasswort)
* Change the name of the server Lua script to "init.lua", change your configuration files as you wish and upload all changed files. Then turn off the module (using the website) and restart it by pressing the button for approx. one to two seconds.
* If everything works, assemble the hardware in the chassis to find out and mark where you want to drill the holes (you need a hole for every 3.5mm socket, one for the button, and a slot for the micro-USB socket).
* Mark the holes' centers and drill the holes.
* Assemble everything to the chassis.
* Test if everything works.
* Fix everything to the chassis and each other as you like.
* Additionally you can seal everything with glue and hot glue or whatever you think is useful, so no water can get in the module, or at least hardly any. Be careful though, you do not want to get any glue inside the micro-USB socket!
* Have fun!


### Error handling

* If you get no serial connection to the module, make sure it is powered properly and the wiring to the USB-serial adaper is properly done. When powering on, ususally the LED on the ESP board lights up for a short time
* If you brick your module by a corrupt init.lua file or something, just flash NodeMCU to the module and start again with uploading your files to the module.
* If you get "invalid header" every time when flashing (after a successful flash erase), the flash chip of your ESP board might be broken and you need to replace the board (or the chip, if you are good enough).
