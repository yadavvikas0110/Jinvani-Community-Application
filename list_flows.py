import json

try:
    with open('figma_node.json', 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
    
    all_children = data["nodes"]["592:15086"]["document"]["children"]
    for flow in all_children:
        print(f"Flow Name: {flow.get('name')}")

except Exception as e:
    print(f"Error: {e}")
