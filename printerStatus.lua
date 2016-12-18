-- Retrive the status of the 3D Printer

requestRunning=false
function get3DprinterStatus()
srvrconn=net.createConnection(net.TCP, 0) 
    srvrconn:on("receive", function(srvrconn, pl) 
    --print(pl)
    found=string.match(pl, "completion\": %d+")
    if (found ~= nil) then
        percent=string.match(found, "%d+")
        print(percent .. "%")
        numLeds=percent*60/100
        ws2812.writergb(4, string.char(0,0,30):rep(numLeds) .. string.char(0,0,0):rep(60) )
    else
        print("No valid answer")
    end
    requestRunning=false
    end)
    srvrconn:connect(80, printer3D)
    srvrconn:send("GET /api/job?apikey=" .. apikey .. " HTTP/1.1\r\n".."Accept: */*\r\n\r\n")
    requestRunning=true
 end
print("Asking the printer") 
get3DprinterStatus()

tmr.alarm(1, 5000, 1, function() 
    if (not requestRunning) then
        get3DprinterStatus()
    end
end)