Rails.application.routes.draw do
  comfy_route :cms_admin, path: "/admin"
  # Ensure that this route is defined last
  comfy_route :cms, path: "/"
  comfy_route :blog_admin, path: "/admin"
  comfy_route :blog, path: "/blog"
end
