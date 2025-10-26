import os
import hashlib
from collections import defaultdict

def get_file_hash(filepath):
    hasher = hashlib.md5()
    try:
        with open(filepath, 'rb') as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hasher.update(chunk)
        return hasher.hexdigest(), os.path.getsize(filepath)
    except IOError:
        return None

def main():
    root_dir = '.'
    names = defaultdict(list)
    duplicates = defaultdict(list)
    # Skip .git, __pycache__, node_modules
    exclude_dirs = {'.git', '__pycache__', 'node_modules'}
    for dirpath, dirnames, filenames in os.walk(root_dir):
        dirnames[:] = [d for d in dirnames if d not in exclude_dirs]
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)
            hash_val, size = get_file_hash(filepath)
            if hash_val is None:
                continue
            # For same name
            names[filename].append(filepath)
            # For duplicates
            key = (hash_val, size)
            duplicates[key].append(filepath)

    print("Files with same name (project only, excluding node_modules):")
    for name, paths in names.items():
        if len(paths) > 1:
            print(f"\n{name}:")
            for p in paths:
                print(f"  {p}")

    print("\n\nDuplicate files (same content, project only, excluding node_modules):")
    for files in duplicates.values():
        if len(files) > 1:
            print(f"\nHash group ({len(files)} files):")
            for f in sorted(files):
                print(f"  {f} (size: {os.path.getsize(f)} bytes)")

if __name__ == "__main__":
    main()
