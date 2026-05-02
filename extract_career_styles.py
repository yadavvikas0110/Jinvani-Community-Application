import json

def rgb_to_hex(r, g, b):
    return f"#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}"

def extract_node_details(node, results=None):
    if results is None:
        results = []
    if node.get("type") == "TEXT":
        chars = node.get("characters", "").replace('\n', ' ')
        style = node.get("style", {})
        fills = [f for f in node.get("fills", []) if f.get("type") == "SOLID" and f.get("visible", True) != False]
        color_hex = rgb_to_hex(fills[0]["color"]["r"], fills[0]["color"]["g"], fills[0]["color"]["b"]) if fills else ""
        results.append({
            "type": "TEXT",
            "text": chars,
            "fontSize": style.get("fontSize"),
            "fontWeight": style.get("fontWeight"),
            "color": color_hex
        })
    elif "fills" in node:
        fills = [f for f in node.get("fills", []) if f.get("type") == "SOLID" and f.get("visible", True) != False]
        if fills:
            color_hex = rgb_to_hex(fills[0]["color"]["r"], fills[0]["color"]["g"], fills[0]["color"]["b"])
            if color_hex not in ["#ffffff", "#000000"]:
                results.append({
                    "type": "BG_COLOR",
                    "color": color_hex
                })
    for child in node.get("children", []):
        extract_node_details(child, results)
    return results

def find_target_nodes(node, target_names, found_nodes):
    name = node.get('name', '')
    for target in target_names:
        if target.lower() in name.lower():
            found_nodes.append(node)
    
    for child in node.get('children', []):
        find_target_nodes(child, target_names, found_nodes)

try:
    with open('figma_node.json', 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
        
    root_node = data["nodes"]["592:15086"]["document"]
    
    summary = {}
    target_flows = ["Job Seeker Flow", "Business owners", "Matrimonial"]
    
    found_nodes = []
    find_target_nodes(root_node, target_flows, found_nodes)
    
    for flow in found_nodes:
        flow_name = flow.get("name")
        # If it's a frame or group, we treat it as a flow/screen
        details = extract_node_details(flow)
        colors = set(d["color"] for d in details if d["type"] == "BG_COLOR")
        texts = [d for d in details if d["type"] == "TEXT"]
        
        if flow_name not in summary:
            summary[flow_name] = {
                "bg_colors": list(colors)[:10],
                "sample_texts": texts[:20]
            }
                
    with open('career_figma_summary.json', 'w') as out:
        json.dump(summary, out, indent=2)
    print("Career summary generated in career_figma_summary.json")

except Exception as e:
    print(f"Error: {e}")
