all: build

init:
	bundle

dev: init
	bundle exec middleman server

clean:
	rm -rf ../docs
	rm -rf ../install
	rm -rf ../assets
	rm ../404.html || true
	rm ../index.html || true
	rm ../robots.txt || true
	rm ../sitemap.xml || true

deploy:
	mv ./build/docs ../
	mv ./build/install ../
	mv ./build/assets ../
	mv ./build/index.html ../
	mv ./build/404.html ../
	mv ./build/robots.txt ../
	mv ./build/sitemap.xml ../

build: init clean
	bundle exec middleman build
	make deploy
