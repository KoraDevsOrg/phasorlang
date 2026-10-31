import "lib/color.ph"

// Global signals for wave parameters and time
signal current_time = 0.0
signal wave1_amplitude = 100.0
signal wave1_frequency = 0.02
signal wave1_phase = 0.0 // radians
signal wave2_amplitude = 80.0
signal wave2_frequency = 0.02
signal wave2_phase = 0.523599 // ~30 degrees in radians (PI/6)

// Complex number for impedance Z = R + jX
signal impedance_R = 50.0 // Resistance
signal impedance_X = 30.0 // Reactance (inductive)

// Phasor for voltage V = [Magnitude, Angle_Degrees, Z_Component]
signal voltage_mag = 120.0
signal voltage_angle_deg = 45.0 // Degrees

// Phasor for current I = [Magnitude, Angle_Degrees, Z_Component]
signal current_mag = 0.0 // Calculated
signal current_angle_deg = 0.0 // Calculated

// Placeholder for Z_mag and Z_angle_deg
signal Z_mag = 0.0
signal Z_angle_rad = 0.0
signal Z_angle_deg = 0.0

// Screen dimensions (from registers)
signal vw = 0.0
signal vh = 0.0
signal center_x = 0.0
signal center_y = 0.0

// Helper functions (could be in lib/math.ph)
deg_to_rad(degrees) = {
    degrees * (3.14159265 / 180.0)
}

rad_to_deg(radians) = {
    radians * (180.0 / 3.14159265)
}

// Function to get current time for visualization purposes (e.g. wrapping)
get_visual_time(total_width) = {
    // Wrap current_time to fit the visual range for plotting
    current_time_wrapped = mod(current_time * 100.0, total_width - 100.0)
    current_time_wrapped + 50.0 // Start from x=50
}

