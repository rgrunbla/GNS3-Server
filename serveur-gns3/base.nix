{ pkgs, lib, nixos-generators, buildEnv, ... }:

let
  baseConfig = {
    system.stateVersion = "24.05";

    services.gns3-server = {
      enable = true;
      settings = {
        "Server" = {
          "host" = "0.0.0.0";
          "port" = 3080;
        };
      };
      dynamips = {
        enable = true;
      };
      vpcs = {
        enable = true;
      };
      ubridge = {
        enable = true;
      };
    };

    systemd.services.gns3-server.path = [pkgs.qemu];
    networking.firewall.enable = false;

    users.users.root.password = "root";
    services.getty.autologinUser = lib.mkDefault "root";

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.settings.PermitRootLogin = "yes";

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
      # By default, not automatically configure any IPv6 addresses.
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.all.autoconf" = 0;
      "net.ipv6.conf.all.use_tempaddr" = 0;
    };

    i18n.defaultLocale = "fr_FR.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "fr"; # keyMap = "fr-bepo";
    };

    environment.systemPackages = with pkgs; [
      tcpdump
      tmux
      bgpdump
      bridge-utils
      ripgrep
      htop
      qemu
      mtr
      traceroute
    ];
    virtualisation.docker.enable = true;
    virtualisation.libvirtd.enable = true;
  };

  hostConfig = baseConfig // {
/*     virtualbox = {
      memorySize = 4000;
      params = {
        nic1 = "bridged";
        nictype1 = "82540EM";
        nic-property1 = "network=wlo1";
        nic2 = "bridged";
        nictype2 = "82540EM";
        nic-property2 = "network=wlo1";
      };
    }; */

    virtualisation = {
      forwardPorts =
        [
          { from = "host"; host.port = 3080; guest.port = 3080; }
        ];
        memorySize = 4096;
    };
  };

in
nixos-generators.nixosGenerate
{
  system = "x86_64-linux";
  specialArgs = {
    diskSize = "8192";
  };
  modules = [ hostConfig ];
  format = "vm"; #virtualbox
}

