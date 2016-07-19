function seqOpt(t,a)
local e="<option"
if(t=="-")then
e=e.." selected"
end
e=e..">-</option>"
for a,o in pairs(a)do
e=e.."<option"
if(t==a)then
e=e.." selected"
end
e=e..">"
e=e..a
e=e.."</option>"
end
return e
end
function nextSeqStep(i,o,n,a)
local e=file.open(i);
if(e==true)then
a=a+1
for e=0,a,1 do
line=file.readline();
end
file.close()
if(line==nil)then
return
end
local e=""
local t=""
for a,o in string.gmatch(line,"(%w+), (%w+)")do
e=a
t=string.gsub(o,"\n","")
end
if(e~=nil and t~=nil)then
duty=tonumber(e)
time=tonumber(t)
end
if(duty~=nil)then
pwm.setduty(o,duty)
tmr.alarm(n,time,0,function()
nextSeqStep(i,o,n,a)
end)
else
if(e=="repeat")then
if(time~=nil)then
else
if(t=="infinite")then
nextSeqStep(i,o,n,0)
else
pwm.setduty(o,0)
end
end
end
end
end
end
function onWifiCon()
local e,t,t,t=wifi.sta.getconfig()
print("connected to wifi "..e)
wifi.sta.sethostname(cfg.hostname)
end
function connectToWifi(e)
for e,t in pairs(e)do
for a,t in pairs(wifis)do
if(e==a)then
wifi.sta.config(e,t)
print("connecting to wifi "..e)
return
end
end
end
tmr.alarm(0,1000,0,function()
wifi.sta.getap(connectToWifi)
end)
end
node.setcpufreq(node.CPU160MHZ)
gpio.mode(8,gpio.OUTPUT)
gpio.write(8,gpio.HIGH)
collectgarbage()
print("Webserver v1.0")
wificfg={}
cfg={}
if(file.open("ESPWebserver.conf")~=nil)then
print("Webserver config opened")
currline=file.readline()
while(currline~=nil)do
if(string.sub(currline,1,1)~="#")then
for e,t in string.gmatch(currline,"([^=]+)=(.+)")do
cfg[e]=string.gsub(t,"\n","")
end
end
currline=file.readline()
end
file.close()
else
print("ERROR opening ESPWebserver.conf")
end
if(wifi.sta.sethostname(cfg.hostname)==true)then
print("hostname set")
end
pwm.setup(cfg.pwm1pin,100,0)
pwm.setup(cfg.pwm2pin,100,0)
pwm.setup(cfg.pwm3pin,100,0)
pwm.start(cfg.pwm1pin)
pwm.start(cfg.pwm2pin)
pwm.start(cfg.pwm3pin)
gpio.mode(cfg.pin1,gpio.OUTPUT)
gpio.mode(cfg.pin2,gpio.OUTPUT)
pwm1rate=0
pwm2rate=0
pwm3rate=0
seq1="-"
seq2="-"
seq3="-"
newseq1=0
newseq2=0
newseq3=0
wifi.sta.eventMonReg(wifi.STA_GOTIP,onWifiCon)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD,function()print("Wrong password for wifi network");wifi.sta.getap(connectToWifi)end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND,function()print("Wifi network no longer exists");wifi.sta.getap(connectToWifi)end)
wifi.sta.eventMonReg(wifi.STA_FAIL,function()print("Failed to connect to wifi network. Unknown reason");wifi.sta.getap(connectToWifi)end)
wifis={}
apcfg={}
if(file.open("ESPWIFI.conf")~=nil)then
print("Wifi config opened")
local e=file.readline()
while(e~=nil)do
if(string.sub(e,1,1)~="#")then
for e,t in string.gmatch(e,"([^=]+)=(.+)")do
if(e~=nil)then
if(apcfg.ssid==nil)then
apcfg.ssid=e
apcfg.pwd=string.gsub(t,"\n","")
print("read config for accespoint")
else
wifis[e]=string.gsub(t,"\n","")
end
end
end
end
e=file.readline()
end
file.close()
end
if(cfg.wifitype=="ap")then
wifi.setmode(wifi.SOFTAP)
if(cfg.APmode==b)then
wifi.setphymode(wifi.PHYMODE_B)
elseif(cfg.APmode==g)then
wifi.setphymode(wifi.PHYMODE_G)
elseif(cfg.APmode==n)then
wifi.setphymode(wifi.PHYMODE_N)
end
wifi.ap.config(apcfg)
print("Accesspoint only mode. SSID: "..apcfg.ssid)
elseif(cfg.wifitype=="cl")then
wifi.setmode(wifi.STATION)
wifi.sta.eventMonStart(200)
wifi.sta.getap(connectToWifi)
print("Client only mode. Connecting to first known wifi.")
elseif(cfg.wifitype=="mix")then
wifi.setmode(wifi.STATIONAP)
wifi.ap.config(apcfg)
print("Mixed mode. Accesspoint SSID: "..apcfg.ssid)
wifi.sta.eventMonStart(200)
wifi.sta.getap(connectToWifi)
else
print("Unknown wifi mode specified")
end
seqfiles=file.list()
for e,t in pairs(seqfiles)do
file.open(e)
firstline=string.gsub(file.readline(),"\n","")
if(firstline~=nil)then
if(firstline=="pwmsequence")then
print("found pwm sequence: "..e)
else
seqfiles[e]=nil
end
else
seqfiles[e]=nil
end
file.close()
end
node.setcpufreq(node.CPU80MHZ)
print("starting server")
srv=net.createServer(net.TCP)
srv:listen(80,function(e)
e:on("receive",function(i,o)
node.setcpufreq(node.CPU160MHZ)
local t={}
local e="<!DOCTYPE html><html>"
local a=string.match(o,"POST (.+) HTTP/.*")
if(a==nil)then
a=string.match(o,"GET (.+) HTTP/.*")
end
local o=string.match(o,".*\n([^\n]+=[^\n]+)")
if(o~=nil)then
for a,e in string.gmatch(o,"([^=&]+)=([^&]+)&*")do
t[a]=e
end
end
if(a==nil or a=="/")then
e=e.."<head><title>"..cfg.servername.."</title><meta name=\"viewport\" content=\"width=300, initial-scale=1, maximum-scale=5\"></head><body><font size=\""..cfg.titlesize.."\">"
e=e..cfg.servername.."</font><br><br><a href=\"c\" target=\"m\">"..cfg.configstr.."</a> <a href=\"s\" target=\"m\">"..cfg.statusstr
e=e.."</a><br><iframe name=\"m\" src=\"c\" height=\""..cfg.frameh.."\" width=\""..cfg.framew.."\"></iframe></body></html>"
elseif(a=="/s")then
if(t.pwd==cfg.pwd and t.off=="1")then
print("Power off")
gpio.write(8,gpio.LOW)
end
e=e.."<body><form action=\"\" method=\"post\">"..cfg.statusstr.."<br><br>"..cfg.vstr.." "..(adc.read(0)*4).." mV<br><br>"
if(cfg.wifitype~="ap")then
e=e.."WiFi client IP: "..wifi.sta.getip().."<br>WiFi client hostname: "..wifi.sta.gethostname().."<br><br>"
end
e=e..cfg.pwdstr.." <input type=\"password\" name=\"pwd\"/><br><br><input type=\"checkbox\" name=\"off\" value=\"1\"> <input type=\"submit\" value=\""..cfg.turnoffstr.."\" size=\"7\"></body></html>"
elseif(a=="/c")then
if(t.pwd==cfg.pwd)then
if(t.alloff=="1")then
tmr.stop(1)
tmr.stop(2)
tmr.stop(3)
pwm.setduty(cfg.pwm1pin,0)
pwm.setduty(cfg.pwm2pin,0)
pwm.setduty(cfg.pwm3pin,0)
pwm1rate=0
pwm2rate=0
pwm3rate=0
seq1="-"
seq2="-"
seq3="-"
newseq1=0
newseq2=0
newseq3=0
else
if((t.seq1~=nil)and(t.seq1~=seq1))then
seq1=t.seq1
newseq1=1
pwm1rate=0
end
if((t.seq2~=nil)and(t.seq2~=seq2))then
seq2=t.seq2
newseq2=1
pwm2rate=0
end
if((t.seq3~=nil)and(t.seq3~=seq3))then
seq3=t.seq3
newseq3=1
pwm3rate=0
end
if((t.pwm1~=nil)and(seq1=="-")and cfg.pwm1en=="en")then
tmr.stop(1)
pwm1preratio=tonumber(t.pwm1)
if(pwm1preratio~=nil)then
if((pwm1preratio<=1023)and(pwm1preratio>=0))then
pwm1rate=pwm1preratio
pwm.setduty(cfg.pwm1pin,pwm1rate)
end
end
end
if((t.pwm2~=nil)and(seq2=="-")and cfg.pwm2en=="en")then
tmr.stop(2)
pwm2preratio=tonumber(t.pwm2)
if(pwm2preratio~=nil)then
if((pwm2preratio<=1023)and(pwm2preratio>=0))then
pwm2rate=pwm2preratio
pwm.setduty(cfg.pwm2pin,pwm2rate)
end
end
end
if((t.pwm3~=nil)and(seq3=="-")and cfg.pwm3en=="en")then
tmr.stop(3)
pwm3preratio=tonumber(t.pwm3)
if(pwm3preratio~=nil)then
if((pwm3preratio<=1023)and(pwm3preratio>=0))then
pwm3rate=pwm3preratio
pwm.setduty(cfg.pwm3pin,pwm3rate)
end
end
end
end
else
print("wrong password")
end
e=e.."<body><form action=\"\" method=\"post\" ><font size=\""..cfg.textsize.."\" face=\"Verdana\">"
if(cfg.pwm1en=="en")then
e=e..cfg.pwm1..cfg.iscurrstr..pwm1rate.."<br> <input type=\"range\" name=\"pwm1\" value=\""..pwm1rate
e=e.."\"  min=\"0\" max=\"1023\" class=fw><br><select name=\"seq1\">"..seqOpt(seq1,seqfiles).."</select><br><br>"
end
if(cfg.pwm2en=="en")then
e=e..cfg.pwm2..cfg.iscurrstr..pwm2rate.."<br> <input type=\"range\" name=\"pwm2\" value=\""..pwm2rate
e=e.."\"  min=\"0\" max=\"1023\" class=fw><br><select name=\"seq2\">"..seqOpt(seq2,seqfiles).."</select><br><br>"
end
if(cfg.pwm3en=="en")then
e=e..cfg.pwm3..cfg.iscurrstr..pwm3rate.."<br> <input type=\"range\" name=\"pwm3\" value=\""..pwm3rate
e=e.."\"  min=\"0\" max=\"1023\" class=fw><br><select name=\"seq3\">"..seqOpt(seq3,seqfiles).."</select><br><br>"
end
if(cfg.pin1en=="en")then
e=e.."<input type=\"checkbox\" name=\"pin1\" value=\"1\"/> "..cfg.pin1n
end
if(cfg.pin2en=="en")then
e=e.."<br><br><input type=\"checkbox\" name=\"pin2\" value=\"1\"/> "..cfg.pin2n
end
e=e.."<br><br><input type=\"checkbox\" name=\"alloff\" value=\"1\"> "..cfg.alloffstr.."<br><br>"
if(cfg.pwd~=nil)then
e=e.."<br>"..cfg.pwdstr.." <input type=\"password\" name=\"pwd\"/><br><br>"
end
e=e.."<input type=\"submit\" value=\""..cfg.setvalstr.."\" size=\"7\"> </font></form><style scoped>.fw {width: 90%}</style></body></html>"
end
i:send(e)
i:close()
if(t.pwd==cfg.pwd)then
if(t.pin1~=nil and cfg.pin1en=="en")then
if(t.pin1=="1")then
gpio.write(cfg.pin1,gpio.HIGH)
gpio.write(cfg.pin1,gpio.LOW)
end
end
if(t.pin2~=nil and cfg.pin2en=="en")then
if(t.pin2=="1")then
gpio.write(cfg.pin2,gpio.HIGH)
gpio.write(cfg.pin2,gpio.LOW)
end
end
if(newseq1==1 and cfg.pwm1en=="en")then
tmr.stop(1)
nextSeqStep(seq1,cfg.pwm1pin,1,0)
newseq1=0
end
if(newseq2==1 and cfg.pwm2en=="en")then
tmr.stop(2)
nextSeqStep(seq2,cfg.pwm2pin,2,0)
newseq2=0
end
if(newseq3==1 and cfg.pwm3en=="en")then
tmr.stop(3)
nextSeqStep(seq3,cfg.pwm3pin,3,0)
newseq3=0
end
end
node.setcpufreq(node.CPU80MHZ)
collectgarbage()
end)
end)