screen main {
    // Update time for animation
    dt = 0.00833 // Roughly 120 FPS frame time (1/120)
    current_time = current_time + dt

    // Get screen dimensions
    vw = R250
    vh = R251
    center_x = vw * 0.5
    center_y = vh * 0.5

    cls(0x0D1117) // Dark KoraDevs background

    // --- Wave Simulation ---
    // Calculate instantaneous values of two sine waves
    wave1_val_inst = wave1_amplitude * sin(wave1_frequency * current_time + wave1_phase)
    wave2_val_inst = wave2_amplitude * sin(wave2_frequency * current_time + wave2_phase)

    // Sum of waves
    sum_wave_val_inst = wave1_val_inst + wave2_val_inst

    // Draw coordinate axis for waves
    line(50.0, center_y, vw - 50.0, center_y, 0x30363D) // Horizontal axis for waves

    // Draw wave 1
    i = 0.0
    while (i < vw - 100.0) { // Iterate across horizontal range
        x_plot = 50.0 + i
        y_plot_prev = center_y + (wave1_amplitude * sin(wave1_frequency * (current_time + (i - 1.0)*0.1) + wave1_phase))
        y_plot_curr = center_y + (wave1_amplitude * sin(wave1_frequency * (current_time + i*0.1) + wave1_phase))
        line(x_plot - 1.0, y_plot_prev, x_plot, y_plot_curr, 0x58A6FF) // Blue wave
        i = i + 1.0
    }

    // Draw wave 2
    i = 0.0
    while (i < vw - 100.0) { // Iterate across horizontal range
        x_plot = 50.0 + i
        y_plot_prev = center_y + (wave2_amplitude * sin(wave2_frequency * (current_time + (i - 1.0)*0.1) + wave2_phase))
        y_plot_curr = center_y + (wave2_amplitude * sin(wave2_frequency * (current_time + i*0.1) + wave2_phase))
        line(x_plot - 1.0, y_plot_prev, x_plot, y_plot_curr, 0x3FB950) // Green wave
        i = i + 1.0
    }
    
    // Draw current instantaneous sum value on wave axis
    circle(get_visual_time(vw), center_y + sum_wave_val_inst, 5.0, 0xF85149) // Red indicator

    // Display instantaneous values
    text("Wave 1:", 10.0, 10.0, 11.0, 0x58A6FF)
    text(wave1_val_inst, 60.0, 10.0, 11.0, 0x58A6FF) // Display value
    text("Wave 2:", 10.0, 25.0, 11.0, 0x3FB950)
    text(wave2_val_inst, 60.0, 25.0, 11.0, 0x3FB950)
    text("Sum:", 10.0, 40.0, 11.0, 0xF85149)
    text(sum_wave_val_inst, 60.0, 40.0, 11.0, 0xF85149)


    // --- Complex Number and Phasor Operations ---

    // Calculate complex impedance magnitude and angle for current calculation
    Z_mag = sqrt(pow(impedance_R, 2.0) + pow(impedance_X, 2.0))
    // Assuming atan2(y,x) function is available in PhasorLang (common in math libraries)
    Z_angle_rad = atan2(impedance_X, impedance_R)
    Z_angle_deg = rad_to_deg(Z_angle_rad)

    // Calculate current phasor I = V / Z
    // Magnitude: I_mag = V_mag / Z_mag
    // Angle: I_angle = V_angle - Z_angle
    current_mag = voltage_mag / Z_mag
    current_angle_deg = voltage_angle_deg - Z_angle_deg

    // Convert phasors to Cartesian for drawing
    // Voltage:
    V_cart_x = voltage_mag * cos(deg_to_rad(voltage_angle_deg))
    V_cart_y = voltage_mag * sin(deg_to_rad(voltage_angle_deg)) // Y-axis in graphics is inverted, so use -V_cart_y for drawing

    // Current:
    I_cart_x = current_mag * cos(deg_to_rad(current_angle_deg))
    I_cart_y = current_mag * sin(deg_to_rad(current_angle_deg)) // Y-axis in graphics is inverted, so use -I_cart_y for drawing

    // Draw Phasor Diagram (bottom right)
    phasor_origin_x = vw - 150.0
    phasor_origin_y = vh - 150.0

    // Draw coordinate axes for phasor diagram
    line(phasor_origin_x - 100.0, phasor_origin_y, phasor_origin_x + 100.0, phasor_origin_y, 0x30363D) // Real axis
    line(phasor_origin_x, phasor_origin_y - 100.0, phasor_origin_x, phasor_origin_y + 100.0, 0x30363D) // Imaginary axis

    // Draw Voltage Phasor
    line(phasor_origin_x, phasor_origin_y, phasor_origin_x + V_cart_x, phasor_origin_y - V_cart_y, 0x00E5FF) // Cyan for Voltage
    circle(phasor_origin_x + V_cart_x, phasor_origin_y - V_cart_y, 4.0, 0x00E5FF) // End point

    // Draw Current Phasor
    line(phasor_origin_x, phasor_origin_y, phasor_origin_x + I_cart_x, phasor_origin_y - I_cart_y, 0xF2CC60) // Yellow for Current
    circle(phasor_origin_x + I_cart_x, phasor_origin_y - I_cart_y, 4.0, 0xF2CC60) // End point

    // Display Phasor values
    text("Voltage:", vw - 300.0, 10.0, 11.0, 0x00E5FF)
    text(voltage_mag, vw - 250.0, 10.0, 11.0, 0x00E5FF)
    text("V @", vw - 210.0, 10.0, 11.0, 0x00E5FF)
    text(voltage_angle_deg, vw - 180.0, 10.0, 11.0, 0x00E5FF)
    text("°", vw - 160.0, 10.0, 11.0, 0x00E5FF)

    text("Impedance:", vw - 300.0, 25.0, 11.0, 0xFFFFFF)
    text(Z_mag, vw - 230.0, 25.0, 11.0, 0xFFFFFF)
    text("Ω @", vw - 190.0, 25.0, 11.0, 0xFFFFFF)
    text(Z_angle_deg, vw - 160.0, 25.0, 11.0, 0xFFFFFF)
    text("°", vw - 140.0, 25.0, 11.0, 0xFFFFFF)

    text("Current:", vw - 300.0, 40.0, 11.0, 0xF2CC60)
    text(current_mag, vw - 250.0, 40.0, 11.0, 0xF2CC60)
    text("A @", vw - 210.0, 40.0, 11.0, 0xF2CC60)
    text(current_angle_deg, vw - 180.0, 40.0, 11.0, 0xF2CC60)
    text("°", vw - 160.0, 40.0, 11.0, 0xF2CC60)
}