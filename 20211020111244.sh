set -x
 
#  本脚本为127.0.0.1执行
 
#setup
tar zxf  docker-18.06.3-ce.tgz && mv docker/* /usr/bin/ && rm -rf docker/
 
#systemd config
cat >/etc/systemd/system/docker.service <<-EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
 
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
 
[Install]
WantedBy=multi-user.target
EOF
 
#start
chmod +x /etc/systemd/system/docker.service
systemctl daemon-reload && systemctl start docker && systemctl enable docker.service
 
#testing
systemctl status docker && docker -v
 
# 安装docker-compose
chmod 777 docker-compose-Linux-x86_64
 
sudo mv docker-compose-Linux-x86_64 /usr/bin/docker-compose
 
sudo chmod +x /usr/bin/docker-compose
 
docker-compose -v
