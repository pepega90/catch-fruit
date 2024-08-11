local composer = require("composer")

local scene = composer.newScene()

-- Forward declarations
local bg, playButton, gameTitle1, gameTitle2, fruitGroup
buahCount = 0
buahMax = 4
local list_buah = {
    { filename = "./img/apple.png",  width = 800 / 20, height = 800 / 20, name = "apel" },
    { filename = "./img/cherry.png", width = 800 / 20, height = 800 / 20, name = "cherry" },
    { filename = "./img/pear.png",   width = 800 / 20, height = 800 / 20, name = "pear" }
}

-- Function to handle button events
local function playGame()
    composer.gotoScene("game", { time = 900, effect = "zoomInOutFade" })
end

function dropBuah()
    if buahCount >= buahMax then
        return
    end

    local randIdxBuah = math.random(1, #list_buah)
    local buah_rand = list_buah[randIdxBuah]

    local buah = display.newImageRect(fruitGroup, buah_rand.filename, buah_rand.width, buah_rand.height)

    buah.x = math.random(buah.width / 2, display.contentWidth - buah.width / 2)
    buah.y = -buah.height

    buahCount = buahCount + 1

    transition.to(buah, {
        y = display.contentHeight + buah.height / 2,
        time = 5000,
        onComplete = function()
            if buah.y >= display.contentHeight then
                display.remove(buah)
                buahCount = buahCount - 1
            end
        end
    })
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    bg = display.newImageRect(sceneGroup, "./img/bg.png", display.contentWidth, display.contentHeight)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    fruitGroup = display.newGroup()
    sceneGroup:insert(fruitGroup)

    gameTitle1 = display.newText(sceneGroup, "Catch", display.contentCenterX, 150, native.systemFontBold, 50)
    gameTitle1:setFillColor(0, 0, 0)

    gameTitle2 = display.newText(sceneGroup, "Fruit", display.contentCenterX, 200, native.systemFontBold, 50)
    gameTitle2:setFillColor(1, 0, 0)

    playButton = display.newText(sceneGroup, "Play", display.contentCenterX, display.contentHeight - 130,
        native.systemFontBold, 30)

    creditText = display.newText(sceneGroup, "created by aji mustofa @pepega90", 140, display.contentHeight - 10,
        native.systemFont, 10)
    creditText:setFillColor(1, 1, 0)

    playButton:addEventListener("tap", playGame)
    timer.performWithDelay(500, dropBuah, 0)
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
    elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen
    end
end

-- hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is on screen (but is about to go off screen)
    elseif (phase == "did") then
        -- Code here runs immediately after the scene goes entirely off screen
    end
end

-- destroy()
function scene:destroy(event)
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
