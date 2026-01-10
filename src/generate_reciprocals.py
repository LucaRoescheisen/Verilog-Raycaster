with open("reciprocal_lut.mem", "w") as f:
    for i in range(1, 1024):
        dir_val = i / 1024.0  # Normalize index to 0.0 - 1.0 range
        reciprocal = 1.0 / dir_val
        # Convert to Q8.16 (multiply by 2^16)
        fixed_val = int(reciprocal * 65536)
        f.write(f"{fixed_val:06x}\n")