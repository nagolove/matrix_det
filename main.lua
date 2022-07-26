local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local coroutine = _tl_compat and _tl_compat.coroutine or coroutine; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local math = _tl_compat and _tl_compat.math or math; local pcall = _tl_compat and _tl_compat.pcall or pcall; local string = _tl_compat and _tl_compat.string or string; local table = _tl_compat and _tl_compat.table or table; local inspect = require("inspect")
local ceil = math.ceil
local getTime = love.timer.getTime
local resume = coroutine.resume
local gr = love.graphics
local font = gr.newFont("dejavusansmono.ttf", 70)

love.window.setMode(1920, 1080)
love.window.setTitle('транспонирование матрицы')

local Matrix = {}
local ColoredText = {}





local Cell = {}






local function matrix_draw(
   m,
   x, y,
   active)


   x = x or 0
   y = y or 0
   local x0, y0 = x, y
   local bracket_width = 7
   local bracket_height = #m * font:getHeight()
   local mat_width = 0.



   gr.setColor({ 1, 1, 1, 1 })
   gr.setLineWidth(3)

   gr.line(x0, y0, x0 + bracket_width, y0)

   gr.line(x0, y0 + bracket_height, x0 + bracket_width, y0 + bracket_height)

   gr.line(x0, y0, x0, y0 + bracket_height)
   gr.setLineWidth(1)

   local colored_text = {}
   local cells = {}

   local function draw_colored_text_line(X, Y)
      for k, v in ipairs(colored_text) do
         gr.setColor(v.color)
         gr.print(v.s, X, Y)
         print(v.s)
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




      for row, i in ipairs(j) do
         local color
         if active and active[2] == col and active[1] == row then
            color = { 0, 1, 0, 1 }
         else
            color = { 1, 1, 1, 1 }
         end
         table.insert(colored_text, {
            s = tostring(i),
            color = color,
         })
         if row ~= #j then
            line = line .. tostring(i) .. ","
            table.insert(colored_text, {
               s = ",",
               color = { 1, 0, 0, 1 },
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



   gr.setColor({ 1, 1, 1, 1 })
   gr.setLineWidth(3)

   gr.line(x0, y0, x0 - bracket_width, y0)

   gr.line(x0, y0 + bracket_height, x0 - bracket_width, y0 + bracket_height)

   gr.line(x0, y0, x0, y0 + bracket_height)
   gr.setLineWidth(1)

   return ceil(mat_width + 10), cells
end

local m1 = {
   { 0, 0, 0 },
   { 0, 1, 0 },
   { 1, 1, 1 },
}

local m2 = {
   { 0, 0, 0, 20 },
   { 0, 1, 0, 40 },
   { 1, 1, 1, -3.14 },
}

local m3 = {
   { 1, 2 },
}

local m4 = {
   { 1, 2 },
   { 3, 4 },
}

local m5 = {
   { 1, 2 },
   { 3, 4 },
   { 5, 6 },
}

local m5 = {
   { 1, 2, 0, -1, 0, -1, -2, -3, 4 },
   { 3, 4, 0, -1, 0, -1, -2, 0, 4 },
   { 5, 6, 0, -1, 0, -1, -2, 0, 4 },
   { 3, 4, 0, -1, 0, -1, -2, -3, 4 },
   { 3, 4, 0, -1, 0, -1, -2, -3, 4 },
   { 3, 4, 0, -1, 0, -1, -2, -3, 4 },
}

local function matrix_transpose_fast(m)
   local res = {}
   local columns = #m[1]
   local rows = #m

   for _ = 1, columns do
      table.insert(res, {})
      for j = 1, rows do
         res[#res][j] = 1 / 0
      end
   end

   for i = 1, #res do
      for j = 1, #res[1] do
         res[i][j] = m[j][i]
      end
   end

   return res
end

local function matrix_transpose(m)
   local res = {}
   local columns = #m[1]
   local rows = #m

   for _ = 1, columns do
      table.insert(res, {})
      for j = 1, rows do
         res[#res][j] = 1 / 0
      end
   end

   coroutine.yield(res)
   print('step')

   for i = 1, #res do
      for j = 1, #res[1] do
         res[i][j] = m[j][i]
         coroutine.yield(res, { i, j })
         print('innner step')
      end
   end

   return res
end

local matrix_transpose_coro = coroutine.create(matrix_transpose)
local last_time = getTime()
local wait_time = 0.
local wait_time_real = .5
local mat
local indices
local paused = false
local canvas = gr.newCanvas(1, 1)

local function calculate_pixel_width(
   m,
   x0,
   y0)

   gr.setCanvas(canvas)
   local res = matrix_draw(m, x0, y0)
   local transposed_m = matrix_transpose_fast(m)
   res = res + matrix_draw(transposed_m, res + x0, y0)
   gr.setCanvas()
   return res
end

local x0, y0 = 10, 10
local m = m5













love.draw = function()
   gr.setFont(font)
   local cells_trans

   local width, cells_orig = matrix_draw(m, x0, y0, indices)
   local x, y = x0, y0
   x = x + width

   local now = getTime()
   local can_resume
   local new_mat

   if paused then
      last_time = getTime()
   end

   if now - last_time > wait_time then
      last_time = now
      wait_time = wait_time_real
      can_resume, new_mat, indices = resume(matrix_transpose_coro, m)


      if can_resume then
         mat = new_mat
      end
   end

   if mat then
      local reverse_indices
      if indices then
         reverse_indices = { indices[2], indices[1] }
      end
      local text_width = 0.
      text_width, cells_trans = matrix_draw(mat, x, y, reverse_indices)
   end

   if indices and cells_trans and cells_orig then
      local ok, errmsg = pcall(function()
         local oldw = gr.getLineWidth()
         gr.setLineWidth(10)
         gr.setColor({ 0.6, 0.2, 0.9, 0.5 })




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

         if cells_orig[indices[2]] and
            cells_orig[indices[2]][indices[1]] and
            cells_orig[indices[2]][indices[1]].x and
            cells_orig[indices[2]][indices[1]].y and
            cells_trans[indices[2]] and
            cells_trans[indices[2]][indices[1]] and
            cells_trans[indices[2]][indices[1]].x and
            cells_trans[indices[2]][indices[1]].y then
            gr.line(
            cells_orig[indices[2]][indices[1]].x,
            cells_orig[indices[2]][indices[1]].y,
            cells_trans[indices[2]][indices[1]].x,
            cells_trans[indices[2]][indices[1]].y)

         end

         gr.setLineWidth(oldw)












      end)
      if not ok then
         error(errmsg)
      end
   end

   gr.setColor({ 0, 0.8, 0 })

end

love.update = function(_)
   if love.keyboard.isDown("escape") then
      love.event.quit();
   end
end

love.keypressed = function(_, key)
   if key == 'p' then
      paused = not paused
   end
end
