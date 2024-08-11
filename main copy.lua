-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- TODO: show score in the middle

-- Your code here
physics = require("physics")
physics.start()
physics.setGravity(0, 0)

-- load background
bg = display.newImageRect("./img/bg.png", display.contentWidth, display.contentHeight)
bg.x = display.contentCenterX
bg.y = display.contentCenterY

-- load player kotak
kotak = display.newImageRect("./img/kotak.png", 531 / 7, 278 / 7)
kotak.x = display.contentCenterX
kotak.y = display.contentHeight - 80
physics.addBody(kotak, { radius = 30, isSensor = true })
kotak.id = "kotak"

-- load image buah
local list_buah = {
    { filename = "./img/apple.png",  width = 800 / 20, height = 800 / 20, name = "apel" },
    { filename = "./img/bom.png",    width = 222 / 7,  height = 372 / 7,  name = "bom" },
    { filename = "./img/cherry.png", width = 800 / 20, height = 800 / 20, name = "cherry" },
    { filename = "./img/pear.png",   width = 800 / 20, height = 800 / 20, name = "pear" }
}

-- game variable
buahTable = {}
buahCount = 0
buahMax = 3
score = 0
scoreText = display.newText("Score: " .. score, 100, 50, native.systemFont, 20)
scoreText:setFillColor(0, 0, 0)

local function endGame()
    -- Display Game Over screen
    local gameOverText = display.newText("Game Over", display.contentCenterX, display.contentCenterY, native.systemFont,
        40)
    gameOverText:setFillColor(1, 0, 0)

    local restartText = display.newText("Tap to Restart", display.contentCenterX, display.contentCenterY + 50,
        native.systemFont, 20)
    restartText:setFillColor(1, 1, 1)

    local function restartGame()
        -- Remove Game Over screen
        display.remove(gameOverText)
        display.remove(restartText)

        -- Reset game variables
        score = 0
        scoreText.text = "Score: " .. score
        buahCount = 0

        -- Remove all buah objects
        for i = #buahTable, 1, -1 do
            local buah = buahTable[i]
            display.remove(buah)
            table.remove(buahTable, i)
        end

        -- Restart game loop
        timer.performWithDelay(1000, dropBuah, 0)

        -- Remove tap listener
        bg:removeEventListener("tap", restartGame)
    end

    -- Add tap listener to restart game
    bg:addEventListener("tap", restartGame)

    -- Stop game loop
    timer.cancelAll()
end

function dropBuah()
    if buahCount >= buahMax then
        return
    end

    local randIdxBuah = math.random(1, #list_buah)
    local buah_rand = list_buah[randIdxBuah]

    local buah = display.newImageRect(buah_rand.filename, buah_rand.width, buah_rand.height)
    table.insert(buahTable, buah)
    physics.addBody(buah, { radius = 5, isSensor = true })
    buah.id = buah_rand.name

    buah.x = math.random(buah.width / 2, display.contentWidth - buah.width / 2)
    buah.y = -buah.height

    buahCount = buahCount + 1

    transition.to(buah, {
        y = display.contentHeight + buah.height / 2,
        time = 5000,
        onComplete = function()
            if buah.y >= display.contentHeight then
                display.remove(buah)
                for i = #buahTable, 1, -1 do
                    if buahTable[i] == buah then
                        table.remove(buahTable, i)
                        break
                    end
                end
                buahCount = buahCount - 1
            end
        end
    })

    kotak:toFront()
end

timer.performWithDelay(1000, dropBuah, 0)

-- function untuk drag kotak dengan touch
function dragKotak(event)
    local kotak = event.target
    local phase = event.phase

    if phase == "began" then
        display.currentStage:setFocus(kotak)
        kotak.touchOffsetX = event.x - kotak.x
    elseif phase == "moved" then
        local newX = event.x - kotak.touchOffsetX
        if newX < kotak.width then
            newX = kotak.width
        elseif newX > display.contentWidth - kotak.width then
            newX = display.contentWidth - kotak.width
        end
        kotak.x = newX
    elseif phase == "ended" or phase == "cancelled" then
        display.currentStage:setFocus(nil)
    end

    return true
end

kotak:addEventListener("touch", dragKotak)

function onCollision(event)
    local phase = event.phase

    if phase == "began" then
        local obj1 = event.object1
        local obj2 = event.object2

        local buahList = { "apel", "cherry", "pear" }

        if (obj1.id == "kotak" and obj2.id == "bom") or (obj1.id == "bom" and obj2.id == "kotak") then
            endGame()
        elseif (obj1.id == "kotak" and isInList(obj2.id, buahList)) then
            transition.cancel(obj2)
            transition.to(obj2, {
                time = 500,
                delay = 50,
                alpha = 0,
                onComplete = function()
                    display.remove(obj2)
                    obj2 = nil
                    buahCount = buahCount - 1
                end
            })

            for i = #buahTable, 1, -1 do
                if buahTable[i] == obj1 or buahTable[i] == obj2 then
                    table.remove(buahTable, i)
                    break
                end
            end

            score = score + 10
            scoreText.text = "Score: " .. score
        elseif (isInList(obj1.id, buahList) and obj2.id == "kotak") then
            transition.cancel(obj1)
            transition.to(obj1, {
                time = 500,
                delay = 50,
                alpha = 0,
                onComplete = function()
                    display.remove(obj1)
                    obj1 = nil
                    buahCount = buahCount - 1
                end
            })

            for i = #buahTable, 1, -1 do
                if buahTable[i] == obj1 or buahTable[i] == obj2 then
                    table.remove(buahTable, i)
                    break
                end
            end

            score = score + 10
            scoreText.text = "Score: " .. score
        end
    end
end

Runtime:addEventListener("collision", onCollision)

function isInList(value, list)
    for _, v in ipairs(list) do
        if v == value then
            return true
        end
    end
    return false
end
