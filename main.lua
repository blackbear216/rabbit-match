love.graphics.setDefaultFilter("nearest")

local SCALE_FACTOR = 3
local TILE_SIZE = 16

local WIDTH = math.ceil(love.graphics.getWidth() / SCALE_FACTOR)
local HEIGHT = math.ceil(love.graphics.getHeight() / SCALE_FACTOR)

local frame_size = 16 * 8

local frame_x_pos = math.ceil((WIDTH - frame_size) / 2)
local frame_y_pos = math.ceil((HEIGHT - frame_size) / 2)

local highlight_pos = {}

local game_table = {
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,1,1,0,1,0,0,0},
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

local function highlight_cell(x, y)
    local x = x - frame_x_pos
    local y = y - frame_y_pos

    local i = math.ceil(y / TILE_SIZE)
    local j = math.ceil(x / TILE_SIZE)

    return {i, j}
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
            elseif game_table[i][j] == 1 then
                mode = "fill"
            end
            love.graphics.rectangle(mode, tile_x_pos, tile_y_pos, TILE_SIZE, TILE_SIZE)
            if i == highlight_pos[1] and j == highlight_pos[2] then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("fill", tile_x_pos, tile_y_pos, TILE_SIZE, TILE_SIZE)
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end