import argparse
from pathlib import Path

def count_lines_in_file(file_path):
    with file_path.open('r', encoding='utf-8', errors='ignore') as file:
        return sum(1 for _ in file)

def main(directory):
    total_lines = 0
    bas_files = list(Path(directory).rglob('*.bas'))
    
    for bas_file in bas_files:
        line_count = count_lines_in_file(bas_file)
        total_lines += line_count
        print(f"{bas_file}: {line_count} lines")
    
    print(f"Total number of lines in all .bas scripts: {total_lines}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Count lines in .bas scripts")
    parser.add_argument('directory', type=str, help="Directory to search for .bas files")
    args = parser.parse_args()
    
    main(args.directory)