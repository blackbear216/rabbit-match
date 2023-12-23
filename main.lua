love.graphics.setDefaultFilter("nearest")

local SCALE_FACTOR = 3
local TILE_SIZE = 16

local WIDTH = math.ceil(love.graphics.getWidth() / SCALE_FACTOR)
local HEIGHT = math.ceil(love.graphics.getHeight() / SCALE_FACTOR)

local frame_size = 16 * 8

local frame_x_pos = math.ceil((WIDTH - frame_size) / 2)
local frame_y_pos = math.ceil((HEIGHT - frame_size) / 2)

local highlight_pos = {}
local click_pos = {}
local click_flag = false

local game_table = {
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,1,1,2,1,2,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0}
}

local function is_inside_game_table(x, y)
    return x > frame_x_pos
    and x < frame_x_pos + frame_size
    and y > frame_y_pos
    and y < frame_y_pos + frame_size
end

local function is_inside_game_table_pos(x, y)
    if x == nil then return false end
    if y == nil then return false end
    return x > 0
    and x < 9
    and y > 0
    and y < 9
end

local function highlight_cell(x, y)
    local x = x - frame_x_pos
    local y = y - frame_y_pos

    local i = math.ceil(y / TILE_SIZE)
    local j = math.ceil(x / TILE_SIZE)

    return {i, j}
end

local function check_adjacent(highlight_pos, click_pos)
    if not is_inside_game_table_pos(highlight_pos[1], highlight_pos[2]) then
        return false
    elseif not is_inside_game_table_pos(click_pos[1], click_pos[2]) then
        return false
    end

    --north
    local north = {click_pos[1] - 1, click_pos[2]}
    if north[1] > 0 then
        if north[1] == highlight_pos[1] and north[2] == highlight_pos[2] then
            return true
        end
    end
    
    --south
    local south = {click_pos[1] + 1, click_pos[2]}
    if south[1] < 9 then
        if south[1] == highlight_pos[1] and south[2] == highlight_pos[2] then
            return true
        end
    end
    
    --east
    local east = {click_pos[1], click_pos[2] + 1}
    if east[2] < 9 then
        if east[1] == highlight_pos[1] and east[2] == highlight_pos[2] then
            return true
        end
    end

    --west
    local west = {click_pos[1], click_pos[2] - 1}
    if west[2] > 0 then
        if west[1] == highlight_pos[1] and west[2] == highlight_pos[2] then
            return true
        end
    end
    
    return false
end

local function swap_tiles(highlight_pos, click_pos)
    local hi, hj = highlight_pos[1], highlight_pos[2]
    local ci, cj = click_pos[1], click_pos[2]
    local placeholder = game_table[hi][hj]
    game_table[hi][hj] = game_table[ci][cj]
    game_table[ci][cj] = placeholder
end

local function copy_pos(pos)
    local new_pos = {}
    for i=1, #pos do
        new_pos[i] = pos[i]
    end

    return new_pos
end

local function is_same_pos(pos1, pos2)
    return pos1[1] == pos2[1] and pos1[2] == pos2[2]
end

function love.load()

end

function love.update(dt)
    local x, y = love.mouse.getPosition()

    x = math.ceil(x / SCALE_FACTOR)
    y = math.ceil(y / SCALE_FACTOR)
    if is_inside_game_table(x, y) then
        highlight_pos = highlight_cell(x, y)
    else
        highlight_pos = {}
    end
end

function love.draw()
    love.graphics.scale(SCALE_FACTOR)
    love.graphics.rectangle("line", frame_x_pos, frame_y_pos, frame_size, frame_size)

    for i=1, #game_table do
        for j=1, #game_table[i] do
            local tile_x_pos = frame_x_pos + TILE_SIZE * (j - 1)
            local tile_y_pos = frame_y_pos + TILE_SIZE * (i - 1)

            local mode
            if game_table[i][j] == 0 then
                mode = "line"
            else
                mode = "fill"
            end

            if game_table[i][j] == 1 then
                love.graphics.setColor(0.5, 1, 0.5, 1)
            elseif game_table[i][j] == 2 then
                love.graphics.setColor(0.5, 0.5, 1, 1)
            end
            love.graphics.rectangle(mode, tile_x_pos, tile_y_pos, TILE_SIZE, TILE_SIZE)

            if i == highlight_pos[1] and j == highlight_pos[2] then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("fill", tile_x_pos, tile_y_pos, TILE_SIZE, TILE_SIZE)
            end
            love.graphics.setColor(1, 1, 1, 1)

            if i == click_pos[1] and j == click_pos[2] then
                love.graphics.setColor(1, 0, 0, 0.5)
                love.graphics.rectangle("fill", tile_x_pos, tile_y_pos, TILE_SIZE, TILE_SIZE)
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function love.mousepressed(x, y, button)
    if click_flag then
        if not is_inside_game_table_pos(highlight_pos[1], highlight_pos[2]) then
            click_pos = {}
            click_flag = false
        elseif is_same_pos(highlight_pos, click_pos) then
            click_pos = {}
            click_flag = false
        else
            local adjacent = check_adjacent(highlight_pos, click_pos)
            if adjacent then
                swap_tiles(highlight_pos, click_pos)
                click_pos = {}
                click_flag = false
            else
                click_pos = copy_pos(highlight_pos)
                click_flag = true
            end
        end
    else
        click_pos = copy_pos(highlight_pos)
        click_flag = true
    end
end