{...}:
{
  networking.extraHosts = ''
    127.0.0.1 curry
    10.1.0.25 itp-dc1

    10.253.18.100 k0-0
    10.253.18.100 itp-registry itp-registry.local
    10.253.18.100 dashboard.k0.local
    10.253.18.100 gitlab.k0.local registry.k0.local minio.k0.local
    10.253.18.100 prometheus.k0.local alertmanager.k0.local pushgateway.k0.local
    10.253.18.100 sentry.k0.local
    10.253.18.100 grafana.k0.local
    10.253.18.100 baywash.k0.local
    10.253.18.100 portal-staging.arkiv-troms.local
    10.253.18.100 portal-production.arkiv-troms.local

    10.253.18.109 k1-0
    10.253.18.109 dashboard.k1.local
    10.253.18.109 gitlab.k1.local registry.k1.local minio.k1.local
  '';
}
