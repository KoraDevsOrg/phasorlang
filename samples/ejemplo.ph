// samples/ejemplo.ph
import "lib/ui_components.ph"
import "lib/ui_scrollbar.ph"

signal anim_x = 50.0

screen main {
    cls(0x0D1117) // Dark background
    
    // Animate a circle based on R0 (PVM register simulated by runtime)
    current_x = R0 // Simulated animation register from runtime JS
    circle(current_x, 150.0, 20.0, 0xF85149) // Red circle

    // Draw a rectangle at mouse position if left click is down
    if (R254 > 0.0) {
        rect(R252, R253, 30.0, 30.0, 0x58A6FF) // Blue square at cursor
    }

    text("PhasorLang Bundler Demo", 50.0, 50.0, 16.0, 0x3FB950)
    text("Mouse X: " + R252, 50.0, 70.0, 12.0, 0x8B949E)
    text("Mouse Y: " + R253, 50.0, 85.0, 12.0, 0x8B949E)
    text("Click L: " + R254, 50.0, 100.0, 12.0, 0x8B949E)
    text("Key Code: " + R230, 50.0, 115.0, 12.0, 0x8B949E)
    text("Key Down: " + R231, 50.0, 130.0, 12.0, 0x8B949E)
    text("Scroll Y: " + R255, 50.0, 145.0, 12.0, 0x8B949E)
    text("Viewport W: " + R250, 50.0, 160.0, 12.0, 0x8B949E)

    // Simulate usage of imported components (will be mocked bytecode)
    // ui_button("Test Button", 200.0, 250.0, 120.0, 40.0, 0.0, 0x8957E5, R252, R253)
    // The above is a function call. For simplicity in mock bytecode, I will only process literal UI calls.
}

screen imported_screen {
    cls(0x161B22)
    rect(100.0, 100.0, 200.0, 100.0, 0x238636)
    text("Imported Screen Content", 110.0, 120.0, 14.0, 0xFFFFFF)
}
