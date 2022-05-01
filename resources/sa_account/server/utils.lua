local character_set = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$^&*_-+";
function genSalt(length)
    local str = "";

    for i = 1, length do 
        local indexOf = math.random(1, string.len(character_set));
        str = str .. string.sub(character_set, indexOf, indexOf);
    end 

    return str;
end 

function encryptPassword(password, salt)
    return hash(
        'sha256', 
        salt .. hash('sha256', password) .. salt
    );
end 