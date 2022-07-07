#!/bin/bash

SYNH(){
	if [[ -z `ps -o pid= -p $nodepid` ]]
	then
		cd /
		echo ===================================================================
		echo ===Нода не работает, перезапускаю...Node not working, restart...===
		echo ===================================================================
		rm ./nohup.out
		rm ./nohup.err
		nohup  $binary start >nohup.out 2>nohup.err </dev/null &  nodepid=`echo $!`
		echo $nodepid
		sleep 5
		curl -s localhost:26657/status
		synh=`curl -s localhost:26657/status | jq .result.sync_info.catching_up`
		echo $synh
	else
		cd /
		echo =================================
		echo ===Нода работает.Node working.===
		echo =================================
		curl -s localhost:26657/status
		tail ./nohup.out
		tail ./nohup.err
		synh=`curl -s localhost:26657/status | jq .result.sync_info.catching_up`
		cat /root/$folder/config/priv_validator_key.json
		echo $nodepid
		echo $synh
	fi
}
MONIKER=state_sync_on_AKASH
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
(echo ${my_root_password}; echo ${my_root_password}) | passwd root
service ssh restart
sleep 5
ver="1.18.1" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
git clone $gitrep && cd $gitfold
echo $vers
sleep 5
git checkout $vers
make install
mv ~/go/bin/$binary /usr/local/bin/$binary
$binary version
sleep 5
#=======init ноды==========
echo =INIT=
$binary init "$MONIKER" --chain-id $chain
sleep 10
#==========================
#=============СКАЧИВАЕМ GENESIS И ADDRBOOK ============
wget -O $HOME/$folder/config/genesis.json $genesis
sha256sum ~/$folder/config/genesis.json
cd && cat $folder/data/priv_validator_state.json
echo ==========================
rm $HOME/$folder/config/addrbook.json
wget -O $HOME/$folder/config/addrbook.json $addrbook
echo ==========================
#=======================================================

#-------------НАСТРАИВАЕМ CONFIG.TOML И APP.TOML-------------------
$binary config chain-id $chain
echo $PEER
sleep 5
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$denom\"/;" $HOME/$folder/config/app.toml
sleep 1
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEED\"/;" $HOME/$folder/config/config.toml
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEER\"/;" $HOME/$folder/config/config.toml
sed -i.bak -e "s_"tcp://127.0.0.1:26657"_"tcp://0.0.0.0:26657"_;" $HOME/$folder/config/config.toml
pruning="custom" && \
pruning_keep_recent="5" && \
pruning_keep_every="1000" && \
pruning_interval="50" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$folder/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$folder/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$folder/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$folder/config/app.toml

snapshot_interval="1000" && \
sed -i.bak -e "s/^snapshot-interval *=.*/snapshot-interval = \"$snapshot_interval\"/" $HOME/$folder/config/app.toml

#===========ЗАПУСК НОДЫ============

echo =Run node...=
cd /
nohup  $binary start >nohup.out 2>nohup.err </dev/null &  nodepid=`echo $!`
echo $nodepid
source $HOME/.bashrc
sleep 20
synh=`curl -s localhost:26657/status | jq .result.sync_info.catching_up`
echo $synh
tail ./nohup.out
tail ./nohup.err
sleep 2
for ((;;))
do
SYNH
date
sleep 5m
wget -qO- eth0.me
done
sleep infinity
