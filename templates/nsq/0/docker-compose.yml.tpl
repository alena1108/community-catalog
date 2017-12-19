nsqlookupd01:
  image: nsqio/nsq
  command: /nsqlookupd
nsqlookupd02:
  image: nsqio/nsq
  command: /nsqlookupd
nsqlookupd03:
  image: nsqio/nsq
  command: /nsqlookupd
nsqd:
  image: nsqio/nsq
  command:
  - /bin/sh
  - -c
  - nsqd --data-path=/data --lookupd-tcp-address=nsqlookupd01:4160 --lookupd-tcp-address=nsqlookupd02:4160 --lookupd-tcp-address=nsqlookupd03:4160 -broadcast-address=$$HOSTNAME
  labels:
      io.rancher.scheduler.affinity:host_label_soft: nsqd=true
      io.rancher.scheduler.affinity:container_label_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
      io.rancher.sidekicks: data
      io.rancher.container.hostname_override: container_name
  volumes_from:
  - data
nsqadmin:
  image: nsqio/nsq
  command: /nsqadmin --lookupd-http-address=nsqlookupd01:4161 --lookupd-http-address=nsqlookupd02:4161 --lookupd-http-address=nsqlookupd03:4161
nsq-lb:
  image: rancher/lb-service-haproxy:v0.7.9
  ports:
  - 4150:4150/tcp
  - 4151:4151/tcp
  - 4171:4171/tcp
  labels:
    io.rancher.container.agent.role: environmentAdmin
    io.rancher.container.create_agent: 'true'
    io.rancher.scheduler.global: 'true'
data:
  image: busybox
  command: /bin/true
  net: none
  volumes:
  - /data
  labels:
    io.rancher.container.start_once: 'true'
