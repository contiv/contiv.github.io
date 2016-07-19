all: build

init:
	bundle

dev: init
	bundle exec middleman server

clean:
	rm -rf ../documents
	rm -rf ../assets
	rm -rf ../articles
	rm -rf ../extras
	rm ../404.html || true
	rm ../index.html || true
	rm ../robots.txt || true
	rm ../sitemap.xml || true
	rm ../favicon* || true

deploy:
	mv ./build/documents ../
	mv ./build/assets ../
	mv ./build/articles ../
	mv ./build/extras ../
	mv ./build/index.html ../
	mv ./build/favicon* ../
	mv ./build/404.html ../
	mv ./build/robots.txt ../
	mv ./build/sitemap.xml ../

build: init clean
	bundle exec middleman build
	make deploy
