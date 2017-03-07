# Editing the Contiv Website

This repo contains the Contiv website source files (Markdown) and build scripts. If you want to make changes to the Contiv website, make changes to the source files under `websrc/source` and follow the instructions below.

## Prerequisites

Fork this repo to your personal account.

Run `cd websrc; make init` to build the development Docker image.  If you don't have Docker, you'll need to install it first.

## Running the Site Locally and Testing Your Changes

Running the site locally is simple: run `cd websrc; make dev` then open up `http://localhost:4567`

When you edit the Markdown source files, your changes will be available immediately.  Reload the page to see them.

## Submitting Changes

Make changes to the Markdown files and test them using the the above instructions.

When you are ready to submit the changes, run `cd websrc; make build`. This generates the static website content which will be hosted by Github Pages. You can now commit all of the changes together (Markdown files and static content) and submit a pull request.

Please ensure that your PR includes both the source and static content changes!

## Directory Structure

The directory structure for the Contiv website follows the typical Middleman project structure. See https://middlemanapp.com for details.

- Top level directory contains the compiled static content for the contiv.github.io website
- `websrc` directory contains the source files used to build the static content

Directory structure:

```
+- websrc: makefile, gemfile, and other build related files
	 +- helpers: helper scripts used for compiling the website
	 +- source: root directory for all html template files. `index.html.erb` is the main html page for the website.
		  +- articles: this folder contains the blog articles
		  +- assets: contains stylesheets, images, and javascript files
		  +- documents: this folder contains all the .md files for documentation
		  +- layouts: contains the template for header, footer, and sidebar elements
```
