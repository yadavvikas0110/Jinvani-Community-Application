const fs = require('fs');

const txt = fs.readFileSync('figma_node.json', 'utf8').replace(/^\uFEFF/, '');
const data = JSON.parse(txt);

const allChildren = data.nodes['592:15086'].document.children;

const targetFlows = [
    'Splash Screen',
    'Login Flow',
    'Sign Up Flow',
    'Home Page',
    'Job Seeker Flow',
    'Directory Flow'
];

function extractText(node, texts = []) {
    if (node.type === 'TEXT') {
        texts.push(node.characters.replace(/\n/g, ' '));
    }
    if (node.children) {
        node.children.forEach(c => extractText(c, texts));
    }
    return texts;
}

const summary = {};

allChildren.forEach(flow => {
    // Only analyze frames with names or target flows
    if (targetFlows.includes(flow.name) || flow.name === 'Splash Screen') {
        const screens = {};
        if (flow.children) {
            flow.children.forEach(screen => {
                const texts = extractText(screen);
                if (texts.length > 0) {
                    screens[screen.name] = texts.slice(0, 10); // First 10 texts
                }
            });
        } else {
             const texts = extractText(flow);
             if (texts.length > 0) screens[flow.name] = texts.slice(0, 10);
        }
        summary[flow.name] = screens;
    }
});

console.log(JSON.stringify(summary, null, 2));
