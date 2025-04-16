{ lib, stdenv, dpkg, makeWrapper, coreutils, ghostscript, gnugrep, gnused, which, perl }:

stdenv.mkDerivation rec {
  pname = "mfcj995dwcupswrapper";
  version = "1.0.5-0";

  src = ./mfcj995dwpdrv-1.0.5-0.i386.deb;

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = ''
    dpkg-deb -x $src $out
  '';

  installPhase = ''
    # Find the printer model directory
    PRINTER_MODEL="mfcj995dw"
    if [ ! -d "$out/opt/brother/Printers/$PRINTER_MODEL" ]; then
      # Try to find the actual directory
      PRINTER_DIR=$(find $out/opt/brother/Printers -mindepth 1 -maxdepth 1 -type d | head -1 || echo "")
      if [ -z "$PRINTER_DIR" ]; then
        echo "Error: Could not find printer directory in the .deb package"
        find $out -type d | sort
        exit 1
      fi
      PRINTER_MODEL=$(basename "$PRINTER_DIR")
      echo "Found printer model directory: $PRINTER_MODEL"
    fi
    
    BASEDIR="$out/opt/brother/Printers/$PRINTER_MODEL"
    echo "Base directory: $BASEDIR"
    
    # Create necessary directories
    mkdir -p $out/lib/cups/filter/
    mkdir -p $out/share/cups/model/Brother/

    # Find and copy the PPD file - check multiple locations
    PPD_FILE=""
    if [ -d "$BASEDIR/cupswrapper" ]; then
      PPD_FILE=$(find "$BASEDIR/cupswrapper" -name "*.ppd" | head -1 || echo "")
    fi
    if [ -z "$PPD_FILE" ] && [ -d "$BASEDIR/inf" ]; then
      PPD_FILE=$(find "$BASEDIR/inf" -name "*.ppd" | head -1 || echo "")
    fi
    if [ -z "$PPD_FILE" ]; then
      PPD_FILE=$(find "$BASEDIR" -name "*.ppd" | head -1 || echo "")
    fi

    if [ -n "$PPD_FILE" ]; then
      echo "Found PPD file: $PPD_FILE"
      cp -v "$PPD_FILE" $out/share/cups/model/Brother/
    else
      echo "Warning: No PPD file found!"
      find $BASEDIR -type f | grep -i "ppd"
    fi
    
    # Find and create the filter
    FILTER_FILE=""
    if [ -d "$BASEDIR/lpd" ]; then
      FILTER_FILE=$(find "$BASEDIR/lpd" -name "filter*" | head -1 || echo "")
    fi
    if [ -z "$FILTER_FILE" ]; then
      FILTER_FILE=$(find "$BASEDIR" -name "filter*" | head -1 || echo "")
    fi

    if [ -n "$FILTER_FILE" ]; then
      echo "Found filter file: $FILTER_FILE"
      if [ -x "$FILTER_FILE" ]; then
        echo "Filter is executable"
        ln -sf "$FILTER_FILE" $out/lib/cups/filter/brother_lpdwrapper_$PRINTER_MODEL
        
        # Wrap the filter
        wrapProgram $out/lib/cups/filter/brother_lpdwrapper_$PRINTER_MODEL \
          --prefix PATH ":" ${lib.makeBinPath [ coreutils ghostscript gnugrep gnused which perl ]}
      else
        echo "Filter found but not executable, making it executable:"
        chmod +x "$FILTER_FILE"
        ln -sf "$FILTER_FILE" $out/lib/cups/filter/brother_lpdwrapper_$PRINTER_MODEL
        
        # Wrap the filter
        wrapProgram $out/lib/cups/filter/brother_lpdwrapper_$PRINTER_MODEL \
          --prefix PATH ":" ${lib.makeBinPath [ coreutils ghostscript gnugrep gnused which perl ]}
      fi
    else
      echo "Warning: No filter file found!"
      find $BASEDIR -type f | grep -i "filter"
    fi

    # Check for other executables and wrap them
    for exe in $(find $BASEDIR -type f -executable); do
      if [ -f "$exe" ] && [ "$exe" != "$FILTER_FILE" ]; then
        echo "Wrapping executable: $exe"
        wrapProgram "$exe" \
          --prefix PATH ":" ${lib.makeBinPath [ coreutils ghostscript gnugrep gnused which perl ]}
      fi
    done

    # Print what we've found for debugging
    echo "Finished installation phase. Contents of directories:"
    echo "Contents of $out/lib/cups/filter/:"
    ls -la $out/lib/cups/filter/ || echo "Directory empty or not found"
    echo "Contents of $out/share/cups/model/Brother/:"
    ls -la $out/share/cups/model/Brother/ || echo "Directory empty or not found"
  '';

  meta = with lib; {
    description = "Brother MFC-J995DW CUPS wrapper driver";
    homepage = "https://support.brother.com/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
