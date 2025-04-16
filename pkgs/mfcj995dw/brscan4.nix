{ lib, stdenv, dpkg, makeWrapper, coreutils, udev }:

stdenv.mkDerivation rec {
  pname = "brscan4";
  version = "0.4.11-1";

  src = ./brscan4-0.4.11-1.amd64.deb;

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = ''
    dpkg-deb -x $src $out
  '';

  installPhase = ''
    # Debug output - check what we have
    echo "Contents of extracted package:"
    find $out -type d | sort | head -20
    
    mkdir -p $out/etc/sane.d/dll.d
    mkdir -p $out/lib/udev/rules.d
    mkdir -p $out/lib/sane
    
    # Create SANE configuration
    echo "brother4" > $out/etc/sane.d/dll.d/brother4.conf
    
    # Check if the brscan4 directory exists
    if [ ! -d "$out/opt/brother/scanner/brscan4" ]; then
      echo "Warning: brscan4 directory not found. Checking for other scanner directories..."
      find $out/opt -type d | grep -i "scanner"
      
      # Try to find the brscan directory
      BRSCAN_DIR=$(find $out/opt -path "*/scanner/*" -type d | head -1 || echo "")
      if [ -z "$BRSCAN_DIR" ]; then
        echo "Error: Could not find brscan directory in the package"
        exit 1
      fi
      echo "Found scanner directory: $BRSCAN_DIR"
      BRSCAN_DIR=$(dirname "$BRSCAN_DIR")
    else
      BRSCAN_DIR="$out/opt/brother/scanner/brscan4"
    fi
    
    echo "Using brscan directory: $BRSCAN_DIR"
    
    # Copy network configuration if available
    if [ -f "$BRSCAN_DIR/brsanenetdevice4.cfg" ]; then
      cp -v "$BRSCAN_DIR/brsanenetdevice4.cfg" $out/etc/sane.d/
    else
      echo "Warning: brsanenetdevice4.cfg not found"
      find $BRSCAN_DIR -name "*.cfg"
    fi
    
    # Copy udev rules if available
    UDEV_RULES=""
    if [ -d "$BRSCAN_DIR/udev-rules" ]; then
      UDEV_RULES=$(find "$BRSCAN_DIR/udev-rules" -name "*.rules" | head -1 || echo "")
    fi
    if [ -n "$UDEV_RULES" ]; then
      cp -v "$UDEV_RULES" $out/lib/udev/rules.d/
    else
      echo "Warning: No udev rules found"
      find $BRSCAN_DIR -name "*.rules"
    fi
    
    # Find and link library files
    echo "Finding library files..."
    for lib_file in $(find $BRSCAN_DIR -name "*.so*"); do
      if [ -f "$lib_file" ]; then
        base_name=$(basename "$lib_file")
        echo "Found library: $base_name, linking to $out/lib/sane/"
        ln -s "$lib_file" "$out/lib/sane/$base_name"
        
        # Create additional symlinks for major versions
        if [[ "$base_name" =~ ^libbrscandec.*\.so\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          major=$(echo "$base_name" | sed -E 's/^libbrscandec.*\.so\.([0-9]+)\..*/\1/')
          prefix=$(echo "$base_name" | sed -E 's/^(libbrscandec.*)\.so\..*/\1/')
          mkdir -p $out/lib
          echo "Creating symlink: $out/lib/$prefix.so.$major -> $lib_file"
          ln -s "$lib_file" "$out/lib/$prefix.so.$major"
        fi
        
        if [[ "$base_name" =~ ^libbrcolm.*\.so\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          major=$(echo "$base_name" | sed -E 's/^libbrcolm.*\.so\.([0-9]+)\..*/\1/')
          prefix=$(echo "$base_name" | sed -E 's/^(libbrcolm.*)\.so\..*/\1/')
          mkdir -p $out/lib
          echo "Creating symlink: $out/lib/$prefix.so.$major -> $lib_file"
          ln -s "$lib_file" "$out/lib/$prefix.so.$major"
        fi
      fi
    done
    
    # Find and wrap the brsaneconfig utility
    BRSANECONFIG=$(find $BRSCAN_DIR -name "brsaneconfig*" | head -1 || echo "")
    if [ -n "$BRSANECONFIG" ]; then
      echo "Found brsaneconfig: $BRSANECONFIG"
      if [ ! -x "$BRSANECONFIG" ]; then
        echo "Making brsaneconfig executable"
        chmod +x "$BRSANECONFIG"
      fi
      wrapProgram "$BRSANECONFIG" \
        --prefix PATH ":" ${lib.makeBinPath [ coreutils ]}
    else
      echo "Warning: brsaneconfig not found"
      find $BRSCAN_DIR -type f -executable
    fi
    
    # Print final configuration
    echo "Final SANE configuration:"
    echo "Contents of $out/etc/sane.d/dll.d:"
    ls -la $out/etc/sane.d/dll.d/
    echo "Contents of $out/lib/udev/rules.d:"
    ls -la $out/lib/udev/rules.d/
    echo "Contents of $out/lib/sane:"
    ls -la $out/lib/sane/
  '';

  meta = with lib; {
    description = "Brother brscan4 SANE scanner driver (supports MFC-J995DW)";
    homepage = "https://support.brother.com/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
