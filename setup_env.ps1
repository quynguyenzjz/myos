# Use tools from F:/cursor
$nasmPath = "F:/cursor/nasm"
$crossPath = "F:/cursor/llvm-mingw"

# Add tools to PATH for current session
$env:Path = "$nasmPath;$crossPath\bin;$env:Path"

# Build the OS
Write-Host "Building OS..."
Set-Location F:\MyOS
& make clean
& make

Write-Host "Build complete! The OS binary should be in the build directory."

# Create VirtualBox disk
Write-Host "Creating VirtualBox disk..."
& .\create_image.ps1

Write-Host "Setup complete! You can now:"
Write-Host "1. Open VirtualBox"
Write-Host "2. Create a new VM (Type: Other, Version: Other/Unknown 64-bit)"
Write-Host "3. Use the created VHD file at 'F:\MyOS\build\myos.vhd' as the hard disk" 