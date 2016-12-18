-- Initialization

print("Autostart in  1 Second")
tmr.alarm(6, 1000, 0, function() 
    if (file.open("main.lua")) then
        dofile("main.lua")
    else
        print("No main.lua file available -> no autostart")
    end
end)