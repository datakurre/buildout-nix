{ lib, buildPythonPackage, fetchPypi, pip, wheel }:

buildPythonPackage rec {
  pname = "zc.buildout";
  version = "3.0.0rc3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-rAgiaA7493XB73aui7NFmVtkh9r1P7LoXVRXXHX4caE=";
  };

  propagatedBuildInputs = [ pip wheel ];

  patches = [ ./nix.patch ];

  meta = with lib; {
    homepage = "http://www.buildout.org";
    description = "A software build and configuration system";
    license = licenses.zpl21;
    maintainers = [ maintainers.goibhniu ];
  };
}
