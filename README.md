# clickhouse-metrics-grafana (demo stand)

Show Clickhouse grafana dashboard with graphite storage:
- https://clickhouse.tech/docs/en/operations/server_settings/settings/#server_settings-graphite for export metrics via graphite
- https://github.com/lomik/graphite-clickhouse for store metrics values back to clickhouse
- adapted https://grafana.com/grafana/dashboards/882 for using name conversions used by Clickhouse Server

## Installation instructions for Vagrant (ubuntu 16.04 based)

Run
```
vagrant plugin install vagrant-hostmanager
vagrant up --provision
```

Open http://local.grafana.clickhouse.pro:3000/ and view grafana dashboards
