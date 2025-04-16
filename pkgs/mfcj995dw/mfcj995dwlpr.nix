{ lib, stdenv, dpkg, makeWrapper, coreutils, ghostscript, gnugrep, gnused, which, a2ps, file }:

stdenv.mkDerivation rec {
  pname = "mfcj995dwlpr";
  version = "1.0.5-0";

  src = ./mfcj995dwpdrv-1.0.5-0.i386.deb;

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = ''
    dpkg-deb -x $src $out
  '';

  installPhase = ''
    # List contents of extracted package
    echo "Contents of the extracted package:"
    find $out -type d | sort | head -20
    
    # Find the printer model directory
    PRINTER_MODEL="mfcj995dw"
    if [ ! -d "$out/opt/brother/Printers/$PRINTER_MODEL" ]; then
      # Try to find the actual directory
      PRINTER_DIR=$(find $out/opt/brother/Printers -mindepth 1 -maxdepth 1 -type d | head -1 || echo "")
      if [ -z "$PRINTER_DIR" ]; then
        echo "Error: Could not find printer directory in the .deb package"
        exit 1
      fi
      PRINTER_MODEL=$(basename "$PRINTER_DIR")
      echo "Found printer model directory: $PRINTER_MODEL"
    fi
    
    BASEDIR="$out/opt/brother/Printers/$PRINTER_MODEL"
    echo "Base directory: $BASEDIR"
    
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
    
    # Find and link the filter
    FILTER_FILE=""
    if [ -d "$BASEDIR/lpd" ]; then
      FILTER_FILE=$(find "$BASEDIR/lpd" -name "filter*" | head -1 || echo "")
    fi
    if [ -z "$FILTER_FILE" ]; then
      FILTER_FILE=$(find "$BASEDIR" -name "filter*" | head -1 || echo "")
    fi

    if [ -n "$FILTER_FILE" ]; then
      echo "Found filter file: $FILTER_FILE"
      if [ ! -x "$FILTER_FILE" ]; then
        echo "Making filter executable"
        chmod +x "$FILTER_FILE"
      fi
      ln -sv "$FILTER_FILE" $out/lib/cups/filter/brother_lpdwrapper_$PRINTER_MODEL
    else
      echo "Warning: No filter file found!"
      find $BASEDIR -type f | grep -i "filter"
    fi

    # Wrap all executables
    echo "Finding and wrapping executables..."
    for exe in $(find $BASEDIR -type f); do
      if [ -f "$exe" ] && [ -x "$exe" ]; then
        echo "Wrapping executable: $exe"
        wrapProgram "$exe" \
          --prefix PATH ":" ${lib.makeBinPath [ coreutils ghostscript gnugrep gnused which a2ps file ]}
      fi
    done
    
    # Make sure the filter is executable
    if [ -f "$out/lib/cups/filter/brother_lpdwrapper_$PRINTER_MODEL" ]; then
      chmod +x "$out/lib/cups/filter/brother_lpdwrapper_$PRINTER_MODEL"
    fi
    
    # Print the results for debugging
    echo "Contents of $out/lib/cups/filter:"
    ls -la $out/lib/cups/filter/ || echo "Directory empty or not found"
    echo "Contents of $out/share/cups/model/Brother:"
    ls -la $out/share/cups/model/Brother/ || echo "Directory empty or not found"
  '';

  meta = with lib; {
    description = "Brother MFC-J995DW CUPS driver";
    homepage = "https://support.brother.com/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
