const fs = require('fs');

const txt = fs.readFileSync('figma_node.json', 'utf8').replace(/^\uFEFF/, '');
const data = JSON.parse(txt);

const bookingFlow = data.nodes['592:15086'].document.children.find(c => c.name === 'Property Booking Flow');

function extractText(node, texts = []) {
    if (node.type === 'TEXT') {
        texts.push(node.characters.replace(/\n/g, ' '));
    }
    if (node.children) {
        node.children.forEach(c => extractText(c, texts));
    }
    return texts;
}

if (bookingFlow) {
    const summary = {};
    bookingFlow.children.forEach(c => {
        const texts = extractText(c);
        // Take first 10 text nodes to identify the screen
        summary[c.name] = texts.slice(0, 10);
    });
    console.log(JSON.stringify(summary, null, 2));
}
