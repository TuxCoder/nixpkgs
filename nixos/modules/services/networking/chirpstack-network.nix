{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.chirpstack-network;
  defaultUser = "chirpstack-network";

  format = pkgs.formats.toml {};

  configFile = format.generate "chirpstack-network-config.toml" (with cfg;  {
    general = {
      log_to_syslog = true;
    };
    postgresql = {
      dsn="postgresql://${postgresql.username}@${postgresql.host}/${postgresql.database}?sslmode=disable";
    };
    inherit redis network_server monitoring;
  });
in {
  ###### interface
  options = {
    services.chirpstack-network = {

      enable = mkEnableOption ''
        Enables Chirpstack Network Server, on http://localhost:TODO
        '';

      postgresql = {
        host = mkOption {
          type = types.str;
          default = "localhost";
          description = ''
            Postgresql hostname eg "localhost"
            '';
        };
        username = mkOption {
          type = types.str;
          default = "postgresql";
          description = ''
            Postgresql username
            '';
        };
        database = mkOption {
          type = types.str;
          default = "chirpstack_ns";
          description = ''
            Postgresql database name.
            '';
        };
      };
      redis = {

        server = mkOption {
          type = types.listOf types.str;
          default = [ "localhost:6379" ];
          description = ''
            Redis server list
            '';
        };
        password = mkOption {
          type = types.str;
          default = "";
          description = ''
            Redis password.
            '';
        };
      };

      network_server = {
        net_id = mkOption {
          type = types.str;
          default = "000000";
          description = ''
            net id
            '';
        };
        band = {
          name = mkOption {
            type = types.str;
            default = "EU868";
            description = ''
              LoraWAN band
              '';
          };
        };
        api = {
          bind = mkOption {
            type = types.str;
            default = "[::1]:8000";
            description = ''
              bind address
              '';
          };
        };
        network_settings = {
          extra_channels = mkOption {
            type = types.listOf  ( types.submodule {
              options = {
                frequency= mkOption {
                  type = types.int;
                  description = ''
                  '';
                };
                min_dr = mkOption {
                  type = types.int;
                  default= 0;
                  description = ''
                  '';
                };
                max_dr = mkOption {
                  type = types.int;
                  default = 5;
                  description = ''
                  '';
                };
              };
            });
            description = ''
              Extra channel configuration.

              Use this for LoRaWAN regions where it is possible to extend the by default
              available channels with additional channels (e.g. the EU band).
              The first 5 channels will be configured as part of the OTAA join-response
              (using the CFList field).
              The other channels (or channel / data-rate changes) will be (re)configured
              using the NewChannelReq mac-command.
            '';
          };
        };
        gateway = {
          backend = {
            type = mkOption {
              type = types.str;
              default = "mqtt";
              description = ''
                backend type, one of "mqtt", "amqp", "gcp_pub_sub", "azure_iot_hub"
                '';
            };
            mqtt = {
              server = mkOption {
                type = types.str;
                default = "tcp://localhost:1883";
                description = ''
                  mqtt server
                  '';
              };
              username = mkOption {
                type = types.str;
                default = "";
                description = ''
                  mqtt username
                  '';
              };
              password = mkOption {
                type = types.str;
                default = "";
                description = ''
                  mqtt password
                  '';
              };

            };
          };
        };
      };
      monitoring = {
        bind = mkOption {
          type = types.str;
          default = "[::]:9834";
          description = ''
            monitoring bind endpoint, IP:port
            '';
        };

        prometheus_endpoint = mkOption {
          type = types.bool;
          default = false;
          description = ''
            When set true, Prometheus metrics will be served at '/metrics'.
            '';
        };
      };



#     declarative = {
#       cert = mkOption {
#         type = types.nullOr types.str;
#         default = null;
#         description = ''
#           Path to users cert.pem file, will be copied into the chirpstack-network's
#           <literal>configDir</literal>
#         '';
#       };

#       key = mkOption {
#         type = types.nullOr types.str;
#         default = null;
#         description = ''
#           Path to users key.pem file, will be copied into the chirpstack-network's
#           <literal>configDir</literal>
#         '';
#       };

#       overrideDevices = mkOption {
#         type = types.bool;
#         default = true;
#         description = ''
#           Whether to delete the devices which are not configured via the
#           <literal>declarative.devices</literal> option.
#           If set to false, devices added via the webinterface will
#           persist but will have to be deleted manually.
#         '';
#       };

#       devices = mkOption {
#         default = {};
#         description = ''
#           Peers/devices which chirpstack-network should communicate with.
#         '';
#         example = {
#           bigbox = {
#             id = "7CFNTQM-IMTJBHJ-3UWRDIU-ZGQJFR6-VCXZ3NB-XUH3KZO-N52ITXR-LAIYUAU";
#             addresses = [ "tcp://192.168.0.10:51820" ];
#           };
#         };
#         type = types.attrsOf (types.submodule ({ name, ... }: {
#           options = {

#             name = mkOption {
#               type = types.str;
#               default = name;
#               description = ''
#                 Name of the device
#               '';
#             };

#             addresses = mkOption {
#               type = types.listOf types.str;
#               default = [];
#               description = ''
#                 The addresses used to connect to the device.
#                 If this is let empty, dynamic configuration is attempted
#               '';
#             };

#             id = mkOption {
#               type = types.str;
#               description = ''
#                 The id of the other peer, this is mandatory. It's documented at
#                 https://docs.chirpstack-network.net/dev/device-ids.html
#               '';
#             };

#             introducer = mkOption {
#               type = types.bool;
#               default = false;
#               description = ''
#                 If the device should act as an introducer and be allowed
#                 to add folders on this computer.
#               '';
#             };

#           };
#         }));
#       };

#       overrideFolders = mkOption {
#         type = types.bool;
#         default = true;
#         description = ''
#           Whether to delete the folders which are not configured via the
#           <literal>declarative.folders</literal> option.
#           If set to false, folders added via the webinterface will persist
#           but will have to be deleted manually.
#         '';
#       };

#       folders = mkOption {
#         default = {};
#         description = ''
#           folders which should be shared by chirpstack-network.
#         '';
#         example = literalExample ''
#           {
#             "/home/user/sync" = {
#               id = "syncme";
#               devices = [ "bigbox" ];
#             };
#           }
#         '';
#         type = types.attrsOf (types.submodule ({ name, ... }: {
#           options = {

#             enable = mkOption {
#               type = types.bool;
#               default = true;
#               description = ''
#                 share this folder.
#                 This option is useful when you want to define all folders
#                 in one place, but not every machine should share all folders.
#               '';
#             };

#             path = mkOption {
#               type = types.str;
#               default = name;
#               description = ''
#                 The path to the folder which should be shared.
#               '';
#             };

#             id = mkOption {
#               type = types.str;
#               default = name;
#               description = ''
#                 The id of the folder. Must be the same on all devices.
#               '';
#             };

#             label = mkOption {
#               type = types.str;
#               default = name;
#               description = ''
#                 The label of the folder.
#               '';
#             };

#             devices = mkOption {
#               type = types.listOf types.str;
#               default = [];
#               description = ''
#                 The devices this folder should be shared with. Must be defined
#                 in the <literal>declarative.devices</literal> attribute.
#               '';
#             };

#             versioning = mkOption {
#               default = null;
#               description = ''
#                 How to keep changed/deleted files with chirpstack-network.
#                 There are 4 different types of versioning with different parameters.
#                 See https://docs.chirpstack-network.net/users/versioning.html
#               '';
#               example = [
#                 {
#                   versioning = {
#                     type = "simple";
#                     params.keep = "10";
#                   };
#                 }
#                 {
#                   versioning = {
#                     type = "trashcan";
#                     params.cleanoutDays = "1000";
#                   };
#                 }
#                 {
#                   versioning = {
#                     type = "staggered";
#                     params = {
#                       cleanInterval = "3600";
#                       maxAge = "31536000";
#                       versionsPath = "/chirpstack-network/backup";
#                     };
#                   };
#                 }
#                 {
#                   versioning = {
#                     type = "external";
#                     params.versionsPath = pkgs.writers.writeBash "backup" ''
#                       folderpath="$1"
#                       filepath="$2"
#                       rm -rf "$folderpath/$filepath"
#                     '';
#                   };
#                 }
#               ];
#               type = with types; nullOr (submodule {
#                 options = {
#                   type = mkOption {
#                     type = enum [ "external" "simple" "staggered" "trashcan" ];
#                     description = ''
#                       Type of versioning.
#                       See https://docs.chirpstack-network.net/users/versioning.html
#                     '';
#                   };
#                   params = mkOption {
#                     type = attrsOf (either str path);
#                     description = ''
#                       Parameters for versioning. Structure depends on versioning.type.
#                       See https://docs.chirpstack-network.net/users/versioning.html
#                     '';
#                   };
#                 };
#               });
#             };

#             rescanInterval = mkOption {
#               type = types.int;
#               default = 3600;
#               description = ''
#                 How often the folders should be rescaned for changes.
#               '';
#             };

#             type = mkOption {
#               type = types.enum [ "sendreceive" "sendonly" "receiveonly" ];
#               default = "sendreceive";
#               description = ''
#                 Whether to send only changes from this folder, only receive them
#                 or propagate both.
#               '';
#             };

#             watch = mkOption {
#               type = types.bool;
#               default = true;
#               description = ''
#                 Whether the folder should be watched for changes by inotify.
#               '';
#             };

#             watchDelay = mkOption {
#               type = types.int;
#               default = 10;
#               description = ''
#                 The delay after an inotify event is triggered.
#               '';
#             };

#             ignorePerms = mkOption {
#               type = types.bool;
#               default = true;
#               description = ''
#                 Whether to propagate permission changes.
#               '';
#             };

#             ignoreDelete = mkOption {
#               type = types.bool;
#               default = false;
#               description = ''
#                 Whether to delete files in destination. See <link
#                 xlink:href="https://docs.chirpstack-network.net/advanced/folder-ignoredelete.html">
#                 upstream's docs</link>.
#               '';
#             };

#           };
#         }));
#       };
#     };

#     guiAddress = mkOption {
#       type = types.str;
#       default = "127.0.0.1:8384";
#       description = ''
#         Address to serve the GUI.
#       '';
#     };

      systemService = mkOption {
        type = types.bool;
        default = true;
        description = "Auto launch Chirpstack Network as a system service.";
      };

      user = mkOption {
        type = types.str;
        default = defaultUser;
        description = ''
          Chirpstack Network will be run under this user (user will be created if it doesn't exist.
          This can be your user name).
        '';
      };

      group = mkOption {
        type = types.str;
        default = defaultUser;
        description = ''
          Chirpstack Network will be run under this group (group will not be created if it doesn't exist.
          This can be your user name).
        '';
      };

#     all_proxy = mkOption {
#       type = with types; nullOr str;
#       default = null;
#       example = "socks5://address.com:1234";
#       description = ''
#         Overwrites all_proxy environment variable for the chirpstack-network process to
#         the given value. This is normaly used to let relay client connect
#         through SOCKS5 proxy server.
#       '';
#     };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/chirpstack-network";
        description = ''
          Path where config and persistant data is saved.
        '';
      };

#     configDir = mkOption {
#       type = types.path;
#       description = ''
#         Path where the settings and keys will exist.
#       '';
#       default =
#         let
#           nixos = config.system.stateVersion;
#           cond  = versionAtLeast nixos "19.03";
#         in cfg.dataDir + (optionalString cond "/.config/chirpstack-network");
#     };

      openDefaultPorts = mkOption {
        type = types.bool;
        default = false;
        example = literalExample "true";
        description = ''
          Open the default ports in the firewall:
            - TCP 22000 for transfers
            - UDP 21027 for discovery
          If multiple users are running chirpstack-network on this machine, you will need to manually open a set of ports for each instance and leave this disabled.
          Alternatively, if are running only a single instance on this machine using the default ports, enable this.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.chirpstack.network-server;
        defaultText = "pkgs.chirpstack.network-server";
        example = literalExample "pkgs.chirpstack.network-server";
        description = ''
          Chirpstack Network package to use.
        '';
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    networking.firewall = mkIf cfg.openDefaultPorts {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 21027 ];
    };

    systemd.packages = [ cfg.package ];

    users.users = mkIf (cfg.systemService && cfg.user == defaultUser) {
      ${defaultUser} =
        { group = cfg.group;
          home  = cfg.dataDir;
          createHome = true;
          uid = config.ids.uids.chirpstack-network;
          description = "Chirpstack Network daemon user";
        };
    };

    users.groups = mkIf (cfg.systemService && cfg.group == defaultUser) {
      ${defaultUser}.gid =
        config.ids.gids.chirpstack-network;
    };

    systemd.services = {
      chirpstack-network = mkIf cfg.systemService {
        description = "Chirpstack Network service";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Restart = "on-failure";
          User = cfg.user;
          Group = cfg.group;
          ExecStart = ''
            ${cfg.package}/bin/chirpstack-network-server --config ${configFile.outPath}
          '';
        };
      };
    };
  };
}
