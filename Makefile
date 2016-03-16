OUTPUT_DIR = ./builds

gotty: tty/resource.go main.go tty/*.go rec/*.go
	go build

resource:  tty/resource.go

tty/resource.go: bindata/static/js/hterm.js bindata/static/js/gotty.js  bindata/static/index.html bindata/static/favicon.ico bindata/static/css/bootstrap-theme.min.css bindata/static/css/bootstrap.min.css bindata/static/js/bootstrap.min.js bindata/static/js/jquery-1.12.1.js bindata/static/js/demo.js bindata/static/js/fetch.js 
	go-bindata-assetfs -prefix bindata -pkg tty -ignore=\\.gitkeep -o tty/resource.go bindata/...
	gofmt -w tty/resource.go

bindata:
	mkdir bindata

bindata/static: bindata
	mkdir bindata/static

bindata/static/index.html: bindata/static resources/index.html
	cp resources/index.html bindata/static/index.html

bindata/static/favicon.ico: bindata/static resources/favicon.ico
	cp resources/favicon.ico bindata/static/favicon.ico

bindata/static/js: bindata/static
	mkdir bindata/static/js

bindata/static/css: bindata/static
	mkdir bindata/static/css

bindata/static/js/hterm.js: bindata/static/js libapps/hterm/js/*.js
	cd libapps && \
	LIBDOT_SEARCH_PATH=`pwd` ./libdot/bin/concat.sh -i ./hterm/concat/hterm_all.concat -o ../bindata/static/js/hterm.js

bindata/static/js/gotty.js: bindata/static/js resources/js/gotty.js
	cp resources/js/gotty.js bindata/static/js/gotty.js

bindata/static/js/bootstrap.min.js: bindata/static/js resources/js/bootstrap.min.js
	cp resources/js/bootstrap.min.js bindata/static/js/bootstrap.min.js

bindata/static/js/jquery-1.12.1.js: bindata/static/js resources/js/jquery-1.12.1.js
	cp resources/js/jquery-1.12.1.js bindata/static/js/jquery-1.12.1.js

bindata/static/js/demo.js: bindata/static/js resources/js/demo.js
	cp resources/js/demo.js bindata/static/js/demo.js

bindata/static/js/fetch.js: bindata/static/js resources/js/fetch.js
	cp resources/js/fetch.js bindata/static/js/fetch.js

bindata/static/css/bootstrap-theme.min.css: bindata/static/css resources/css/bootstrap-theme.min.css
	cp resources/css/bootstrap-theme.min.css bindata/static/css/bootstrap-theme.min.css

bindata/static/css/bootstrap.min.css: bindata/static/css resources/css/bootstrap.min.css
	cp resources/css/bootstrap.min.css bindata/static/css/bootstrap.min.css

tools:
	go get github.com/tools/godep
	go get github.com/mitchellh/gox
	go get github.com/tcnksm/ghr
	go get github.com/jteeuwen/go-bindata/...
	go get github.com/elazarl/go-bindata-assetfs/...

deps:
	godep restore

test:
	if [ `go fmt ./... | wc -l` -gt 0 ]; then echo "go fmt error"; exit 1; fi

install:
	install -m 0755 -d /var/log/gotty
	install -m 0755 -d /etc/gotty
	install -m 0755 gotty /usr/sbin/
	install -m 0755 etc/init.d/gotty /etc/init.d/
	install -m 0644 etc/gotty/gotty.conf /etc/gotty
	/usr/sbin/update-rc.d gotty defaults

run:
	./gotty  -logtostderr -v 3 -c ./etc/gotty/gotty.run.conf daemon
