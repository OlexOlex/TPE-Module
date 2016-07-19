function seqOpt(selectedSeq, files)
    local tempbuf = "<option"
    if(selectedSeq == "-") then
        tempbuf = tempbuf.." selected"
    end
    tempbuf = tempbuf..">-</option>"    
    for seq,_ in pairs(files) do
        tempbuf = tempbuf.."<option"
        if (selectedSeq == seq) then
            tempbuf = tempbuf.." selected"
        end
        tempbuf = tempbuf..">"
        tempbuf = tempbuf..seq
        tempbuf = tempbuf.."</option>"
    end
    return tempbuf 
end

-- reads next pwm - timedelta pair, sets the pwm value and the timer
function nextSeqStep(seqname, pwmpin, timerID, currStep)
    local f = file.open(seqname);
    if(f == true) then
        currStep = currStep + 1
        -- read initial line (has no information) plus x steps on. Done in the for loop since lua only compares whether the value is larger in such for loops...
        for i = 0, currStep, 1 do
            line = file.readline();
        end
        file.close()
        if(line == nil) then
            return
        end
        local firstval = ""
        local secval = ""
        for k, v in string.gmatch(line, "(%w+), (%w+)") do
            firstval = k
            secval = string.gsub(v, "\n", "")
        end
        if(firstval ~= nil and secval ~= nil) then
            duty = tonumber(firstval)
            time = tonumber(secval)
        end
        if(duty ~= nil) then
            -- set pwm duty, start timer
            pwm.setduty(pwmpin, duty)
            tmr.alarm(timerID, time, 0, function() 
                nextSeqStep(seqname, pwmpin, timerID, currStep)
            end)
        else
            if(firstval == "repeat") then
                if(time ~= nil) then
                    -- TODO only finite times repeating
                else
                    if(secval == "infinite") then
                        -- start over
                        nextSeqStep(seqname, pwmpin, timerID, 0)
                    else
                        -- end sequence - turn off
                        pwm.setduty(pwmpin, 0)
                    end
                end
            end
        end
    end
end

-- react to successful connection to a wifi network
function onWifiCon()
    local ssid, _, _, _=wifi.sta.getconfig()
    print("connected to wifi "..ssid)
    -- important: works only with nodemcu newer than 05.01.2016
    wifi.sta.sethostname(cfg.hostname)
end

-- search for the first known wifi accesspoint and connect to it
function connectToWifi(aplist)
    for ssid,v in pairs(aplist) do
        -- we do know "wifis" (list of ssid/password pairs) from startup
        for knownssid, pwd in pairs(wifis) do
            -- connect to the first known, then return
            if(ssid == knownssid) then
                wifi.sta.config(ssid, pwd)
                print("connecting to wifi "..ssid)
                return
            end
        end
    end
    -- if no known wifi found, try again in 1 second
    tmr.alarm(0, 1000, 0, function() 
                wifi.sta.getap(connectToWifi)
            end)
end

-- raise CPU frequency for startup
node.setcpufreq(node.CPU160MHZ)
-- turn power on (so the Power button does not need to be pushed anymore)
-- GPIO15 used for this
gpio.mode(8, gpio.OUTPUT)
gpio.write(8, gpio.HIGH)


collectgarbage()
print("Webserver v1.0")


-- make sure to use the right ADC mode (if wrong mode was set, restart the module with adjusted settings)
-- if you cange this from adc.INIT_VDD33 to adc.INIT_ADC make sure later you use
-- adc.read() instead of adc.readvdd33(0) to read the voltage, and vice versa...
-- only works in newer versions of NodeMCU 
--if(adc.force_init_mode(adc.INIT_VDD33))then
    --node.restart()
--end

-- initial field declaration
wificfg = {}
cfg = {}

