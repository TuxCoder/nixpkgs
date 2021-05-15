{ lib, stdenv }:
stdenv.mkDerivation rec {
  pname = "chirpstack-application-server";
  version = "3.14.0";
  src = builtins.fetchurl {
    name = "${pname}-src";
    url = "https://artifacts.chirpstack.io/downloads/chirpstack-application-server/chirpstack-application-server_${version}_linux_amd64.tar.gz";
    sha256 = "sha256:05xpf6nzf534k78ycq9prq8ryi9a0wvijl1pjn9llw2c2hfw77c9";
  };

  unpackPhase = ''
    tar xzf $src
  '';

  installPhase = ''
    install -m755 -D chirpstack-application-server $out/bin/chirpstack-application-server
  '';

  meta = with lib; {
    description = ''ChirpStack Application Server is an open-source LoRaWAN Application Server, part of the ChirpStack open-source LoRaWAN Network Server stack. It is responsible for the node "inventory" part of a LoRaWAN infrastructure, handling of received application payloads and the downlink application payload queue. It comes with a web-interface and API (RESTful JSON and gRPC) and supports authorization by using JWT tokens (optional). Received payloads are published over MQTT and payloads can be enqueued by using MQTT or the API.'';
    license = licenses.mit;
    homepage = "https://www.chirpstack.io";
    maintainers = with maintainers; [  ];
    platforms = platforms.linux;
  };
}

