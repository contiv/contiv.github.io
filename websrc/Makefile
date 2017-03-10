all: build

init:
	@bash ./scripts/init.sh

# dev launches the live-reloading development server on port 4567
dev: init
	@bash ./scripts/dev.sh

clean:
	rm -rf ../documents
	rm -rf ../assets
	rm -rf ../articles
	rm -rf ../extras
	rm -f ../404.html
	rm -f ../index.html
	rm -f ../robots.txt
	rm -f ../sitemap.xml
	rm -f ../favicon*

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
	touch "../documents/DO NOT EDIT THE HTML OR OTHER OUTPUT DIRECTLY. ALWAYS EDIT FROM THE SOURCE DIRECTORY." 

build: clean init
	@bash ./scripts/build.sh
