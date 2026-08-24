import os

# PÄIVITETTY: Etsitään tiedostot os_bin-kansiosta, erillään emulaattorista
IMAGE_NAME = "hdd.img"
LOADER_BIN = os.path.join("os_bin", "loader.bin")
MONITOR_BIN = os.path.join("os_bin", "monitor.bin")

def make_disk():
    # 1. Luodaan tyhjä 10MB hdd.img
    print(f"Alustetaan {IMAGE_NAME}...")
    disk = bytearray(1024 * 1024 * 10)

    # 2. Luetaan loader.bin lohkoon LBA 0 (offset 0)
    if os.path.exists(LOADER_BIN):
        with open(LOADER_BIN, "rb") as f:
            loader = f.read()
            disk[0:len(loader)] = loader
            print(f"-> {LOADER_BIN} asennettu lohkoon 0.")
    else:
        print(f"VIRHE: {LOADER_BIN} puuttuu!")
        return

    # 3. Luetaan monitor.bin ja lasketaan sen tiedot
    if os.path.exists(MONITOR_BIN):
        with open(MONITOR_BIN, "rb") as f:
            monitor_data = f.read()
            
        file_size_bytes = len(monitor_data)
        file_size_sectors = (file_size_bytes + 511) // 512
        
        # Kirjoitetaan monitorin raakadata alkaen LBA 2 (offset 1024)
        start_byte = 1024
        end_byte = start_byte + file_size_bytes
        disk[start_byte:end_byte] = monitor_data
        print(f"-> {MONITOR_BIN} kirjoitettu LBA 2 eteenpäin ({file_size_sectors} lohkoa).")
    else:
        print(f"VIRHE: {MONITOR_BIN} puuttuu!")
        return

    # 4. LUODAAN INDEKSITAULUKKO LBA 1 -LOHKOON (offset 512)
    dir_offset = 512
    name = b"MONITOR.SYS\x00"
    disk[dir_offset : dir_offset + len(name)] = name
    
    # Big-Endian pituudet M68k:lle
    disk[dir_offset + 12 : dir_offset + 16] = (2).to_bytes(4, byteorder='big')
    disk[dir_offset + 16 : dir_offset + 20] = file_size_bytes.to_bytes(4, byteorder='big')
    disk[dir_offset + 20 : dir_offset + 24] = file_size_sectors.to_bytes(4, byteorder='big')
    
    with open(IMAGE_NAME, "wb") as f:
        f.write(disk)
    print(f"\nValmis! {IMAGE_NAME} on onnistuneesti luotu Custom-tiedostojarjestelmalla.")

if __name__ == "__main__":
    make_disk()
