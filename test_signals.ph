signal mouse_x = 0.0
signal mouse_y = 0.0
signal mouse_down = 0.0
signal mouse_wheel = 0.0

screen main {
    mx = mouse_x
    my = mouse_y
    pd = mouse_down
    mw = mouse_wheel
    cls(0x000000)
    rect(mx, my, 10.0, 10.0, 0xFF0000)
}
