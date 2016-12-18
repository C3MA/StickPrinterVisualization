-- Main.lua file: all code
print("Booting printer visualization v0.23")

wifi.setmode(wifi.STATION)
dofile("wlancfg.lua")

function startTelnetServer(dummy)
    s=net.createServer(net.TCP, 180)
    s:listen(2323,function(c)
    global_c=c
    function s_output(str)
      if(global_c~=nil)
         then global_c:send(str)
      end
    end
    node.output(s_output, 0)
    c:on("receive",function(c,l)
      node.input(l)
    end) 
    c:on("disconnection",function(c)
      node.output(nil)
      global_c=nil
    end)
    print("Welcome to the 3D visualization.")
    end)
    print("WiFi up and running")
end

counter=0
tmr.alarm(0, 500, 1, function() 
   if wifi.sta.getip()=="0.0.0.0" or wifi.sta.getip() == nil then
      print("Connect AP, Waiting...") 
      if counter == 0 then
        ws2812.writergb(4, string.char(0, 60, 0):rep(60))
        counter=1
      else
          ws2812.writergb(4, string.char(0, 0, 0):rep(60))
          counter=0
      end
    
   else
      tmr.stop(0)
      print("Connected")
      print( wifi.sta.getip() )
      -- Display IP on the stick (red = hundreds, green = tenth, blue = ones)
      ws2812.writergb(4, string.char(0, 0, 0):rep(60))
      ip=wifi.sta.getip()
      for k in string.gmatch(ip, "(%d+)") do
      lastIP=k
      end
      hundred=math.floor(lastIP / 100)
      lastIP=lastIP-hundred*100
      tenth=math.floor(lastIP / 10)
      lastIP=lastIP-tenth*10
      ones=lastIP
      -- Set some orange points, soo the IP address is not coded in the foot, afterwards the IP is displayed
      ws2812.writergb(4, string.char(128, 82, 0):rep(10) .. string.char(30, 0, 0):rep(hundred) .. string.char(0,30,0):rep(tenth) .. string.char(0,0,30):rep(ones) )
      
      startTelnetServer()
      if (file.open("printerStatus.lua")) then
        dofile("printerStatus.lua")
      end
   end
end)