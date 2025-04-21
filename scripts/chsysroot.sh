# All required libraries are in the given sysroot path.

# Check if patchelf is installed
if ! command -v patchelf > /dev/null; then
    echo "patchelf could not be found. Please install it first."
    exit 1
fi

help() {
    echo "Usage: $0 <sysroot> <binary>"
    echo "  sysroot: path to the sysroot directory of the target system"
    echo "  binary: path to the binary to be patched"
}
if [ $# -ne 2 ]; then
    help
    exit 1
fi

SYSROOT=$1
BINARY=$2
patchelf --set-rpath $SYSROOT/lib $BINARY
patchelf --add-rpath $SYSROOT/usr/lib $BINARY
patchelf --add-rpath $SYSROOT/usr/lib64 $BINARY
patchelf --set-interpreter $SYSROOT/lib/ld-linux-aarch64.so.1 $BINARY
