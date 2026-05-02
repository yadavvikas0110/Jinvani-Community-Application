import json
import sys

def parse_node(node, indent=0, results=None):
    if results is None:
        results = []
        
    prefix = "  " * indent
    name = node.get("name", "Unnamed")
    ntype = node.get("type", "UNKNOWN")
    
    info = f"{prefix}- {name} [{ntype}]"
    
    if ntype == "TEXT":
        chars = node.get("characters", "").replace('\n', '\\n')
        info += f" | Text: '{chars}'"
        style = node.get("style", {})
        font_size = style.get("fontSize")
        font_weight = style.get("fontWeight")
        if font_size or font_weight:
            info += f" | Style: {font_size}px, w{font_weight}"
            
    if "fills" in node:
        fills = [f for f in node["fills"] if f.get("type") == "SOLID" and f.get("visible", True) != False]
        if fills:
            color = fills[0].get("color", {})
            r, g, b = int(color.get("r", 0)*255), int(color.get("g", 0)*255), int(color.get("b", 0)*255)
            info += f" | Fill: #{r:02x}{g:02x}{b:02x}"
            
    results.append(info)
    
    for child in node.get("children", []):
        parse_node(child, indent + 1, results)
        
    return results

try:
    with open('figma_node.json', 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
        
    nodes = data.get("nodes", {})
    if not nodes:
        print("No nodes found in Figma response.")
        if "err" in data:
            print("Error:", data["err"])
        sys.exit(1)
        
    for node_id, node_data in nodes.items():
        doc = node_data.get("document", {})
        print(f"=== Node {node_id} ===")
        res = parse_node(doc)
        print('\n'.join(res[:200])) # Print first 200 lines to avoid blowing up output
        if len(res) > 200:
            print(f"... and {len(res)-200} more items")
            
except Exception as e:
    print(f"Failed: {e}")
