# Contiv Website

URL: http://contiv.github.io

This repo contains the Contiv website source files (Markdown) and build scripts. If you want to make changes to the Contiv website, make changes to the source files under `websrc/source` and follow the instructions below.

# Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

# Directory Structure

The directory structure for this repo follows the typical Middleman project structure. See https://middlemanapp.com for details.

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
