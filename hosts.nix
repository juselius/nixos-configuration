{ ... }:
{
  networking.extraHosts = ''
    10.1.30.10 fs0-0 fs0-0.itpartner.intern
    10.1.30.10 fs1-0 fs1-0.itpartner.intern
    10.1.8.10  fs2-0 fs2-0.itpartner.intern

    10.1.30.80 psql1-0 psql1-0.itpartner.intern
    10.1.8.80 psql2-0 psql2-0.itpartner.intern

    10.1.8.50 k0-0 k0-0.itpartner.intern
    10.1.8.51 k0-1 k0-1.itpartner.intern
    10.1.8.52 k0-2 k0-2.itpartner.intern

    10.1.30.100 k1-0 k1-0.itpartner.intern
    10.1.30.101 k1-1 k1-1.itpartner.intern
    10.1.30.102 k1-2 k1-2.itpartner.intern
    10.1.30.103 k1-3 k1-3.itpartner.intern

    10.1.8.60 k2-0 k2-0.itpartner.intern
    10.1.8.61 k2-1 k2-1.itpartner.intern
    10.1.8.62 k2-2 k2-2.itpartner.intern
    10.1.8.63 k2-3 k2-3.itpartner.intern
    10.1.8.64 k2-4 k2-4.itpartner.intern

    10.1.62.2 stokes stokes.hpc.local

    10.1.61.100 frontend frontend.hpc.local
    10.1.61.101 c0-1 c0-1.hpc.local
    10.1.61.102 c0-2 c0-2.hpc.local
    10.1.61.103 c0-3 c0-3.hpc.local
    10.1.61.104 c0-4 c0-4.hpc.local
    10.1.61.105 c0-5 c0-5.hpc.local
    10.1.61.106 c0-6 c0-6.hpc.local
    10.1.61.107 c0-7 c0-7.hpc.local
    10.1.61.108 c0-8 c0-8.hpc.local

    10.1.61.80 mds0-0 mds0-0.hpc.local

    10.1.60.100 frontend.mgmt.hpc.local
    10.1.60.100 c0-0.mgmt.hpc.local
    10.1.60.101 c0-1.mgmt.hpc.local
    10.1.60.102 c0-2.mgmt.hpc.local
    10.1.60.103 c0-3.mgmt.hpc.local
    10.1.60.104 c0-4.mgmt.hpc.local
    10.1.60.105 c0-5.mgmt.hpc.local
    10.1.60.106 c0-6.mgmt.hpc.local
    10.1.60.107 c0-7.mgmt.hpc.local
    10.1.60.108 c0-8.mgmt.hpc.local

    10.1.60.80 mds0-0.mgmt.hpc.local
    10.1.60.81 vault-0.mgmt.hpc.local me4-0.mgmt.hpc.local
    10.1.60.82 vault-1.mgmt.hpc.local me4-1.mgmt.hpc.local
    10.1.60.10 ib-switch-0 ib-switch-0.mgmt.hpc.local

    10.1.8.100   minio.itpartner.no
    10.1.30.100  froydis.itpartner.no
    10.1.30.100  arkiv.ikat.local
    10.1.30.100  arkivist.itpartner.intern
    10.208.0.130 velferdskamera.hepro.no
  '';
}
