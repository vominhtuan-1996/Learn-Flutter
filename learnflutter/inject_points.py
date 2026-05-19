import os

file_path = 'lib/features/test_screen/google_map_engine_demo_screen.dart'
points_path = 'tan_thuan_points.txt'

with open(points_path, 'r') as f:
    points_code = f.read()

with open(file_path, 'r') as f:
    content = f.read()

# I want to inject points_code right before `return points;` inside `_sampleHeatmap`
insertion_marker = 'return points;'
if insertion_marker in content:
    replacement = f"""
      // ─── Boundary of Tân Thuận ───
      points.addAll(const [
{points_code}
      ]);

      {insertion_marker}"""
    content = content.replace(insertion_marker, replacement)
    
    with open(file_path, 'w') as f:
        f.write(content)
    print("Injected Tan Thuan points successfully!")
else:
    print("Could not find insertion marker")
