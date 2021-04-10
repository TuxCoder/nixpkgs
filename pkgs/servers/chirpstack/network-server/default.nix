{ lib, stdenv, buildGoModule, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "chirpstack-network-server";
  version = "3.12.3";
  src = builtins.fetchurl {
    name = "${pname}-src";
    url = "https://artifacts.chirpstack.io/downloads/chirpstack-network-server/chirpstack-network-server_3.12.3_linux_amd64.tar.gz";
    sha256 = "sha256:02n3n1ksb63agi79z1mxl5v24s4dk3k6cizf5pzz3486dgbs0lpm";
  };

  unpackPhase = ''
    tar xzf $src
  '';

  installPhase = ''
    install -m755 -D chirpstack-network-server $out/bin/chirpstack-network-server
  '';


#buildGoModule rec {
# pname = "chirpstack-network-server";
# version = "3.12.3";
# src = fetchFromGitHub {
#   #rev = "v${version}";
#   rev = "1a7ed28f5293d124029093cbb96821e5b9037bc9";
#   owner = "brocaar";
#   repo = "chirpstack-network-server";
#   sha256 = "sha256:13ppnxkk1ma0xj26jbgrvka2942wxwcwdk1ydzpc5v1hd5ya69sg";
# };
# subPackages = [ "cmd/chirpstack-network-server" ];
# vendorSha256 = "sha256:0cj4dbldyf6s0xz6zyrwk7fghhlw7h4z6vgmwl0y69qzvkl3wdry";

  meta = with lib; {
    description = "ChirpStack Network Server is an open-source LoRaWAN network-server, part of ChirpStack. It is responsible for handling (and de-duplication) of uplink data received by the gateway(s) and the scheduling of downlink data transmissions.";
    license = licenses.mit;
    homepage = "https://www.chirpstack.io";
    maintainers = with maintainers; [  ];
    platforms = platforms.linux;
  };
}

