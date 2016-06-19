set :base_url, "http://contiv.io/"
activate :livereload, livereload_css_target: 'stylesheets/application-799c3eac.css'

activate :hashicorp do |h|
  h.name        = "contiv"
  h.version     = "0.2.0"
  h.github_slug = "contiv/netplugin"
end

activate :blog do |blog|
  # set options on blog
  blog.prefix = "articles"
  blog.default_extension = ".md"
  blog.layout = "article"
end

# activate :deploy do |deploy|
#   deploy.deploy_method = :git
#   # Optional Settings
#   deploy.remote = https://github.com/pyhung99/contiv2.git
#   # remote name or git url, default: origin
#   # deploy.branch   = 'custom-branch' # default: gh-pages
#   # deploy.strategy = :submodule      # commit strategy: can be :force_push or :submodule, default: :force_push
#   # deploy.commit_message = 'custom-message'      # commit message (can be empty), default: Automated commit at `timestamp` by middleman-deploy `version`
#   deploy.build_before = true # default: false
# end