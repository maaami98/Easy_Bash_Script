import subprocess
import argparse
import os

def copy_and_execute_script(host, user, script_file):
    remote_path = f"/tmp/{os.path.basename(script_file)}"
    
    try:
        # scp ile script dosyasını sunucuya kopyala
        scp_command = f"scp {script_file} {user}@{host}:{remote_path}"
        result = subprocess.run(scp_command, shell=True, capture_output=True, text=True)
        
        if result.returncode != 0:
            print(f"{host} sunucusuna script dosyasını kopyalarken bir hata oluştu:")
            print(result.stderr)
            return
        
        # ssh ile script dosyasını çalıştır
        ssh_command = f'ssh {user}@{host} "bash {remote_path} && rm {remote_path}"'
        result = subprocess.run(ssh_command, shell=True, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"{host} sunucusunda script başarıyla çalıştırıldı.")
            print(result.stdout)
        else:
            print(f"{host} sunucusunda script çalıştırılırken bir hata oluştu:")
            print(result.stderr)
            
    except Exception as e:
        print(f"{host} sunucusunda script çalıştırılırken bir hata oluştu: {e}")

def read_servers(file_path):
    servers = []
    with open(file_path, "r") as file:
        for line in file:
            host = line.strip()
            if host:
                servers.append(host)
    return servers

def main():
    # Argümanları tanımla
    parser = argparse.ArgumentParser(description="SSH ile sunuculara komut ve script dosyası çalıştırma")
    parser.add_argument("-u", "--user", required=True, help="Sunucuya bağlanacak kullanıcı adı")
    parser.add_argument("-f", "--file", required=True, help="Sunucu listesini içeren dosya yolu")
    parser.add_argument("-c", "--command", required=False, help="Çalıştırılacak SSH komutu")
    parser.add_argument("-sf", "--scriptfile", required=False, help="Sunucuda çalıştırılacak script dosyasının yolu")

    args = parser.parse_args()
    user = args.user
    file_path = args.file
    command = args.command
    script_file = args.scriptfile

    # Sunucular listesini oku
    servers = read_servers(file_path)

    # Her sunucu için SSH bağlantısı kur ve komutu çalıştır veya script dosyasını kopyala ve çalıştır
    for host in servers:
        if command:
            ssh_command = f'ssh {user}@{host} "{command}"'
            subprocess.run(ssh_command, shell=True)
        
        if script_file:
            copy_and_execute_script(host, user, script_file)

if __name__ == "__main__":
    main()
