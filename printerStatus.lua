-- Retrive the status of the 3D Printer

requestRunning=false
srvrconn=nil
function get3DprinterStatus()
    srvrconn=net.createConnection(net.TCP, 0)
    srvrconn:on("disconnection", function(con)
        print("Connection closed")
        requestRunning=false
    end)
    srvrconn:on("receive", function(con, pl) 
        --print(pl)
        local found=string.match(pl, "completion\": %d+")
        if (found ~= nil) then
            local percent=string.match(found, "%d+")
            print(percent .. "% " .. node.heap().. " bytes free")
            local numLeds=percent*60/100
            ws2812.writergb(4, string.char(0,0,30):rep(numLeds) .. string.char(0,0,0):rep(60) )
        else
            print("No valid answer")
        end
        pl=nil
        srvrconn:close()
        collectgarbage()
    end)
    srvrconn:connect(80, printer3D)
    srvrconn:send("GET /api/job?apikey=" .. apikey .. " HTTP/1.1\r\n".."Accept: */*\r\n\r\n")
    requestRunning=true
    print("Starting a request")
 end
print("Asking the printer") 
get3DprinterStatus()

tmr.alarm(1, 30000, 1, function() 
    if (not requestRunning) then
        get3DprinterStatus()
    end
end)