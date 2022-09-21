-- vim: set colorcolumn=85
-- vim: fdm=marker

--local inspect = require "inspect"
local ceil = math.ceil
local getTime = love.timer.getTime
local resume = coroutine.resume
local gr = love.graphics
local font = gr.newFont("dejavusansmono.ttf", 70)

love.window.setMode(1920, 1080)
love.window.setTitle('транспонирование матрицы')

-- Матрица из строк
local type Matrix = {{number}}

local record ColoredText 
    s: string
    color: {number}
end

-- Ячейка представления на экране
local record Cell
    x: number
    y: number
end

-- active[1], active[2] - индексы для подсветки элемента
-- Возвращает ширину матрицы в пикселях
local function matrix_draw(
    m: Matrix, 
    x: number, y: number, 
    active: {number}
): integer, {{Cell}}

    x = x or 0
    y = y or 0
    local x0, y0 = x, y
    local bracket_width = 7
    local bracket_height = #m * font:getHeight()
    local mat_width = 0.

    -- left

    gr.setColor{1, 1, 1, 1}
    gr.setLineWidth(3)
    -- hor
    gr.line(x0, y0, x0 + bracket_width, y0)
    -- hor
    gr.line(x0, y0 + bracket_height, x0 + bracket_width, y0 + bracket_height)
    -- ver
    gr.line(x0, y0, x0, y0 + bracket_height)
    gr.setLineWidth(1)

    local colored_text: {ColoredText} = {}
    local cells:{{Cell}} = {}

    local function draw_colored_text_line(X: number, Y: number): number
        for k, v in ipairs(colored_text) do
            gr.setColor(v.color)
            gr.print(v.s, X, Y)
            if v.s ~= "," then
                local row = cells[#cells]
                row[#row + 1] = {
                    x = X + font:getWidth(v.s) / 2.0, 
                    y = Y + font:getHeight() / 2.,
                }
            end
            X = X + font:getWidth(v.s)
        end
    end

    for col, j in ipairs(m) do
        local line = ""
        colored_text = {}

        table.insert(cells, {});
        --for row, i in ipairs(j) do
            --cells[col][row] = {}
        --end

        for row, i in ipairs(j) do
            local color: {number}
                if active and active[2] == col and active[1] == row then
                    color = {0, 1, 0, 1} 
                else
                    color = {1, 1, 1, 1} 
                end
            table.insert(colored_text, {
                s = tostring(i),
                color = color,
            })
            if row ~= #j then
                line = line .. tostring(i) .. ","
                table.insert(colored_text, {
                    s = ",",
                    color = {1, 0, 0, 1},
                })
            else
                line = line .. tostring(i)
            end
        end
        if #line > mat_width then
            mat_width = #line
        end
        draw_colored_text_line(x, y)
        y = y + font:getHeight()
    end

    mat_width = font:getWidth(string.rep("a", mat_width))
    x0 = x0 + mat_width

    --right

    gr.setColor{1, 1, 1, 1}
    gr.setLineWidth(3)
    -- hor
    gr.line(x0, y0, x0 - bracket_width, y0)
    -- hor
    gr.line(x0, y0 + bracket_height, x0 - bracket_width, y0 + bracket_height)
    -- ver
    gr.line(x0, y0, x0, y0 + bracket_height)
    gr.setLineWidth(1)

    return ceil(mat_width + 10), cells
end

local m1: Matrix = {
    {0, 0, 0},
    {0, 1, 0},
    {1, 1, 1},
}

local m2: Matrix = {
    {0, 0, 0, 20},
    {0, 1, 0, 40},
    {1, 1, 1, -3.14},
}

local m3: Matrix = {
    {1, 2}
}

local m4: Matrix = {
    {1, 2},
    {3, 4}
}

local m5: Matrix = {
    {1, 2},
    {3, 4},
    {5, 6},
}

local m6: Matrix = {
    {1, 2, 0, -1, 0, -1, -2, -3, 4},
    {3, 4, 0, -1, 0, -1, -2, 0, 4},
    {5, 6, 0, -10, 0, -1, -2, 0, 4},
    {3, 40, 0, -1, 0, -1, -200, -3, 4},
    {3, 4, 0, -1, 0, -1, -2, -3, 4},
    {3, 4, 0, -1, 0, -10, -2, -3, 4},
}

local function matrix_transpose_fast(m: Matrix): Matrix
    local res: {{number}} = {}
    local columns = #m[1]
    local rows = #m

    for _ = 1, columns do
        table.insert(res, {})
        for j = 1, rows do
            res[#res][j] = 1/0
        end
    end

    for i = 1, #res do
        for j = 1, #res[1] do
            res[i][j] = m[j][i]
        end
    end

    return res
end

local function matrix_det2(m: Matrix): number
    return m[1][1] * m[2][2] - m[1][2] * m[2][1]
end

local function matrix_det3(m: Matrix): number

end

local function matrix_det_common(m: Matrix): number

end

local function matrix_check_size(m: Matrix): integer
    local msize, msize_prev: integer, integer = 0, 0
    for _, v1 in ipairs(m) do
        msize_prev = msize
        msize = #v1
        assert(msize ~= msize_prev)
        for _, v2 in ipairs(v1) do
            assert(type(v2) == "number")
        end
    end
    return msize
end

local function matrix_det(m: Matrix): number
    local size = matrix_check_size(m)
    if size == 2 then
        return matrix_det2(m)
    elseif size == 3 then
        return matrix_det3(m)
    else
        return matrix_det_common(m)
    end
end

local function mat_print(m: Matrix)
    for _, v1 in ipairs(m) do
        local s = ""
        for _, v2 in ipairs(v1) do
            s = s .. tonumber(v2) .. ","
        end
        print(s)
    end
end

local function test_det(m: Matrix, det_should_be: number)
    mat_print(m)
    assert(matrix_det(m) == det_should_be)
end

-- {{{ Tests

test_det(
    { {9, 5}, { -9, 7}},
    108
)

test_det(
    {{9, 15}, { -9, 7}},
    198
)

test_det(
    { {9, 3, 5}, {-6, -9, 7}, {-1, -8, 1} },
    615
)

test_det(
    {{9, 0, 5}, {-6, -9, 7}, {1, -8, 0}},
    789
)

test_det(
   {{-900, 0, 5}, {-6, -9, -7}, {1, -8, 100}},
   860685
)

test_det(
    {{0, 1, 2}, {0, 2,4}, {0, 2,4}},
    0
)

test_det(
    {{100, 11, -2}, {10, 200,-4}, {10, -30,4}},
    71720
)

test_det(
    {{5, 0,1,0}, { 5, 1,0,0}, {1,2,3,4}, {5,6,7,8}},
    -48
)

test_det(
    {{5, 0,1,0}, { 5, 10,0,0}, {1,20,3,4}, {15,6,7,8} },
    1000
)

test_det(
    {{5, 0,1,0}, { 5, 10,0,0}, {1,20,3,4}, {15,6,7,8} },
    1000
)

test_det(
    {{105, 0,1,0}, {5, 0.10,0,0}, {1,20,3,4}, {15,6,7,8} },
    643.2
)

print("6*6 matrix det =",
    matrix_det(
    {
        {5, 0,1,0,10.1},
        {5, 0.10,0,8.2,0},
        {-0.2,1,2,3,4},
        {15,6,7,8,0},
        {2, 10, 1, 3, 0, 1} 
    })
)

-- }}}

os.exit()

local function matrix_transpose(m: Matrix): Matrix
    local res: {{number}} = {}
    local columns = #m[1]
    local rows = #m

    for _ = 1, columns do
        table.insert(res, {})
        for j = 1, rows do
            --res[#res][j] = 1/0
            res[#res][j] = "_" as number
        end
    end

    coroutine.yield(res)
    print('step')

    for i = 1, #res do
        for j = 1, #res[1] do
            res[i][j] = m[j][i]
            coroutine.yield(res, {i, j})
            print('innner step')
        end
    end

    return res
end

local matrix_transpose_coro = coroutine.create(matrix_transpose)
local last_time: number = getTime()
local wait_time = 0.
local wait_time_real = .5
local mat: Matrix
local indices: {integer}
local paused = false
local canvas = gr.newCanvas(1, 1)
local arrow_start_time: number

local function calculate_pixel_width(
    m: Matrix, 
    x0: integer, 
    y0: integer
): number
    gr.setCanvas(canvas)
    local res = matrix_draw(m, x0, y0)
    local transposed_m = matrix_transpose_fast(m)
    res = res + matrix_draw(transposed_m, res + x0, y0)
    gr.setCanvas()
    return res
end

local x0, y0 = 10, 10
local m: Matrix = m6

--[[
local calculated_width: number
local font_size = 10
repeat
    calculated_width = calculate_pixel_width(m, x0, y0)
    font_size = font_size + 10
    font = gr.newFont("dejavusansmono.ttf", font_size)
    print('calculated_width', calculated_width)
    print('font_size', font_size)
until (calculated_width + 400 >= gr.getWidth())
--]]

local function from_polar(angle: number, radius: number): number, number
    radius = radius or 1
    return math.cos(angle) * radius, math.sin(angle) * radius
end

local function draw_arrow()
    local from_x, from_y, to_x, to_y = coroutine.yield() as 
        (number, number, number, number)
    print(from_x, from_y, to_x, to_y)

    local dirx, diry = to_x - from_x, to_y - from_y
    local len = math.sqrt(dirx * dirx + diry * diry)
    local w = math.atan2(dirx, diry)
    print('dirx, diry', dirx, diry)
    print("w, len", w, len)
    local rad = 10.

    while true do
        from_x, from_y, to_x, to_y = coroutine.yield() as 
            (number, number, number, number)
        gr.line(from_x, from_y, to_x, to_y)

        local x, y = from_polar(w, rad)
        x, y = x + from_x, y + from_y
        gr.setColor{1, 1, 1, 1}
        gr.circle("fill", x, y, 10)
        rad = rad + 0.5
    end
end

local draw_arrow_coro = coroutine.create(draw_arrow)

love.draw = function()
    gr.setFont(font)
    local cells_trans: {{Cell}}

    local width, cells_orig = matrix_draw(m, x0, y0, indices)
    local x, y = x0, y0
    x = x + width

    local now = getTime()
    local can_resume: boolean
    local new_mat: Matrix

    if paused then
        last_time = getTime()
    end

    if now - last_time > wait_time then
        last_time = now
        wait_time = wait_time_real
        can_resume, new_mat, indices = resume(matrix_transpose_coro, m) 
            as (boolean, Matrix, {integer})
        arrow_start_time = getTime()
        if can_resume then
            mat = new_mat
        end
    end

    if mat then
        local reverse_indices: {number}
        if indices then
            reverse_indices = {indices[2], indices[1]}
        end
        local text_width = 0.
        text_width, cells_trans = matrix_draw(mat, x, y, reverse_indices)
    end

    if indices and cells_trans and cells_orig then
        local ok, errmsg = pcall(function()
            local oldw = gr.getLineWidth()
            gr.setLineWidth(10)
            gr.setColor{0.6, 0.2, 0.9, 0.5}

            --[[
            for k, v in ipairs(cells_orig) do
                for k1, v1 in ipairs(v) do
                    if v1.x and v1.y then
                        gr.circle("fill", v1.x, v1.y, 15)
                    end
                end
            end
            for k, v in ipairs(cells_trans) do
                for k1, v1 in ipairs(v) do
                    if v1.x and v1.y then
                        gr.circle("fill", v1.x, v1.y, 15)
                    end
                end
            end
            --]]

            if  cells_orig[indices[2]] and 
                cells_orig[indices[2]][indices[1]] and
                cells_orig[indices[2]][indices[1]].x and
                cells_orig[indices[2]][indices[1]].y and
                cells_trans[indices[1]] and 
                cells_trans[indices[1]][indices[2]] and
                cells_trans[indices[1]][indices[2]].x and
                cells_trans[indices[1]][indices[2]].y then

                    --gr.line(
                        --cells_orig[indices[2]][indices[1]].x,
                        --cells_orig[indices[2]][indices[1]].y,
                        --cells_trans[indices[1]][indices[2]].x,
                        --cells_trans[indices[1]][indices[2]].y
                    --)

                    resume(draw_arrow_coro, 
                        cells_orig[indices[2]][indices[1]].x,
                        cells_orig[indices[2]][indices[1]].y,
                        cells_trans[indices[1]][indices[2]].x,
                        cells_trans[indices[1]][indices[2]].y
                    )
            end

            gr.setLineWidth(oldw)

            --print(
                --"cells_orig x, y", 
                --cells_orig[indices[1]][indices[2]].x,
                --cells_orig[indices[1]][indices[2]].y
            --)
            --print(
                --"cells_trans x, y",
                --cells_trans[indices[1]][indices[2]].x,
                --cells_trans[indices[1]][indices[2]].y
            --)

        end) as (boolean, string)
        if not ok then
            error(errmsg)
        end
    end

    gr.setColor{0, 0.8, 0}
    --gr.line(x0, y0, x0 + calculated_width, y0)
end

love.update = function(_: number)
    if love.keyboard.isDown("escape") then
        love.event.quit();
    end
end

love.keypressed = function(_: string, key: string)
    if key == 'p' then
        paused = not paused
    end
end
