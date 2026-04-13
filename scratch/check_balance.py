
import sys

def check_balance(filename, start_line, end_line):
    with open(filename, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    code = "".join(lines[start_line-1:end_line])
    pCount = 0
    bCount = 0
    sCount = 0
    
    for char in code:
        if char == '(': pCount += 1
        elif char == ')': pCount -= 1
        elif char == '{': bCount += 1
        elif char == '}': bCount -= 1
        elif char == '[': sCount += 1
        elif char == ']': sCount -= 1
        
    print(f"Parentheses: {pCount}")
    print(f"Braces: {bCount}")
    print(f"Square brackets: {sCount}")

if __name__ == "__main__":
    check_balance(sys.argv[1], int(sys.argv[2]), int(sys.argv[3]))
