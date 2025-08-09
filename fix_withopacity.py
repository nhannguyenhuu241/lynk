#!/usr/bin/env python3
import os
import re
import sys

def fix_withOpacity_in_file(filepath):
    """Replace withOpacity() with withValues(alpha: ) in a Dart file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pattern to match .withOpacity(value)
        pattern = r'\.withOpacity\(([^)]+)\)'
        replacement = r'.withValues(alpha: \1)'
        
        # Count replacements
        matches = re.findall(pattern, content)
        if not matches:
            return 0
        
        # Replace all occurrences
        new_content = re.sub(pattern, replacement, content)
        
        # Write back to file
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        return len(matches)
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return 0

def find_dart_files_with_withOpacity(root_dir):
    """Find all Dart files containing withOpacity."""
    dart_files = []
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                        if 'withOpacity(' in content:
                            dart_files.append(filepath)
                except Exception as e:
                    print(f"Error reading {filepath}: {e}")
    return dart_files

def main():
    root_dir = '/Volumes/SSDCUANHAN/UniStudioProject/LynkAn/LynkAn-App/lib'
    
    print("Finding Dart files with withOpacity()...")
    files = find_dart_files_with_withOpacity(root_dir)
    
    # Exclude the files we've already fixed
    already_fixed = [
        '/Volumes/SSDCUANHAN/UniStudioProject/LynkAn/LynkAn-App/lib/common/widgets/bot/chibi_pet_widget.dart',
        '/Volumes/SSDCUANHAN/UniStudioProject/LynkAn/LynkAn-App/lib/common/widgets/bot/cosmic_critter_widget.dart',
        '/Volumes/SSDCUANHAN/UniStudioProject/LynkAn/LynkAn-App/lib/common/widgets/bot/flame/component/face_component.dart',
        '/Volumes/SSDCUANHAN/UniStudioProject/LynkAn/LynkAn-App/lib/common/widgets/bot/ghost_widget.dart',
        '/Volumes/SSDCUANHAN/UniStudioProject/LynkAn/LynkAn-App/lib/common/widgets/bot/mystical_loading_widget.dart',
    ]
    
    files_to_fix = [f for f in files if f not in already_fixed]
    
    print(f"Found {len(files_to_fix)} files to fix")
    
    total_replacements = 0
    fixed_files = 0
    
    for filepath in files_to_fix:
        replacements = fix_withOpacity_in_file(filepath)
        if replacements > 0:
            print(f"Fixed {replacements} occurrences in {filepath}")
            total_replacements += replacements
            fixed_files += 1
    
    print(f"\nSummary:")
    print(f"- Fixed {fixed_files} files")
    print(f"- Total replacements: {total_replacements}")

if __name__ == "__main__":
    main()