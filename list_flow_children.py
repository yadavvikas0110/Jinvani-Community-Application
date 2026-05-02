import json

try:
    with open('figma_node.json', 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
    
    all_children = data["nodes"]["592:15086"]["document"]["children"]
    for flow in all_children:
        if flow.get('name') == "Directory Flow":
             print("Directory Flow Children:")
             for child in flow.get("children", []):
                 print(f" - {child.get('name')}")
        if flow.get('name') == "Job Seeker Flow":
             print("Job Seeker Flow Children:")
             for child in flow.get("children", []):
                 print(f" - {child.get('name')}")

except Exception as e:
    print(f"Error: {e}")
