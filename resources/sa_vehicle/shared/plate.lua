function generateLicensePlate(id)
    if (isElement(id)) then 
        id = getElementData(id, 'id');

        if (not id) then 
            return false;
        end 
    end

    local number_1 = id % 10;
	id = (id - number_1) / 10;

	local number_2 = id % 10;
	id = (id - number_2) / 10;

	local character_1 = id % 14;
	id = (id - character_1) / 14;

	local character_2 = id % 14;
	id = (id - character_2) / 14;
	
	local character_3 = id % 14;
	id = (id - character_3) / 14;

	return string.format("%c%c%c%c-%c%c",
		id + string.byte("A"),
		character_3 + string.byte("A"),
		character_2 + string.byte("A"),
		character_1 + string.byte("A"),

		number_2 + string.byte("0"),
		number_1 + string.byte("0")
	);
end 