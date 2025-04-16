{ lib, stdenv, fetchurl, dpkg, makeWrapper, coreutils, ghostscript, gnugrep, gnused, which, a2ps, file }:

stdenv.mkDerivation rec {
  pname = "mfcj995dwlpr";
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
    mkdir -p $out/lib/cups/filter/
    mkdir -p $out/share/cups/model/Brother/

    cp -v $out/opt/brother/Printers/mfcj995dw/cupswrapper/brother_mfcj995dw_printer_en.ppd $out/share/cups/model/Brother/
    ln -sv $out/opt/brother/Printers/mfcj995dw/lpd/filtermfcj995dw $out/lib/cups/filter/brother_lpdwrapper_mfcj995dw

    wrapProgram $out/opt/brother/Printers/mfcj995dw/lpd/filtermfcj995dw \
      --prefix PATH ":" ${lib.makeBinPath [ coreutils ghostscript gnugrep gnused which a2ps file ]}
  '';

  meta = with lib; {
    description = "Brother MFC-J995DW CUPS driver";
    homepage = "https://support.brother.com/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ]; # Add your name if you wish
  };
}
