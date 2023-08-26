#!/bin/bash

# ~~~ EaglercraftX Server
# ~~~ >> smashed together YET AGAIN by ayunami2000
# ~~~ >> GO BUY MINECRAFT JAVA EDITION AND A THINKPAD OR ELSE UR CHEAP AND BROKE

unset DISPLAY

echo "set -g mouse on" > ~/.tmux.conf

tmux kill-session -t server
caddy stop

rm -f web/README.md
cp README.md web/README.md

if [ -f "base.repl" ] && ! { [ "$REPL_OWNER" == "ayunami2000" ] && [ "$REPL_SLUG" == "eaglercraft-old" ]; }; then
  rm base.repl
  rm -rf server/world
  rm -rf server/world_nether
  rm -rf server/world_the_end
  rm -f server/server.log
  rm -f server/server.log.lck
  rm -rf bungee/logs
  rm -f bungee/eaglercraft_skins_cache.db
  rm -f bungee/eaglercraft_auths.db
  rm -f oldgee/proxy.log.0
  rm -f oldgee/proxy.log.0.lck
  sed -i '/^stats: /d' bungee/config.yml
  sed -i "s/^stats: .*\$/stats: $(cat /proc/sys/kernel/random/uuid)/" oldgee/config.yml
  sed -i "s/^server_uuid: .*\$/server_uuid: $(cat /proc/sys/kernel/random/uuid)/" bungee/plugins/EaglercraftXBungee/settings.yml
fi

if [ -f "base.repl" ]; then
  rm -f server/server.log
  rm -f server/server.log.lck
  rm -rf bungee/logs
  rm -f bungee/eaglercraft_skins_cache.db
  rm -f bungee/eaglercraft_auths.db
  rm -f oldgee/proxy.log.0
  rm -f oldgee/proxy.log.0.lck
fi

sed -i "s/^  redirect_legacy_clients_to: .*\$/  redirect_legacy_clients_to: 'wss:\/\/$REPL_SLUG.$REPL_OWNER.repl.co\/old'/" bungee/plugins/EaglercraftXBungee/listeners.yml

caddy start --config ./Caddyfile > /dev/null 2>&1

cd server
tmux new -d -s server "java -Xmx512M -Xms512M -jar server.jar nogui; tmux kill-session -t server"
cd ..

tmux select-pane -T "bukkit" -t server

cd oldgee
tmux splitw -t server -h "java -Xmx32M -Xms32M -jar bungee-dist.jar; tmux kill-session -t server"
cd ..

tmux select-pane -T "1.5 bungee" -t server

cd bungee
tmux splitw -t server -v "java -Xmx128M -Xms128M -jar bungee.jar; tmux kill-session -t server"
cd ..

tmux select-pane -T "1.8 bungee" -t server

tmux select-pane -L -t server

cd viaproxy
rm -rf logs
tmux splitw -t server -v "java -Xmx96M -Xms96M -jar proxy.jar --bind_address localhost --bind_port 25568 --target_ip localhost --target_port 25565 --version 1.5.2; tmux kill-session -t server"
cd ..

tmux select-pane -T "viaproxy" -t server

tmux select-pane -U -t server
tmux resize-pane -D 4
tmux resize-pane -R 4

while tmux has-session -t server
do
  tmux a -t server
done

caddy stop