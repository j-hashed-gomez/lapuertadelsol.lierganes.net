import hashlib
import os
import json
import datetime
import subprocess

def log(message, warning=False):
    prefix = "WARNING: " if warning else ""
    print(f"{datetime.datetime.now()} - {prefix}{message}")

def md5_hash(file_path):
    hasher = hashlib.md5()
    with open(file_path, 'rb') as f:
        buf = f.read()
        hasher.update(buf)
    return hasher.hexdigest()

def read_sections(html_path):
    sections = []
    with open(html_path, 'r') as file:
        content = file.readlines()
    current_section = None
    for line in content:
        if "<!-- INICIO " in line:
            parts = line.strip().split()
            if parts[1] == os.path.basename(html_path) and len(parts) > 2:
                current_section = parts[2]
        elif "<!-- FINAL " in line:
            parts = line.strip().split()
            if parts[1] == os.path.basename(html_path) and current_section and len(parts) > 2 and parts[2] == current_section:
                sections.append(current_section)
                current_section = None
    return sections

def update_section(html_path, section, items):
    with open(html_path, 'r+') as file:
        content = file.readlines()
        start_index = end_index = None
        for i, line in enumerate(content):
            if f"<!-- INICIO {os.path.basename(html_path)} {section} -->" in line:
                start_index = i + 1
            elif f"<!-- FINAL {os.path.basename(html_path)} {section} -->" in line:
                end_index = i
                break
        if start_index is not None and end_index is not None:
            content[start_index:end_index] = [
                f"  <tr>\n    <th scope='row'>{index + 1}</th>\n    <td colspan='2'>{item.split('::')[0]}</td>\n    <td>{item.split('::')[1]} €</td>\n  </tr>\n"
                for index, item in enumerate(items) if item.strip()
            ]
            file.seek(0)
            file.writelines(content)
            file.truncate()
            log(f"Section {section} in {os.path.basename(html_path)} has been updated.")
            return True
    return False

def reload_apache():
    try:
        subprocess.run(['/etc/init.d/apache2', 'reload'], check=True)
        log("Apache service has been reloaded successfully.")
    except subprocess.CalledProcessError:
        log("Failed to reload Apache service.", warning=True)

def load_prev_hashes(file_path):
    if os.path.exists(file_path):
        with open(file_path, 'r') as f:
            return json.load(f)
    else:
        return {}

def save_hashes(file_path, hashes):
    with open(file_path, 'w') as f:
        json.dump(hashes, f)

def main():
    html_files = ["/var/www/html/carta.html", "/var/www/html/raciones.html"]
    upload_path = "/var/www/html/uploads/"
    hash_file = "/var/www/html/hashes.json"

    for html_path in html_files:
        sections = read_sections(html_path)
        prev_hashes = load_prev_hashes(hash_file)
        current_hashes = {}
        update_required = False

        log(f"Processing {html_path}. Found sections: {', '.join(sections)}")
        
        for section in sections:
            file_path = os.path.join(upload_path, f"{os.path.basename(html_path)}_{section}.txt")
            if os.path.exists(file_path):
                current_hash = md5_hash(file_path)
                current_hashes[section] = current_hash
                if section not in prev_hashes or current_hash != prev_hashes[section]:
                    log(f"Section {section} in {os.path.basename(html_path)} will be updated due to definition changes.")
                    with open(file_path, 'r') as file:
                        items = file.readlines()
                        if update_section(html_path, section, items):
                            update_required = True
            else:
                log(f"Missing definition file for section {section} in {os.path.basename(html_path)}", warning=True)

        save_hashes(hash_file, current_hashes)

        if update_required:
            reload_apache()

if __name__ == "__main__":
    main()
