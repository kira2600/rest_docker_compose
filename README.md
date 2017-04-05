# rest_docker_compose
ruby + sinatra

rackup ./config.ru -p 2222 -o 0.0.0.0

curl -H 'Content-Type: application/json' -X POST -d  '{"gateway":"10.10.11.17"}' 192.168.122.202:2222/api/compose/config/change/

curl -H 'Content-Type: application/json' -X POST -d "create" http://192.168.122.202:2222/api/compose/config/create/

curl -X DELETE 192.168.122.202:2222/api/compose/config/remove/

curl -H 'Content-Type: application/json' -X POST -d  "down" 192.168.122.202:2222/api/compose/down/

curl -H 'Content-Type: application/json' -X POST -d  "up" 192.168.122.202:2222/api/compose/up/

curl  http://192.168.122.202:2222/api/docker/version/
