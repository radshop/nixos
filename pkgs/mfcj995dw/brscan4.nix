{ lib, stdenv, dpkg, makeWrapper, coreutils, udev }:

stdenv.mkDerivation rec {
  pname = "brscan4";
  version = "0.4.11-1";

  # Use the local file with the correct name
  src = ./brscan4-0.4.11-1.amd64.deb;

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = ''
    dpkg-deb -x $src $out
  '';

  installPhase = ''
    mkdir -p $out/etc/sane.d/dll.d
    mkdir -p $out/lib/udev/rules.d
    
    # Create SANE configuration
    echo "brother4" > $out/etc/sane.d/dll.d/brother4.conf
    
    # The exact paths might vary, so adjust these based on what's actually in the package
    if [ -f $out/opt/brother/scanner/brscan4/brsanenetdevice4.cfg ]; then
      cp -v $out/opt/brother/scanner/brscan4/brsanenetdevice4.cfg $out/etc/sane.d/
    fi
    
    # Create udev rules for scanner detection
    if [ -d $out/opt/brother/scanner/brscan4/udev-rules ]; then
      cp -v $out/opt/brother/scanner/brscan4/udev-rules/*.rules $out/lib/udev/rules.d/
    fi
    
    # Fix library path - adjust these paths based on what's actually in the package
    mkdir -p $out/lib/sane
    
    # Find the actual library files and create symlinks
    for lib in $(find $out/opt/brother/scanner/brscan4 -name "*.so*"); do
      base_name=$(basename $lib)
      ln -s $lib $out/lib/sane/$base_name
      
      # If this is a .so.X.Y.Z file, also create a .so.X symlink
      if [[ $base_name =~ libbrscandec4\.so\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        ln -s $lib $out/lib/libbrscandec4.so.1
      fi
      if [[ $base_name =~ libbrcolm4\.so\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        ln -s $lib $out/lib/libbrcolm4.so.1
      fi
    done
    
    # Wrap the executables
    if [ -f $out/opt/brother/scanner/brscan4/brsaneconfig4 ]; then
      wrapProgram $out/opt/brother/scanner/brscan4/brsaneconfig4 \
        --prefix PATH ":" ${lib.makeBinPath [ coreutils ]}
    fi
  '';

  meta = with lib; {
    description = "Brother brscan4 SANE scanner driver (supports MFC-J995DW)";
    homepage = "https://support.brother.com/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
