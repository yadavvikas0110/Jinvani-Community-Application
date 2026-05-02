import json

try:
    with open('figma_node.json', 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
    
    def find_node_by_name(node, target_name):
        if target_name.lower() in node.get('name', '').lower():
            print(f"Found node: {node.get('name')} (ID: {node.get('id')})")
        
        for child in node.get('children', []):
            find_node_by_name(child, target_name)

    all_children = data["nodes"]["592:15086"]["document"]["children"]
    for flow in all_children:
        find_node_by_name(flow, "Matrimonial")
        find_node_by_name(flow, "Business")

except Exception as e:
    print(f"Error: {e}")
