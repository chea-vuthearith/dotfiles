{...}: {
  # AnyDesk LAN Discovery: multicast 239.255.102.18 on UDP 50001-50003.
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 50001;
      to = 50003;
    }
  ];
}
