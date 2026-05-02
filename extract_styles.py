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

try:
    with open('figma_node.json', 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
        
    booking_flow = next((c for c in data["nodes"]["592:15086"]["document"]["children"] if c.get("name") == "Property Booking Flow"), None)
    
    if booking_flow:
        screens_to_check = ["3", "4", "5", "7", "10", "Upcoming Booking"]
        
        summary = {}
        for screen in booking_flow.get("children", []):
            if screen.get("name") in screens_to_check:
                details = extract_node_details(screen)
                
                colors = set(d["color"] for d in details if d["type"] == "BG_COLOR")
                texts = [d for d in details if d["type"] == "TEXT"]
                
                # Get top 5 unique background colors
                summary[screen["name"]] = {
                    "bg_colors": list(colors)[:10],
                    "sample_texts": texts[:15]
                }
                
        with open('figma_summary.json', 'w') as out:
            json.dump(summary, out, indent=2)
        print("Summary generated in figma_summary.json")

except Exception as e:
    print(f"Error: {e}")
