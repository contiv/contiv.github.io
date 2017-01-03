Editing the Contiv Website

This repo contains the Contiv website source files and build scripts. If you want to make changes to the Contiv public website, make changes to the source files here and follow the instructions below.

Note: The following intstructions were tested on Mac OSX. If you are using a Windows environment, you will have to make adjustments.

## Prerequisits

- Ruby 2.2.0 or higher. Ruby comes preinstalled with OSX. If you have Xcode installed on your Mac, you can install Ruby using "xcode-select --install" command if it isn't there already.
- Bundler 1.11 or higher ("sudo gem install bundler")
- Middleman 3.4 or higher ("sudo gem install middleman")


## Running the Site Locally

Running the site locally is simple. Clone this repo and run `cd websrc; make dev`.

Then open up `http://localhost:4567`.


## Submitting Changes
Make the changes locally on your machine and test it using above instructions.
When you are ready to submit the changes run `cd websrc; make build`. This will build a static website and copy the files to correct locations. After this, you can commit the code and submit a pull request.

## Directory Structure

Directory structure for the Contiv website follows the typical middleman project structure. See https://middlemanapp.com for details.

- Top level directory contains the compiled static HTML webpages for contiv.github.io website
- `websrc` directory contains the source files used to build the static HTML website

Directory structure:

```
+- websrc: makefile, gemfile and other build related files
	 +- helpers: helpers scripts used for compiling the website
	 +- source: root directory for all html template files. `index.html.erb` is the main html page for the website.
	  	  +- documents: this folder contains all the .md files for documentation
		  +- articles: this folder contains the blog articles
		  +- assets: contains stylesheets, images and javascript files
		  +- layouts: contains the template for header, footer and sidebar elements
```
