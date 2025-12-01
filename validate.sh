#!/bin/bash
# Validation script to check the project structure

echo "Checking project structure..."

# Check for required files
FILES=(
    "build.zig"
    "build.zig.zon"
    "lib/utils.zig"
    "README.md"
    "QUICKSTART.md"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done

# Check for all day files
for day in {01..12}; do
    SRC="src/day-${day}.zig"
    INPUT="inputs/day-${day}.txt"
    EXAMPLE="inputs/day-${day}-example-1.txt"
    
    if [ ! -f "$SRC" ]; then
        echo "✗ $SRC missing"
        exit 1
    fi
    if [ ! -f "$INPUT" ]; then
        echo "✗ $INPUT missing"
        exit 1
    fi
    if [ ! -f "$EXAMPLE" ]; then
        echo "✗ $EXAMPLE missing"
        exit 1
    fi
done

echo "✓ All 12 day files present"

# Check if Zig is installed
if command -v zig &> /dev/null; then
    ZIG_VERSION=$(zig version)
    echo "✓ Zig installed: $ZIG_VERSION"
    
    # Try to build
    echo ""
    echo "Testing build system..."
    if zig build; then
        echo "✓ Build successful"
    else
        echo "✗ Build failed"
        exit 1
    fi
else
    echo "⚠ Zig not found - install Zig 0.15.2 to test builds"
fi

echo ""
echo "Project structure validation complete!"
