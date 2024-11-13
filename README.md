that is Out Law Inspired Hud work on qb 


![image](https://github.com/user-attachments/assets/8727cc4d-e364-403f-a3d3-af169d7fff05)


to import this scrit  

firstly put in [qb] folder  

secondly open qb-smallresources / fxmanifest . lua and put this code  

exports {  
    'HasHarness',  
    'HasSeatbelt'  
}  

go qb-smallresources / client / seatbelt and search for this code  

function SeatBeltLoop()  
    CreateThread(function()  
        while true do  
            sleep = 0   
            if seatbeltOn or harnessOn then  
                DisableControlAction(0, 75, true)  
                DisableControlAction(27, 75, true)   
            end  
            if not IsPedInAnyVehicle(PlayerPedId(), false) then  
                seatbeltOn = false  
                harnessOn = false  
                TriggerEvent("seatbelt:client:ToggleSeatbelt")  
                break  
            end  
            if not seatbeltOn and not harnessOn then break end  
            Wait(sleep)  
        end  
    end)  
end  

then go down two lines and put this code 

function HasSeatbelt()  
    return seatbeltOn  
end  
