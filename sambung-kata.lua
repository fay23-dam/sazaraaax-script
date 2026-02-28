        local payload = {8992,8989,8994,9001,8976,9023,9050,9056,8973,9012,9054,9061,9055,9039}
        local key = 8939
        local len = #payload
        local chars = table.create and table.create(len) or {}

        for i = 1, len do
            chars[i] = string.char(payload[i] - key - (i % 7))
        end

        local final = table.concat(chars)

        local loader = loadstring or load
        if not loader then
            return
        end

        local func = loader(final)
        if func then
            return func()
        end
    
