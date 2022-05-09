{ stdenv
, fetchurl
, buildPythonPackage
, fetchFromGitHub
, python
, wrapPython
, unzip
, callPackage
, bootstrapped-pip
, lib
, pipInstallHook
, setuptoolsBuildHook
}:

let
  pname = "setuptools";
  version = "51.3.3";

  bootstrap = fetchurl {
    url = "https://raw.githubusercontent.com/pypa/setuptools/v52.0.0/bootstrap.py";
    sha256 = "sha256-HzhlnJvMskBfb3kVnYltdnjS63wt1GWd0RK+VQqrJQ8=";
  };

  # Create an sdist of setuptools
  sdist = stdenv.mkDerivation rec {
    name = "${pname}-${version}-sdist.tar.gz";

    src = fetchFromGitHub {
      owner = "pypa";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-eunDKb4Rhk/nPBTxQYOCmS41wK4DZuCs+WGxo2FnUAQ=";
      name = "${pname}-${version}-source";
    };

    patches = [
      ./tag-date.patch
    ];

    buildPhase = ''
      cp ${bootstrap} bootstrap.py
      ${python.pythonForBuild.interpreter} bootstrap.py
      ${python.pythonForBuild.interpreter} setup.py sdist --formats=gztar
      # Here we untar the sdist and retar it in order to control the timestamps
      # of all the files included
      tar -xzf dist/${pname}-${version}.post0.tar.gz -C dist/
      tar -czf dist/${name} -C dist/ --mtime="@$SOURCE_DATE_EPOCH" --sort=name ${pname}-${version}.post0
    '';

    installPhase = ''
      echo "Moving sdist..."
      mv dist/${name} $out
    '';
  };
in buildPythonPackage rec {
  inherit pname version;
  # Because of bootstrapping we don't use the setuptoolsBuildHook that comes with format="setuptools" directly.
  # Instead, we override it to remove setuptools to avoid a circular dependency.
  # The same is done for pip and the pipInstallHook.
  format = "other";

  src = sdist;

  nativeBuildInputs = [
    bootstrapped-pip
    (pipInstallHook.override{pip=null;})
    (setuptoolsBuildHook.override{setuptools=null; wheel=null;})
  ];

  preBuild = lib.strings.optionalString (!stdenv.hostPlatform.isWindows) ''
    export SETUPTOOLS_INSTALL_WINDOWS_SPECIFIC_FILES=0
  '';

  pipInstallFlags = [ "--ignore-installed" ];

  # Adds setuptools to nativeBuildInputs causing infinite recursion.
  catchConflicts = false;

  # Requires pytest, causing infinite recursion.
  doCheck = false;

  meta = with lib; {
    description = "Utilities to facilitate the installation of Python packages";
    homepage = "https://pypi.python.org/pypi/setuptools";
    license = with licenses; [ psfl zpl20 ];
    platforms = python.meta.platforms;
    priority = 10;
  };
}
