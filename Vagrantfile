# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_check_update = false

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = false

  config.vm.define :clickhouse_grafana do |clickhouse_grafana|
    clickhouse_grafana.vm.network "private_network", ip: "172.16.1.11"
    clickhouse_grafana.vm.host_name = "local-grafana-clickhouse-pro"
    clickhouse_grafana.hostmanager.aliases = [
        "local.grafana.clickhouse.pro",
    ]
    clickhouse_grafana.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false

      # Customize the amount of memory on the VM:
      vb.memory = "768"
    end

    clickhouse_grafana.vm.provision "shell", inline: <<-SHELL
      set -xeuo pipefail
      sysctl net.ipv6.conf.all.forwarding=1
      apt-get update
      apt-get install -y apt-transport-https software-properties-common jq
      # clickhouse
      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E0C56BD4
      add-apt-repository "deb http://repo.yandex.ru/clickhouse/deb/testing/ main/"

      # grafana
      curl -sSf https://packagecloud.io/gpg.key | apt-key add -
      add-apt-repository "deb https://packagecloud.io/grafana/stable/debian/ jessie main"

      # go-graphite
      wget -q -O- https://packagecloud.io/go-graphite/stable/gpgkey | apt-key add -
      curl -sSf "https://packagecloud.io/install/repositories/go-graphite/stable/config_file.list?os=ubuntu&dist=xenial&source=script" > /etc/apt/sources.list.d/go-graphite.list

      apt-get update

      apt-get install -y clickhouse-client clickhouse-server-common
      cp -fv /vagrant/clickhouse/config.xml /etc/clickhouse-server/config.xml
      cp -fv /vagrant/clickhouse/users.xml /etc/clickhouse-server/users.xml
      systemctl enable clickhouse-server
      systemctl restart clickhouse-server
      sleep 5
      cat /vagrant/carbon-clickhouse/create_tables.sql | clickhouse-client -m -n --echo


      apt-get install -y carbonapi
      mkdir -p /etc/carbonapi/
      cp -fv /vagrant/carbonapi/*.yaml /etc/carbonapi/
      systemctl enable carbonapi
      systemctl restart carbonapi

      wget -q -c -O /tmp/carbon-clickhouse_0.8.2_amd64.deb https://github.com/lomik/carbon-clickhouse/releases/download/v0.8.2/carbon-clickhouse_0.8.2_amd64.deb
      dpkg -i /tmp/carbon-clickhouse_0.8.2_amd64.deb
      cp -fv /vagrant/carbon-clickhouse/carbon-clickhouse.conf /etc/carbon-clickhouse/carbon-clickhouse.conf
      mkdir -p -m 0777 /var/lib/carbon-clickhouse
      systemctl enable carbon-clickhouse
      systemctl restart carbon-clickhouse

      wget -q -c -O /tmp/graphite-clickhouse_0.6.3_amd64.deb https://github.com/lomik/graphite-clickhouse/releases/download/v0.6.3/graphite-clickhouse_0.6.3_amd64.deb
      dpkg -i /tmp/graphite-clickhouse_0.6.3_amd64.deb
      cp -fv /vagrant/graphite-clickhouse/graphite-clickhouse.conf /etc/graphite-clickhouse/graphite-clickhouse.conf
      cp -fv /vagrant/graphite-clickhouse/rollup.xml /etc/graphite-clickhouse/rollup.xml
      mkdir -p -m 0777 /var/lib/graphite-clickhouse
      systemctl enable graphite-clickhouse
      systemctl restart graphite-clickhouse


      mkdir -p /var/lib/grafana/dashboards/
      mkdir -p /etc/grafana/provisioning/dashboards
      mkdir -p /etc/grafana/provisioning/datasources
      cp -fv /vagrant/grafana/*dashboard.json /var/lib/grafana/dashboards/
      # @TODO WTF? why download via wget and curl is broken?
      # wget -O /var/lib/grafana/dashboards/clickhouse_queries_dashboard.json https://grafana.com/api/dashboards/2515/revisions/2/download
      cp -fv /vagrant/grafana/*datasources.yaml /etc/grafana/provisioning/datasources/
      cp -fv /vagrant/grafana/*dashboards.yaml /etc/grafana/provisioning/dashboards/
      apt-get install -y grafana
      systemctl enable grafana-server
      grafana-cli plugins install vertamedia-clickhouse-datasource
      systemctl restart grafana-server


      clickhouse-client --echo -q "SELECT * FROM system.metrics"
      clickhouse-client --echo -q "SELECT * FROM system.asynchronous_metrics"
      clickhouse-client --echo -q "SELECT * FROM system.events"
      clickhouse-client --echo -q "SELECT database, table, SUM(bytes) as bytes, COUNT() as parts, SUM(rows) as rows FROM system.parts /* WHERE active = 1 */ GROUP BY database, table"


      echo "clickhouse-metrics-grafana PROVISIONING DONE, open http://local.grafana.clickhouse.pro:3000/ Good Luck ;)"
    SHELL
  end

end
