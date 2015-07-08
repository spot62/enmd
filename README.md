 Environment for Nginx modules development
===========================================

###Project directories:
./build   - builded web-server

./etc     - config for web-server

./modules - modules

./script  - bulding script

./vendor  - vendor distribution


###Script using:
./script/nginxdev.sh           - default building

./script/nginxdev.sh distclean - clean workspace

./script/nginxdev.sh download  - nginx package download

./script/nginxdev.sh configure - config nginx package

./script/nginxdev.sh build     - build package

./script/nginxdev.sh clean     - clean package

./script/nginxdev.sh start     - nginx start

./script/nginxdev.sh stop      - nginx stop

./script/nginxdev.sh restart   - nginx restart


###Main work directories:
./etc              - web-server config (default http://localhost:8888)

./nginx/build/html - web-server root

./nginx/build/log  - web-server logs





