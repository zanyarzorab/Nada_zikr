#!/usr/bin/env python3
# Read the file
with open('lib/models/app_data.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find sleepAzkar line number
for i, line in enumerate(lines):
    if 'static final List<Azkar> sleepAzkar' in line:
        print(f"Found sleepAzkar at line {i+1}")
        
        # Count brackets from this line forward
        bracket_count = 0
        for j in range(i, len(lines)):
            for char in lines[j]:
                if char == '[':
                    bracket_count += 1
                elif char == ']':
                    bracket_count -= 1
                    if bracket_count == 0:
                        print(f"Found closing bracket at line {j+1}")
                        print(f"Total lines in sleepAzkar: {j-i+1}")
                        print(f"sleepAzkar spans from line {i+1} to {j+1}")
                        exit(0)
