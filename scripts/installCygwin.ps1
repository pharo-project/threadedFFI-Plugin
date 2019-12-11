# Stop on errors
$ErrorActionPreference = 'stop'

# Parse some arguments and set some variables.
$installerName = $args[0]
$cygwinArch = $args[1]
$installerURL = "http://cygwin.com/$installerName"
$cygwinRoot = 'c:\cygwin'
$cygwinMirror ="http://cygwin.mirror.constant.com"

# Download the cygwin installer.
echo "Downloading the Cygwin installer from $installerURL"
Invoke-WebRequest -UseBasicParsing -URI "$installerURL" -OutFile "$installerName"

# Install cygwin and the required packages.
echo "Installing Cygwin packages"
& ".\$installerName" -dgnqNO -R "$cygwinRoot" -s "$cygwinMirror" -l "$cygwinRoot\var\cache\setup" `
    -P make `
    -P cmake `
    -P zip `
    -P binutils `
    -P gcc-core `
    -P gcc-g++ `
    -P mingw64-$cygwinArch-binutils `
    -P mingw64-$cygwinArch-gcc-core `
    -P mingw64-$cygwinArch-gcc-g++ `
    -P unzip `
    -P wget `
    -P git `
    -P patch `
    -P autoconf `
    -P autoconf2.5 `
    -P automake `
    -P automake1.16 `
    -P libtool `
    -P curl | Out-Null

echo "Cygwin installed under $cygwinRoot"
