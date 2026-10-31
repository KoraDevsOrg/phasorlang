// runtime/phasor_runtime.js (minimal mock for bundler demonstration)
class PhasorRuntime {
    constructor(canvas, mainModuleSource, childModules) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.mainModuleSource = mainModuleSource;
        this.childModules = childModules;
        this.frameCounter = 0;

        console.log('--- PhasorRuntime Initialized (MOCK) ---');
        console.log('Main module source length:', mainModuleSource.length);
        console.log('Number of child modules:', childModules.length);
        childModules.forEach(mod => console.log(`  - Child: ${mod.name}, length: ${mod.content.length}`));
        
        this.resizeCanvas();
        window.addEventListener('resize', this.resizeCanvas.bind(this));
    }

    resizeCanvas() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
        this.ctx.fillStyle = '#0D1117'; // KoraDevs dark background
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        this.ctx.font = '16px "Space Mono", monospace';
        this.ctx.fillStyle = '#FFFFFF';
        this.ctx.fillText('PhasorLang App Running (MOCK)', 20, 40);
        this.ctx.fillText(`Main module (partial): ${this.mainModuleSource.substring(0, Math.min(50, this.mainModuleSource.length))}...`, 20, 70);
        this.childModules.forEach((mod, i) => {
            this.ctx.fillText(`Child ${i+1}: ${mod.name}`, 20, 100 + i * 20);
        });
    }

    start() {
        console.log('PhasorRuntime Started. Rendering mock content.');
        // In a real runtime, this would start the PVM loop.
        // For this mock, a single draw is sufficient to show the loaded state.
        this.resizeCanvas(); // Initial draw with updated dimensions
    }

    stop() {
        console.log('PhasorRuntime Stopped.');
    }
}