-- read server config file
if(file.open("ESPWebserver.conf") ~= nil)then
    print("Webserver config opened")
    currline = file.readline()
    while(currline ~= nil) do
        -- if Line is comment, ignore
        if (string.sub(currline,1,1) ~= "#") then
            for k, v in string.gmatch(currline, "([^=]+)=(.+)") do
                -- remove possible line break from v before setting value
                cfg[k] = string.gsub(v, "\n", "")
            end
        end
        currline = file.readline()
    end
    file.close()
else
    print("ERROR opening ESPWebserver.conf")
end

-- important: works only wiht nodemcu newer than 05.01.2016
if(wifi.sta.sethostname(cfg.hostname) == true) then
    print("hostname set")
end


-- initialize PWM output
-- pwm.setup(pin, frequency (Hz), duty cycle)
pwm.setup(cfg.pwm1pin,100,0) 
pwm.setup(cfg.pwm2pin,100,0) 
pwm.setup(cfg.pwm3pin,100,0)
pwm.start(cfg.pwm1pin) 
pwm.start(cfg.pwm2pin) 
pwm.start(cfg.pwm3pin)

gpio.mode(cfg.pin1, gpio.OUTPUT)
gpio.mode(cfg.pin2, gpio.OUTPUT)

-- initialize variables
pwm1rate = 0
pwm2rate = 0
pwm3rate = 0
seq1 = "-"
seq2 = "-"
seq3 = "-"
newseq1 = 0
newseq2 = 0
newseq3 = 0

-- register Callbacks to ensure wifi connectivity
wifi.sta.eventMonReg(wifi.STA_GOTIP, onWifiCon)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("Wrong password for wifi network"); wifi.sta.getap(connectToWifi) end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("Wifi network no longer exists"); wifi.sta.getap(connectToWifi) end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("Failed to connect to wifi network. Unknown reason"); wifi.sta.getap(connectToWifi) end)

-- read wifi config file
wifis = {}
apcfg = {}
if(file.open("ESPWIFI.conf") ~= nil)then
    print("Wifi config opened")
    local currline = file.readline()
    while(currline ~= nil) do
        -- if Line is comment, ignore
        if (string.sub(currline,1,1)~="#") then
            for k, v in string.gmatch(currline, "([^=]+)=(.+)") do
                if(k ~= nil) then
                    -- first wifi config is AP config
                    if(apcfg.ssid == nil) then
                        apcfg.ssid = k
                        -- remove possible line break from v before setting value
                        apcfg.pwd = string.gsub(v, "\n", "")
                        print("read config for accespoint")
                    else
                        wifis[k] = string.gsub(v, "\n", "")
                    end
                end
            end
        end
        currline = file.readline()
    end
    file.close()
end

-- depending on configuration, set up WIFI as accespoint and/or client
if(cfg.wifitype =="ap") then
    wifi.setmode(wifi.SOFTAP)
    if(cfg.APmode == b) then
        wifi.setphymode(wifi.PHYMODE_B)
    elseif(cfg.APmode == g) then
        wifi.setphymode(wifi.PHYMODE_G)
    elseif(cfg.APmode == n) then
        wifi.setphymode(wifi.PHYMODE_N)
    end
    wifi.ap.config(apcfg)
    print("Accesspoint only mode. SSID: "..apcfg.ssid)
    -- don't start wifi event monitor, since there are no events in ap mode
elseif(cfg.wifitype == "cl") then
    wifi.setmode(wifi.STATION)
    --start WiFi event monitor with 200ms interval
    wifi.sta.eventMonStart(200)
    -- scan for wifi accespoints, then try to connect to the first known
    wifi.sta.getap(connectToWifi)
    print("Client only mode. Connecting to first known wifi.")
elseif(cfg.wifitype == "mix") then
    wifi.setmode(wifi.STATIONAP)
    wifi.ap.config(apcfg)
    print("Mixed mode. Accesspoint SSID: "..apcfg.ssid)
    --start WiFi event monitor with 200ms interval
    wifi.sta.eventMonStart(200)
    -- scan for wifi accespoints, then try to connect to the first known
    wifi.sta.getap(connectToWifi)
