import sys
import os

# --- Opcode Definitions and Structures ---
OPCODES = {
    # R-Type: Opcode (11 bits)
    "ADD":  "10001011000",
    "SUB":  "11001011000",
    "AND":  "10001010000",
    "ORR":  "10101010000",
    
    # D-Type: Opcode (11 bits)
    "LDUR": "11111000010",
    "STUR": "11111000000",
    
    # CB-Type: Opcode (8 bits)
    "CBZ":  "10110100",
    
    # B-Type: Opcode (6 bits)
    "B":    "000101"
}

def to_bin(value, num_bits):
    """Converts integer to 2's complement binary with fixed width."""
    try:
        val = int(value)
    except ValueError:
        raise ValueError(f"Invalid immediate value: {value}")
        
    if val < 0:
        val = (1 << num_bits) + val
    
    binary = f"{val:b}"
    
    # Check if value fits in the number of bits
    if len(binary) > num_bits:
        # If negative and overflowed due to python's '1' prefix, ok, else error
        if int(value) >= 0 or len(binary) > num_bits: 
             # Fine adjustment for overflowed two's complement slice
             pass 
             
    return binary.zfill(num_bits)[-num_bits:]

def parse_reg(reg_str):
    """Converts register string (Xn or XZR) to 5-bit binary."""
    reg_str = reg_str.upper().strip().replace(",", "")
    
    if reg_str == "XZR":
        return "11111" # 31
    
    if not reg_str.startswith("X"):
        raise ValueError(f"Invalid register: {reg_str}")
    
    try:
        num = int(reg_str[1:])
        if num < 0 or num > 31:
            raise ValueError
        return to_bin(num, 5)
    except:
        raise ValueError(f"Invalid register number: {reg_str}")

def assemble_line(line, line_num):
    # 1. Cleanup: Remove comments and extra spaces
    clean_line = line.split("--")[0].strip()
    if not clean_line:
        return None # Empty line or just comment

    # 2. Tokenization: Replace commas with spaces to facilitate split
    # Keep '#' with the number, remove brackets to facilitate parsing
    parts = clean_line.replace(",", " ").replace("[", " ").replace("]", " ").split()
    instr = parts[0].upper()

    machine_code = ""

    try:
        if instr not in OPCODES:
            raise ValueError(f"Unknown instruction: {instr}")

        # --- R-TYPE (ADD, SUB, AND, ORR) ---
        # Format: Opcode(11) | Rm(5) | shamt(6) | Rn(5) | Rd(5)
        # Syntax: INSTR Rd, Rn, Rm
        if instr in ["ADD", "SUB", "AND", "ORR"]:
            if len(parts) != 4:
                raise ValueError(f"Incorrect syntax for {instr}. Expected: {instr} Rd, Rn, Rm")
            
            rd_bin = parse_reg(parts[1])
            rn_bin = parse_reg(parts[2])
            rm_bin = parse_reg(parts[3])
            shamt_bin = "000000" # shamt fixed at 0 per instructions
            
            machine_code = f"{OPCODES[instr]}{rm_bin}{shamt_bin}{rn_bin}{rd_bin}"

        # --- D-TYPE (LDUR, STUR) ---
        # Format: Opcode(11) | offset(9) | Op2(2) | Rn(5) | Rt(5)
        # Syntax: LDUR Rt, [Rn, #offset]
        elif instr in ["LDUR", "STUR"]:
            # Expected parts after cleanup: ['LDUR', 'Xt', 'Xn', '#offset']
            if len(parts) != 4:
                raise ValueError(f"Incorrect syntax for {instr}. Expected: {instr} Rt, [Rn, #offset]")
            
            rt_bin = parse_reg(parts[1])
            rn_bin = parse_reg(parts[2])
            
            imm_str = parts[3].replace("#", "")
            offset_bin = to_bin(imm_str, 9)
            op2_bin = "00" # Op2 fixed at 00 per instructions
            
            machine_code = f"{OPCODES[instr]}{offset_bin}{op2_bin}{rn_bin}{rt_bin}"

        # --- CB-TYPE (CBZ) ---
        # Format: Opcode(8) | offset(19) | Rt(5)
        # Syntax: CBZ Rt, #offset
        elif instr == "CBZ":
            if len(parts) != 3:
                raise ValueError(f"Incorrect syntax for {instr}. Expected: {instr} Rt, #offset")
            
            rt_bin = parse_reg(parts[1])
            imm_str = parts[2].replace("#", "")
            offset_bin = to_bin(imm_str, 19)
            
            machine_code = f"{OPCODES[instr]}{offset_bin}{rt_bin}"

        # --- B-TYPE (B) ---
        # Format: Opcode(6) | offset(26)
        # Syntax: B #offset
        elif instr == "B":
            if len(parts) != 2:
                raise ValueError(f"Incorrect syntax for {instr}. Expected: {instr} #offset")
            
            imm_str = parts[1].replace("#", "")
            offset_bin = to_bin(imm_str, 26)
            
            machine_code = f"{OPCODES[instr]}{offset_bin}"

        # Final size validation
        if len(machine_code) != 32:
             raise ValueError(f"Internal error: Generated instruction has {len(machine_code)} bits, expected 32.")
             
        return machine_code

    except ValueError as e:
        print(f"Error on line {line_num}: {line.strip()}")
        print(f"Detail: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error on line {line_num}: {e}")
        sys.exit(1)

def main():
    if len(sys.argv) != 2:
        print("Usage: python assembler.py <input_file.asm>")
        return

    input_filename = sys.argv[1]
    
    # Define output filename (replace extension with .dat)
    base_name = os.path.splitext(input_filename)[0]
    output_filename = base_name + ".dat"

    print(f"Assembling {input_filename}...")

    compiled_lines = []

    try:
        with open(input_filename, 'r') as f:
            for i, line in enumerate(f, 1):
                binary_instr = assemble_line(line, i)
                if binary_instr:
                    # Break the 32 bits into 4 lines of 8 bits (Big Endian)
                    # The instructions require 8 bits per line.
                    compiled_lines.append(binary_instr[0:8])
                    compiled_lines.append(binary_instr[8:16])
                    compiled_lines.append(binary_instr[16:24])
                    compiled_lines.append(binary_instr[24:32])

        with open(output_filename, 'w') as f:
            for n, line in enumerate(compiled_lines):
                if n == 0:
                    f.write(line)
                else:
                    f.write('\n' + line)

        print(f"Success! Generated file: {output_filename}")

    except FileNotFoundError:
        print(f"Error: File '{input_filename}' not found.")
    except Exception as e:
        print(f"I/O Error: {e}")

if __name__ == "__main__":
    main()