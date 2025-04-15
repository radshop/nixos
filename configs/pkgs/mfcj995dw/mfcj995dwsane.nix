{ lib, stdenv, fetchurl, dpkg, makeWrapper, coreutils, udev }:

stdenv.mkDerivation rec {
  pname = "mfcj995dwsane";
  version = "4.0.0-1";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103946/mfcj995dwsane-${version}.i386.deb";
    sha256 = ""; # Replace with actual hash
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = ''
    dpkg-deb -x $src $out
  '';

  installPhase = ''
    mkdir -p $out/etc/sane.d/dll.d
    mkdir -p $out/lib/udev/rules.d
    
    # Create SANE configuration
    echo "brother5" > $out/etc/sane.d/dll.d/brother5.conf
    cp -v $out/opt/brother/scanner/brscan5/brsanenetdevice5.cfg $out/etc/sane.d/
    
    # Create udev rules for scanner detection
    cp -v $out/opt/brother/scanner/brscan5/udev-rules/69-brscan5.rules $out/lib/udev/rules.d/
    
    # Fix library path
    mkdir -p $out/lib/sane
    ln -s $out/opt/brother/scanner/brscan5/libbrscandec5.so.1.0.0 $out/lib/sane/
    ln -s $out/opt/brother/scanner/brscan5/libbrcolm5.so.1.0.0 $out/lib/sane/
    ln -s $out/opt/brother/scanner/brscan5/libbrscandec5.so.1.0.0 $out/lib/libbrscandec5.so.1
    ln -s $out/opt/brother/scanner/brscan5/libbrcolm5.so.1.0.0 $out/lib/libbrcolm5.so.1
    
    # Wrap the executables
    wrapProgram $out/opt/brother/scanner/brscan5/brsaneconfig5 \
      --prefix PATH ":" ${lib.makeBinPath [ coreutils ]}
  '';

  meta = with lib; {
    description = "Brother MFC-J995DW SANE scanner driver";
    homepage = "https://support.brother.com/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ]; # Add your name if you wish
  };
}
