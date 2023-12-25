-- to do
-- make 3match checks and adjustments only happen when a new move is made,
--  not 30 frames a second

-- make it so the game knows whether there are any valid moves left on the board

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

local variety = 7

local game_table = {
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0}
}

local colours = {
    {0.5, 1, 0.5},
    {0.5, 0.5, 1},
    {1, 0.5, 0.5},
    {1, 1, 0.5},
    {1, 0.5, 1},
    {0.5, 1, 1},
    {0.8, 0.5, 0.2}
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

local function load_game_table(variety)
    for i=1, #game_table do
        for j=1, #game_table[i] do
            if game_table[i][j] == 0 then
                game_table[i][j] = math.random(variety)
            end
        end
    end
end

local function check_tile_3match(pos)
    --[[
        return key:
        0 - false
        1 - north
        2 - south
        3 - east
        4 - west
    ]]

    --north
    local north = {pos[1] - 1, pos[2]}
    if check_adjacent(north, pos) then 
        if game_table[pos[1]][pos[2]] == game_table[north[1]][north[2]] then
            local north_north = {north[1] - 1, north[2]}
            if check_adjacent(north_north, north) then
                if game_table[north[1]][north[2]] == game_table[north_north[1]][north_north[2]] then
                    return 1
                end
            end
        end
    end

    --south
    local south = {pos[1] + 1, pos[2]}
    if check_adjacent(south, pos) then
        if game_table[pos[1]][pos[2]] == game_table[south[1]][south[2]] then
            local south_south = {south[1] + 1, south[2]}
            if check_adjacent(south_south, south) then
                if game_table[south[1]][south[2]] == game_table[south_south[1]][south_south[2]] then
                    return 2
                end
            end
        end
    end

    --east
    local east = {pos[1], pos[2] + 1}
    if check_adjacent(east, pos) then
        if game_table[pos[1]][pos[2]] == game_table[east[1]][east[2]] then
            local east_east = {east[1], east[2] + 1}
            if check_adjacent(east_east, east) then
                if game_table[east[1]][east[2]] == game_table[east_east[1]][east_east[2]] then
                    return 3
                end
            end
        end  
    end
        
    --west
    local west = {pos[1], pos[2] - 1}
    if check_adjacent(west, pos) then
        if game_table[pos[1]][pos[2]] == game_table[west[1]][west[2]] then
            local west_west = {west[1], west[2] - 1}
            if check_adjacent(west_west, west) then
                if game_table[west[1]][west[2]] == game_table[west_west[1]][west_west[2]] then
                    return 4
                end
            end
        end
    end  

    return 0
end

local function delete_3match(pos, result)
    local empties = {}
    --north
    if result == 1 then
        for i=0, 2 do
            game_table[pos[1] - i][pos[2]] = 0
            empties[i+1] = {pos[1] - i, pos[2]}
        end
    end

    --south
    if result == 2 then
        for i=0, 2 do
            game_table[pos[1] + i][pos[2]] = 0
            empties[i+1] = {pos[1] + i, pos[2]}
        end
    end

    --east
    if result == 3 then
        for i=0, 2 do
            game_table[pos[1]][pos[2] + i] = 0
            empties[i+1] = {pos[1], pos[2] + i}
        end
    end

    --west
    if result == 4 then
        for i=0, 2 do
            game_table[pos[1]][pos[2] - i] = 0
            empties[i+1] = {pos[1], pos[2] - i}
        end
    end

    return empties
end

local function shift_game_table(empties)
    local new_empties = {}
    for i=1, #empties do
        --check tile above empty tile
        if is_inside_game_table_pos(empties[i][1] - 1, empties[i][2]) then
            local below_pos = {empties[i][1], empties[i][2]}
            local above_pos = {empties[i][1] - 1, empties[i][2]}
            local placeholder = game_table[below_pos[1]][below_pos[2]]
            game_table[below_pos[1]][below_pos[2]] = game_table[above_pos[1]][above_pos[2]]
            game_table[above_pos[1]][above_pos[2]] = placeholder

            new_empties[i] = {empties[i][1] - 1, empties[i][2]}
        else
            break
        end
    end
    
    return new_empties
end

local handle_3matches

local function handle_3match_tile(pos, result)
    local empties = delete_3match(pos, result)
    while true do
        local new_empties = shift_game_table(empties)
        -- have ^ func return not a bool but an updated list of empties
        -- then the below v loop can break if empties is empty (#empties == 0
        if #new_empties == 0 then
            break
        end
        for i=1, #new_empties do
            empties[i] = copy_pos(new_empties[i])
        end
    end
    load_game_table(variety)
    handle_3matches()
end

function handle_3matches()
    for i=1, #game_table do
        for j=1, #game_table[i] do
            local pos = {i, j}
            local result = check_tile_3match(pos)
            if result ~= 0 then
                handle_3match_tile(pos, result)
            end
        end
    end
end

local function leads_to_3match(highlight_pos, click_pos)
    local click_value = game_table[click_pos[1]][click_pos[2]]
    swap_tiles(highlight_pos, click_pos)
    local result = check_tile_3match(highlight_pos)
    swap_tiles(highlight_pos, click_pos)
    if result ~= 0 then
        return true
    else
        return false
    end
end

function love.load()
    math.randomseed(os.time())
    load_game_table(variety)
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
    handle_3matches()
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

            local red = colours[game_table[i][j]][1]
            local green = colours[game_table[i][j]][2]
            local blue = colours[game_table[i][j]][3]
            love.graphics.setColor(red, green, blue, 1)

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
    if button == 1 then
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
                    if leads_to_3match(highlight_pos, click_pos) then
                        swap_tiles(highlight_pos, click_pos)
                        click_pos = {}
                        click_flag = false
                    else
                        click_pos = copy_pos(highlight_pos)
                        click_flag = true  
                    end 
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

    if button == 2 then
        --handle_3matches()
    end
end