# Create a new VHD file
$vhdPath = "F:\MyOS\build\myos.vhd"
$size = 32MB

# Create fixed size VHD
New-VHD -Path $vhdPath -Fixed -SizeBytes $size

# Mount the VHD
$disk = Mount-VHD -Path $vhdPath -PassThru

# Get the disk number
$diskNumber = $disk.Number

# Initialize the disk and create a partition
Initialize-Disk -Number $diskNumber -PartitionStyle MBR
$partition = New-Partition -DiskNumber $diskNumber -UseMaximumSize -IsActive
Format-Volume -Partition $partition -FileSystem FAT32 -Force

# Copy the bootloader and kernel
$driveLetter = $partition.DriveLetter
Copy-Item "build\myos.bin" -Destination "${driveLetter}:\"

# Dismount the VHD
Dismount-VHD -Path $vhdPath 