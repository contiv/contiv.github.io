set :base_url, "http://contiv.io/"

activate :hashicorp do |h|
  h.name        = "contiv"
  h.version     = "0.2.0"
  h.github_slug = "contiv/netplugin"
end
