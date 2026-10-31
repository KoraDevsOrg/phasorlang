#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Function to simulate compilation: reads file content and identifies imports.
// In a real scenario, this would invoke `phasor.jar` to get actual bytecode.
function compilePhasorFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    const imports = [];
    const importRegex = /import\s+["'](.+?)["']/g;
    let match;
    while ((match = importRegex.exec(content)) !== null) {
        imports.push(match[1]);
    }
    return { content: content, imports: imports };
}

// Recursively resolves and "compiles" all .ph files
function resolveAndCompile(mainPhPath, initialBaseDir) {
    const compiledModules = new Map(); // Stores { absolutePath -> { name, content } }
    const queue = [];

    const mainAbsolutePath = path.resolve(initialBaseDir, mainPhPath);
    const mainRelativeName = path.relative(initialBaseDir, mainAbsolutePath).replace(/\\/g, '/');
    queue.push({ absolutePath: mainAbsolutePath, relativeName: mainRelativeName });
    
    // Add main module as a placeholder first to handle self-referencing or cycles involving main
    compiledModules.set(mainAbsolutePath, { name: mainRelativeName, content: '' }); 

    while (queue.length > 0) {
        const { absolutePath: currentAbsolutePath, relativeName: currentRelativeName } = queue.shift();

        // If module is already fully processed (content present), skip.
        if (compiledModules.get(currentAbsolutePath) && compiledModules.get(currentAbsolutePath).content !== '') {
            continue;
        }
        
        console.log(`Processing: ${currentAbsolutePath}`);
        const { content, imports } = compilePhasorFile(currentAbsolutePath);
        
        // Escape backticks, backslashes, and dollar signs for embedding in JS template literal
        const escapedContent = content.replace(/`/g, '\`').replace(/\\(?!`)/g, '\\\\').replace(/\$/g, '\$'); 
        
        // Update the module with its actual content
        compiledModules.set(currentAbsolutePath, { name: currentRelativeName, content: escapedContent });

        for (const importPath of imports) {
            const resolvedImportPath = path.resolve(path.dirname(currentAbsolutePath), importPath);
            const importRelativeName = path.relative(initialBaseDir, resolvedImportPath).replace(/\\/g, '/');

            // Only add to queue if it's not already completely processed or added for processing (as a placeholder)
            if (!compiledModules.has(resolvedImportPath) || compiledModules.get(resolvedImportPath).content === '') {
                 queue.push({ absolutePath: resolvedImportPath, relativeName: importRelativeName });
                 // Add a placeholder to prevent re-adding if found again before processing
                 if (!compiledModules.has(resolvedImportPath)) {
                    compiledModules.set(resolvedImportPath, { name: importRelativeName, content: '' });
                 }
            }
        }
    }

    let mainModuleSource = '';
    const childrenModules = [];

    const finalMainEntry = compiledModules.get(mainAbsolutePath);

    if (finalMainEntry) {
        mainModuleSource = finalMainEntry.content;
        compiledModules.delete(mainAbsolutePath); // Remove main from the map
    }

    for (const [absPath, moduleData] of compiledModules.entries()) {
        childrenModules.push({ name: moduleData.name, content: moduleData.content });
    }

    return { main: mainModuleSource, children: childrenModules };
}

async function bundle(inputPhFile, outputHtmlFile, options = {}) {
    const title = options.title || path.basename(inputPhFile, '.ph');
    const initialBaseDir = path.dirname(path.resolve(inputPhFile)); // Use input file's directory as base for resolving imports

    // 1. Read phasor_runtime.js
    const runtimeJsPath = path.join(__dirname, '../runtime/phasor_runtime.js'); // Adjust path as needed relative to tools/
    const phasorRuntimeJs = fs.readFileSync(runtimeJsPath, 'utf8');

    // 2. Resolve and "compile" all .ph files
    const { main, children } = resolveAndCompile(inputPhFile, initialBaseDir);

    // 3. Prepare children data for embedding
    const childrenJsArray = children.map(child => `{ name: '${child.name}', content: \`${child.content}\` }`).join(',\n        ');

    // 4. Construct the HTML
    const htmlContent = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title}</title>
    <style>
        body { margin: 0; overflow: hidden; background-color: #0B0E14; font-family: 'Space Mono', monospace; }
        canvas { display: block; background-color: #0B0E14; }
    </style>
</head>
<body>
    <canvas id="phasorCanvas"></canvas>
    <script>
        // Phasor Runtime Engine
        ${phasorRuntimeJs}

        // Main PhasorLang Module Source (simulated, would be bytecode/WASM)
        var PHASOR_MAIN_MODULE_SOURCE = \`${main}\`;

        // Imported PhasorLang Modules Source (simulated, would be bytecode/WASM)
        var PHASOR_CHILD_MODULES = [
        ${childrenJsArray}
        ];

        // Initialize and run Phasor Runtime
        window.addEventListener('DOMContentLoaded', () => {
            const canvas = document.getElementById('phasorCanvas');
            const runtime = new PhasorRuntime(canvas, PHASOR_MAIN_MODULE_SOURCE, PHASOR_CHILD_MODULES);
            runtime.start();
        });
    </script>
</body>
</html>
`;

    // 5. Write to output HTML file
    fs.writeFileSync(outputHtmlFile, htmlContent.trim(), 'utf8');
    console.log(`Successfully bundled ${inputPhFile} to ${outputHtmlFile}`);
}

// CLI Entry Point
if (require.main === module) {
    const args = process.argv.slice(2); // Remove 'node' and 'phasor_bundler.js'

    if (args.length < 2 || args.length % 2 !== 0 || args.length > 4) { // Allow 2 args (input, output) or 4 args (input, output, --title, 