else
    print("Unknown wifi mode specified")
end

-- finds sequence files and returns a list of their names
seqfiles = file.list() 
-- use filename, ignore size
for currfile,_ in pairs(seqfiles) do
    file.open(currfile)
    -- read line, but remove newline char
    firstline = string.gsub(file.readline(), "\n", "")
    if(firstline ~= nil) then
            -- check if first line starts with "pwmsequence"
            if (firstline == "pwmsequence") then
                print("found pwm sequence: "..currfile)
            else
                --print("no sequence file: "..currfile.." - first line: "..firstline)
                seqfiles[currfile] = nil
            end
    else
        --print("empty file - no sequence: "..currfile)
        seqfiles[currfile] = nil
    end
    file.close()
end
-- now forget about the size information and free heap space
-- not used since it would use too much ram while cleaning...
--seqfiles = {}
--for currfile,_ in pairs(seqfilelists) do
    --table.insert(seqfiles, currfile)
    --seqfilelists[currfile] = nil
--end
-- free memory
--seqfilelists = nil

-- lower CPU frequency again for lower power consumption
node.setcpufreq(node.CPU80MHZ)

print("starting server")
-- start server
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        -- raise CPU frequency until done
        node.setcpufreq(node.CPU160MHZ)
        
        local _POST = {}
        -- create Headline of Page
        local buf = "<!DOCTYPE html><html>"
        -- get ending of url
        local path = string.match(request, "POST (.+) HTTP/.*")
        if(path == nil) then
            path = string.match(request, "GET (.+) HTTP/.*")
        end
        
        -- get last line of payload, which contains = characters. If the request was a post-request, this gets the parameters
        local params = string.match(request, ".*\n([^\n]+=[^\n]+)")
        if(params ~= nil) then
            --print("parameters: "..params)
            for k, v in string.gmatch(params, "([^=&]+)=([^&]+)&*") do
               _POST[k] = v
            end
        end
        -- react according to the url ending
        if(path == nil or path == "/") then
            --print("got a general request")
            buf = buf.."<head><title>"..cfg.servername.."</title><meta name=\"viewport\" content=\"width=300, initial-scale=1, maximum-scale=5\"></head><body><font size=\""..cfg.titlesize.."\">"
            buf = buf..cfg.servername.."</font><br><br><a href=\"c\" target=\"m\">"..cfg.configstr.."</a> <a href=\"s\" target=\"m\">"..cfg.statusstr
            buf = buf.."</a><br><iframe name=\"m\" src=\"c\" height=\""..cfg.frameh.."\" width=\""..cfg.framew.."\"></iframe></body></html>"
        elseif(path == "/s") then
            --print("got status request")
            if(_POST.pwd == cfg.pwd and _POST.off == "1") then
                print("Power off")
                gpio.write(8, gpio.LOW)
            end
             
            -- depending on the version of NodeMCU you need adc.readvdd33() (to read the internal supply voltage) or (adc.read(0)*4) (to read the external voltage on pin ADC using 1.5k to GND and 4.7k to VBat (1 Cell LiPo)
            buf = buf.."<body><form action=\"\" method=\"post\">"..cfg.statusstr.."<br><br>"..cfg.vstr.." "..(adc.read(0)*4).." mV<br><br>"
            -- not sufficient:
            --if(cfg.wifitype ~= "ap")then
            if(wifi.sta.status() == 5) then
                buf = buf.."WiFi client IP: "..wifi.sta.getip().."<br>WiFi client hostname: "..wifi.sta.gethostname().."<br><br>"
            end
            buf = buf..cfg.pwdstr.." <input type=\"password\" name=\"pwd\"/><br><br><input type=\"checkbox\" name=\"off\" value=\"1\"> <input type=\"submit\" value=\""..cfg.turnoffstr.."\" size=\"7\"></body></html>"
            
        elseif(path == "/c") then
            --print("got a config request")
            -- if the password is right or no password to be asked for
            if(_POST.pwd == cfg.pwd) then
                -- turn all gpio, pwm, timer off and do nothing else but respond
                if(_POST.alloff == "1") then
                    tmr.stop(1)
                    tmr.stop(2)
                    tmr.stop(3)
                    pwm.setduty(cfg.pwm1pin, 0)
                    pwm.setduty(cfg.pwm2pin, 0)
                    pwm.setduty(cfg.pwm3pin, 0)
                    pwm1rate = 0
                    pwm2rate = 0
                    pwm3rate = 0
                    seq1 = "-"
                    seq2 = "-"
                    seq3 = "-"
                    newseq1 = 0
                    newseq2 = 0
                    newseq3 = 0
                else

                    if((_POST.seq1 ~= nil) and (_POST.seq1 ~= seq1)) then
                        seq1 = _POST.seq1
                        newseq1 = 1
                        pwm1rate = 0
                    end

                    if((_POST.seq2 ~= nil) and (_POST.seq2 ~= seq2)) then
                        seq2 = _POST.seq2
                        newseq2 = 1
                        pwm2rate = 0
                    end

                    if((_POST.seq3 ~= nil) and (_POST.seq3 ~= seq3)) then
                        seq3 = _POST.seq3
                        newseq3 = 1
                        pwm3rate = 0
                    end

                    if((_POST.pwm1 ~= nil) and (seq1 == "-") and cfg.pwm1en == "en") then
                        -- make sure no sequence is running in parallel
                        tmr.stop(1)
                        pwm1preratio = tonumber(_POST.pwm1)
                        if(pwm1preratio ~= nil) then
                            if( ( pwm1preratio <= 1023 ) and ( pwm1preratio >=0 ) ) then
                                pwm1rate = pwm1preratio
                                pwm.setduty(cfg.pwm1pin, pwm1rate)
                            end
                        end
                    end

                    if((_POST.pwm2 ~= nil) and (seq2 == "-") and cfg.pwm2en == "en") then
                        -- make sure no sequence is running in parallel
                        tmr.stop(2)
                        pwm2preratio = tonumber(_POST.pwm2)
                        if(pwm2preratio ~= nil) then
                            if( ( pwm2preratio <= 1023 ) and ( pwm2preratio >=0 ) ) then
                                pwm2rate = pwm2preratio
                                pwm.setduty(cfg.pwm2pin, pwm2rate)
                            end
                        end
                    end

                    if((_POST.pwm3 ~= nil) and (seq3 == "-") and cfg.pwm3en == "en") then
                        -- make sure no sequence is running in parallel
                        tmr.stop(3)
                        pwm3preratio = tonumber(_POST.pwm3)
                        if( pwm3preratio ~= nil ) then
                            if( ( pwm3preratio <= 1023 ) and ( pwm3preratio >=0 ) ) then
                                pwm3rate = pwm3preratio
                                pwm.setduty(cfg.pwm3pin, pwm3rate)
                            end
                        end
                    end
                
                end
            else
                -- if password was not correct
                -- do not send anything about it, the sending buffer might overflow
                --buf = buf.."<font size=\"5\" color=\"red\"><b>"..cfg.wrongpasswordstr.."</b></font><br><br> "
                print("wrong password")
            end
            -- create HTML website
            -- start with sliders for PWM outputs
            buf = buf.."<body><form action=\"\" method=\"post\" ><font size=\""..cfg.textsize.."\" face=\"Verdana\">"
            if(cfg.pwm1en == "en") then
                -- TODO: display current rate in %
                buf = buf..cfg.pwm1..cfg.iscurrstr..pwm1rate.."<br> <input type=\"range\" name=\"pwm1\" value=\""..pwm1rate
                buf = buf.."\"  min=\"0\" max=\"1023\" class=fw><br><select name=\"seq1\">"..seqOpt(seq1, seqfiles).."</select><br><br>"
            end
            if(cfg.pwm2en == "en") then
                -- TODO: display current rate in %
                buf = buf..cfg.pwm2..cfg.iscurrstr..pwm2rate.."<br> <input type=\"range\" name=\"pwm2\" value=\""..pwm2rate
                buf = buf.."\"  min=\"0\" max=\"1023\" class=fw><br><select name=\"seq2\">"..seqOpt(seq2, seqfiles).."</select><br><br>"
            end
            if(cfg.pwm3en == "en") then
                -- TODO: display current rate in %
                buf = buf..cfg.pwm3..cfg.iscurrstr..pwm3rate.."<br> <input type=\"range\" name=\"pwm3\" value=\""..pwm3rate
                buf = buf.."\"  min=\"0\" max=\"1023\" class=fw><br><select name=\"seq3\">"..seqOpt(seq3, seqfiles).."</select><br><br>"
            end
            -- add binary pin functions
            if(cfg.pin1en == "en") then
                buf = buf.."<input type=\"checkbox\" name=\"pin1\" value=\"1\"/> "..cfg.pin1n
            end
            if(cfg.pin2en == "en") then
                buf = buf.."<br><br><input type=\"checkbox\" name=\"pin2\" value=\"1\"/> "..cfg.pin2n
            end
            -- add emergency stop / lazy way to turn everything off
            buf = buf.."<br><br><input type=\"checkbox\" name=\"alloff\" value=\"1\"> "..cfg.alloffstr.."<br><br>"
            if(cfg.pwd ~= nil) then
                -- ask for Password if one is set- unsafe via POST request, but this works for our purpose
                -- TODO: do it in a good way! (no unencrypted HTTP-POST / GET!)
                buf = buf.."<br>"..cfg.pwdstr.." <input type=\"password\" name=\"pwd\"/><br><br>"
            end

            buf = buf.."<input type=\"submit\" value=\""..cfg.setvalstr.."\" size=\"7\"> </font></form><style scoped>.fw {width: 90%}</style></body></html>"
            
            -- print answer html site:
            --print(buf)
            --print("free heap: "..node.heap())
        end
        -- answer request
        client:send(buf)
        client:close()

        -- if the password is right or no password to be asked for
        if(_POST.pwd == cfg.pwd) then
            -- take care of the binary pin functions and start PWM sequences, now that the request was answered
            if(_POST.pin1 ~= nil and cfg.pin1en == "en") then
                if( _POST.pin1 == "1" ) then
                    gpio.write(cfg.pin1, gpio.HIGH)
                    -- optionally wait for X ms
                    gpio.write(cfg.pin1, gpio.LOW)
                end
            end

            if(_POST.pin2 ~= nil and cfg.pin2en == "en") then
                if( _POST.pin2 == "1" ) then
                    gpio.write(cfg.pin2, gpio.HIGH)
                    -- optionally wait for X ms
                    gpio.write(cfg.pin2, gpio.LOW)
                end
            end

            -- sequences were allready read, react if they are newly set
            if(newseq1 == 1 and cfg.pwm1en == "en") then
                tmr.stop(1)
                nextSeqStep(seq1, cfg.pwm1pin, 1, 0)
                newseq1 = 0
            end

            if(newseq2 == 1 and cfg.pwm2en == "en") then
                tmr.stop(2)
                nextSeqStep(seq2, cfg.pwm2pin, 2, 0)
                newseq2 = 0
            end

            if(newseq3 == 1 and cfg.pwm3en == "en") then
                tmr.stop(3)
                nextSeqStep(seq3, cfg.pwm3pin, 3, 0)
                newseq3 = 0
            end
        end
        -- reset CPU frequency to 80MHz
        node.setcpufreq(node.CPU80MHZ)
        -- Done. Send in cleaning team
        collectgarbage()
    end)
end)
