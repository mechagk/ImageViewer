
text = ""

greatest = {
    year = 0,
    month = 0,
    day = 0,
    hour = 0,
    minute = 0,
    second = 0,
    file = nil
}

changed = false

image = nil

imageSize = nil
windowSize = nil

imagePos = nil

mounted = false

timeElapsed = 0

function love.update(dt)
    timeElapsed = timeElapsed + dt

    if timeElapsed > 1 then
        reloadImage()
        timeElapsed = 0
    end
end

function getImagePos() 
    if windowSize and imageSize then
        scaleX = windowSize.x / imageSize.x
        scaleY = windowSize.y / imageSize.y
        scale = math.min(scaleX, scaleY) 

        imagePos = {
            x = (windowSize.x/2) - ((imageSize.x*scale)/2),
            y = (windowSize.y/2) - ((imageSize.y*scale)/2),
            scale = scale
        }
    end
end

function love.draw()
    if image and imagePos then
        love.graphics.draw(image, imagePos.x, imagePos.y, 0, imagePos.scale, imagePos.scale)
    end

    love.graphics.print(text, 20, 20)
end

function love.resize(w, h)
    setWindowSize(w, h)
end

function setWindowSize(w, h)
    windowSize = {
        x = w,
        y = h
    }

    getImagePos()
end

function love.keypressed(key, scancode, isrepeat) 
    if scancode == 'q' or scancode == 'escape' then
        love.window.setFullscreen(false, 'desktop')
        setWindowSize(love.graphics.getWidth(), love.graphics.getHeight())
    end

    if scancode == 'f' then
        love.window.setFullscreen(true, 'desktop')
        setWindowSize(love.graphics.getWidth(), love.graphics.getHeight())
    end

    if scancode == 'space' then
        reloadImage()
    end
end

function reloadImage()
    if not mounted then
        return
    end

    local files = love.filesystem.getDirectoryItems("base/")

    local images = {}
    local size = 0

    for _, file in ipairs(files) do
        local isImage = string.find(file, "png") ~= nil or 
                        string.find(file, "jpg") ~= nil or
                        string.find(file, "jpeg") ~= nil

        if isImage then
            local match = string.gmatch(file, "(%d+)-(%d+)-(%d+)_(%d+)-(%d+)-(%d+)")

            for year, month, day, hour, minute, second in match do
                year = tonumber(year)
                month = tonumber(month)
                day = tonumber(day)
                hour = tonumber(hour)
                minute = tonumber(minute)
                second = tonumber(second)

                if year > greatest.year or 
                    month > greatest.month or 
                    day > greatest.day or
                    hour > greatest.hour or
                    minute > greatest.minute or
                    second > greatest.second then
                        greatest.year = year
                        greatest.month = month
                        greatest.day = day
                        greatest.hour = hour
                        greatest.minute = minute
                        greatest.second = second
                        greatest.file = file

                        changed = true
                end
            end

            size = size + 1
            images[size] = file
        end
    end

    if changed then
        image = love.graphics.newImage("base/" .. greatest.file)
        imageSize = {
            x = image:getWidth(),
            y = image:getHeight()
        }
        getImagePos()
        changed = false
    end
end


function love.load()
    love.window.setMode(640, 480, {
        resizable=true,
        minwidth = 50,
        minheight = 50,
        highdpi = true
    })
    love.window.setFullscreen(true, "desktop")
    setWindowSize(love.graphics.getWidth(), love.graphics.getHeight())

    if love.filesystem.isFused() then
        local dir = love.filesystem.getSourceBaseDirectory()
        local success = love.filesystem.mount(dir, "base")
        mounted = true

        if success then 
            reloadImage()
        else
            text = "Failed to get directory"
        end
    else
        text = "Not fused :("
    end
end
