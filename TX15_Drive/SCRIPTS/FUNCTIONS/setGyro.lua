local function my_init()
  -- Called once when the script is loaded
end

local function my_run()
  setIMU_X(0, 180)
  setIMU_Y(-1, 90)
end

local function my_background()
  -- Called periodically while the Special Function switch is off
end

return { run = my_run, background = my_background, init = my_init }