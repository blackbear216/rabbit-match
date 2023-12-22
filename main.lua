local SCALE_FACTOR = 2
local TILE_SIZE = 16

local WIDTH = math.ceil(love.graphics.getWidth() / SCALE_FACTOR)
local HEIGHT = math.ceil(love.graphics.getHeight() / SCALE_FACTOR)

local frame_size = 16 * 8

local frame_x_pos = math.ceil((WIDTH - frame_size) / 2)
local frame_y_pos = math.ceil((HEIGHT - frame_size) / 2)

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

function love.load()

end

function love.update(dt)

end

function love.draw()
    love.graphics.scale(SCALE_FACTOR)
    love.graphics.rectangle("line", frame_x_pos, frame_y_pos, frame_size, frame_size)

    for i=1, #game_table do
        for j=1, #game_table[i] do
            local tile_x_pos = frame_x_pos + TILE_SIZE * (j - 1)
            local tile_y_pos = frame_y_pos + TILE_SIZE * (i - 1)
            love.graphics.rectangle("line", tile_x_pos, tile_y_pos, TILE_SIZE, TILE_SIZE)
        end
    end
end