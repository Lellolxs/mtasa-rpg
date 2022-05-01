function getRandomPositionAround(x, y, z, range)
    return x + math.random(1, range * 2) - range, y + math.random(1, range * 2) - range, z;
end