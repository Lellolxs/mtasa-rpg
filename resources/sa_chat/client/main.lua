Core = exports.sa_core;
Admin = exports.sa_admin;

loadstring(Core:require({ }))();

function clearLocalChat()
    for i = 1, getChatboxLayout()['chat_lines'] do 
        outputChatBox(" ");
    end 
end 
addCommandHandler('clearchat', clearLocalChat);
addCommandHandler('cc', clearLocalChat);

addCommandHandler('me', function(cmd, ...)
    triggerServerEvent('onPlayerEnterMe', resourceRoot, table.concat({ ... }, " "));
end);

addCommandHandler('do', function(cmd, ...)
    triggerServerEvent('onPlayerEnterDo', resourceRoot, table.concat({ ... }, " "));
end);

function sendOOCMessage(cmd, ...)
    triggerServerEvent('onPlayerOOCMessage', resourceRoot, table.concat({ ... }, " "));
end 
addCommandHandler('b', sendOOCMessage);
addCommandHandler('OOC', sendOOCMessage);
bindKey('b', 'down', 'chatbox', 'OOC');