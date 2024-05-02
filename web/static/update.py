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
    file_tag = os.path.basename(html_path).split('.')[0].upper()
    for line in content:
        line_upper = line.strip().upper()
        if f"<!-- INICIO {file_tag}" in line_upper:
            start = line_upper.find(f"INICIO {file_tag}") + len(f"INICIO {file_tag}") + 1
            end = line_upper.find("-->")
            current_section = line_upper[start:end].strip()
        elif f"<!-- FINAL {file_tag}" in line_upper and current_section:
            end_section = line_upper.find(f"FINAL {file_tag}") + len(f"FINAL {file_tag}") + 1
            end_section_name = line_upper[end_section:line_upper.find("-->")].strip()
            if current_section == end_section_name:
                sections.append(current_section)
                current_section = None
    return sections

def update_section(html_path, section, items):
    with open(html_path, 'r+') as file:
        content = file.readlines()
        start_index = end_index = None
        section_upper = section.upper()
        for i, line in enumerate(content):
            if f"<!-- INICIO {os.path.basename(html_path).split('.')[0].upper()} {section_upper} -->" in line.upper():
                start_index = i + 1
            elif f"<!-- FINAL {os.path.basename(html_path).split('.')[0].upper()} {section_upper} -->" in line.upper():
                end_index = i
                break
        if start_index is not None and end_index is not None:
            content = content[:start_index] + content[end_index:]
            new_content = [
                f'    <tr> <th scope="row">{index + 1}</th> <td colspan="2">{item.split("::")[0]}</td> <td>{item.split("::")[1]} €</td> </tr>\n'
                for index, item in enumerate(items) if item.strip()
            ]
            content[start_index:start_index] = new_content
            file.seek(0)
            file.writelines(content)
            file.truncate()
            log(f"Section {section} in {os.path.basename(html_path)} has been initialized and updated.")
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
    html_files = ["/var/www/html/carta.html", "/var/www/html/raciones.html", "/var/www/html/bodega.html"]
    upload_path = "/var/www/html/uploads/"
    hash_file = "/var/www/html/hashes.json"

    for html_path in html_files:
        sections = read_sections(html_path)
        prev_hashes = load_prev_hashes(hash_file)
        current_hashes = {}
        update_required = False

        log(f"Processing {html_path}. Found sections: {', '.join(sections)}")
        
        for section in sections:
            file_path = os.path.join(upload_path, f"{os.path.basename(html_path).split('.')[0].lower()}_{section.replace(' ', '_').lower()}.txt")
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
