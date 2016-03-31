# Contiv Website

This repo contains the source of contiv website

## Prerequisits
Note: Currently, this works only on OsX(Mac)

- Ruby 2.0 or higher. Ruby comes preinstalled in OsX. you can install it using ""xcode-select --install" command if it doesnt) 
- Bundler 1.11 or higher ("sudo gem install bundler")
- Middleman 3.4 or higher ("sudo gem install middleman")


## Running the Site Locally

Running the site locally is simple. Clone this repo and run `cd websrc; make dev`.

Then open up `http://localhost:4567`.


## Submitting changes
Make the changes locally on your machine and test it using above instructions.
When you are ready to submit the changes run `cd websrc; make build`. This will build a static website and copy the files to correct location. After this, you can commit the code and submit pull request
