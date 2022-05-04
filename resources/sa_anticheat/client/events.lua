local Events = {};

addEvent('getRemoteEvents', true);
addEventHandler('getRemoteEvents', root, function(newEvents)
    -- Remove previous event handlers
    for resource, events in pairs(Events) do 
        
        for realEvent, eventKey in pairs(events) do 

        end 
    end
end);