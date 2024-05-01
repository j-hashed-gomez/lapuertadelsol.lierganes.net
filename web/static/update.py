import hashlib
import os
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
        if "<!-- INICIO CARTA" in line:
            start = line.find('CARTA') + 6
            end = line.find('-->', start) - 1
            current_section = line[start:end].strip()
        elif "<!-- FINAL CARTA" in line and current_section:
            sections.append(current_section)
            current_section = None
    return sections

def update_section(html_path, section, items):
    with open(html_path, 'r+') as file:
        content = file.readlines()
        start_index = end_index = None
        for i, line in enumerate(content):
            if f"<!-- INICIO CARTA {section} -->" in line:
                start_index = i + 1
            elif f"<!-- FINAL CARTA {section} -->" in line:
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
            log(f"Section {section} has been updated.")

def restart_apache():
    try:
        subprocess.run(['/etc/init.d/apache2', 'reload'], check=True)
        log("Apache service has been reloaded successfully.")
    except subprocess.CalledProcessError:
        log("Failed to reload Apache service.", warning=True)

def main():
    html_path = "/var/www/html/carta.html"
    upload_path = "/var/www/html/uploads/"
    sections = read_sections(html_path)
    prev_hashes = {}
    
    log(f"Found sections: {', '.join(sections)}")
    
    for section in sections:
        file_path = os.path.join(upload_path, f"carta_{section}.txt")
        if os.path.exists(file_path):
            prev_hashes[section] = md5_hash(file_path)
        else:
            log(f"Missing definition file for section {section}", warning=True)
    
    for section in sections:
        file_path = os.path.join(upload_path, f"carta_{section}.txt")
        if os.path.exists(file_path):
            with open(file_path, 'r') as file:
                items = file.readlines()
                new_hash = md5_hash(file_path)
                if new_hash != prev_hashes.get(section, None):
                    log(f"Section {section} will be updated due to definition changes.")
                    update_section(html_path, section, items)
                    
    restart_apache()

if __name__ == "__main__":
    main()
