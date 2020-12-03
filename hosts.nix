{ pkgs, config, ... }:
let
  cfg = config.customize;
in
{
  networking.extraHosts = ''
    10.255.255.151 vortex vortex.itpartner.intern
    10.255.255.152 mds0-0 mds0-0.itpartner.intern

    10.101.0.1     c0-1
    10.101.0.2     c0-2
    10.101.0.3     c0-3
    10.101.0.4     c0-4
    10.101.0.5     c0-5
    10.101.0.6     c0-6
    10.101.0.7     c0-7
    10.101.0.8     c0-8

    10.101.1.1     ic0-1
    10.101.1.2     ic0-2
    10.101.1.3     ic0-3
    10.101.1.4     ic0-4
    10.101.1.5     ic0-5
    10.101.1.6     ic0-6
    10.101.1.7     ic0-7
    10.101.1.8     ic0-8
    10.1.2.74 yoneda yoneda.itpartner.intern
  '';
}
