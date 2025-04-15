{ lib, stdenv, fetchurl, dpkg, makeWrapper, coreutils, ghostscript, gnugrep, gnused, which, perl }:

stdenv.mkDerivation rec {
  pname = "mfcj995dwcupswrapper";
  version = "4.0.0-1";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103948/mfcj995dwpdrv-${version}.i386.deb";
    sha256 = ""; # You'll need to replace this with the actual hash
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = ''
    dpkg-deb -x $src $out
  '';

  installPhase = ''
    basedir=$out/opt/brother/Printers/mfcj995dw
    mkdir -p $out/lib/cups/filter/
    mkdir -p $out/share/cups/model/Brother/

    substituteInPlace $basedir/cupswrapper/brother_mfcj995dw_printer_en.ppd \
      --replace /opt $out/opt
    
    cp -v $basedir/cupswrapper/brother_mfcj995dw_printer_en.ppd $out/share/cups/model/Brother/
    
    # Create the cups filter wrapper
    mkdir -p $out/lib/cups/filter
    ln -sf $basedir/lpd/filtermfcj995dw $out/lib/cups/filter/brother_lpdwrapper_mfcj995dw

    wrapProgram $basedir/lpd/filtermfcj995dw \
      --prefix PATH ":" ${lib.makeBinPath [ coreutils ghostscript gnugrep gnused which perl ]}
  '';

  meta = with lib; {
    description = "Brother MFC-J995DW CUPS wrapper driver";
    homepage = "https://support.brother.com/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ]; # Add your name if you wish
  };
}
