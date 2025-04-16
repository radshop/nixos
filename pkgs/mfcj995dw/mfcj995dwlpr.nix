{ lib, stdenv, dpkg, makeWrapper, coreutils, ghostscript, gnugrep, gnused, which, a2ps, file }:

stdenv.mkDerivation rec {
  pname = "mfcj995dwlpr";
  version = "1.0.5-0"; # Update with correct version if needed

  # Use a local file
  src = ./mfcj995dwpdrv-1.0.5-0.i386.deb; # Adjust filename as needed

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = ''
    dpkg-deb -x $src $out
  '';

  installPhase = ''
    # Define the base directory where the printer files are located
    # This might need adjustment based on the actual structure in the .deb
    PRINTER_MODEL="mfcj995dw"
    if [ ! -d "$out/opt/brother/Printers/$PRINTER_MODEL" ]; then
      # Try to find the actual directory
      PRINTER_DIR=$(find $out/opt/brother/Printers -mindepth 1 -maxdepth 1 -type d | head -1)
      if [ -z "$PRINTER_DIR" ]; then
        echo "Error: Could not find printer directory in the .deb package"
        exit 1
      fi
      PRINTER_MODEL=$(basename "$PRINTER_DIR")
      echo "Found printer model directory: $PRINTER_MODEL"
    fi
    
    BASEDIR="$out/opt/brother/Printers/$PRINTER_MODEL"
    
    mkdir -p $out/lib/cups/filter/
    mkdir -p $out/share/cups/model/Brother/

    # Find and copy the PPD file
    PPD_FILE=$(find $BASEDIR -name "*.ppd" | head -1)
    if [ -n "$PPD_FILE" ]; then
      cp -v "$PPD_FILE" $out/share/cups/model/Brother/
    else
      echo "Warning: No PPD file found!"
    fi

    # Find and link the filter
    FILTER_FILE=$(find $BASEDIR -name "filter*" | head -1)
    if [ -n "$FILTER_FILE" ]; then
      ln -sv "$FILTER_FILE" $out/lib/cups/filter/brother_lpdwrapper_$PRINTER_MODEL
    else
      echo "Warning: No filter file found!"
    fi

    # Wrap executables if they exist
    for exe in $(find $BASEDIR -type f -executable); do
      if [ -f "$exe" ]; then
        wrapProgram "$exe" \
          --prefix PATH ":" ${lib.makeBinPath [ coreutils ghostscript gnugrep gnused which a2ps file ]}
      fi
    done
  '';

  meta = with lib; {
    description = "Brother MFC-J995DW CUPS driver";
    homepage = "https://support.brother.com/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
