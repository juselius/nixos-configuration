{ pkgs, config, ... }:
let
  cfg = config.customize;
in
{
  networking.extraHosts = ''
    10.1.62.2 stokes stokes.hpc.local stokes.regnekraft.io

    10.1.61.200 mds0-0 mds0-0.hpc.local

    10.1.61.201 c0-0 c0-0.hpc.local stokes-intern.hpc.local
    10.1.61.202 c0-1 c0-1.hpc.local
    10.1.61.203 c0-2 c0-2.hpc.local
    10.1.61.204 c0-3 c0-3.hpc.local
    10.1.61.205 c0-4 c0-4.hpc.local
    10.1.61.206 c0-5 c0-5.hpc.local
    10.1.61.207 c0-6 c0-6.hpc.local
    10.1.61.208 c0-7 c0-7.hpc.local
    10.1.61.209 c0-8 c0-8.hpc.local

    10.1.2.74 yoneda yoneda.itpartner.intern
  '';
}
