project_name     = "Doorway Housing Project"
application_name = "Bloom Housing Instance"
name_prefix      = "doorway"
team_name        = "doorway"
aws_region       = "us-west-1"
sdlc_stage       = "dev"
subnet_map = {
  "public" = [
    {
      az   = "us-west-1a",
      cidr = "10.0.0.0/24"
    },
    {
      az   = "us-west-1c",
      cidr = "10.0.1.0/24"
    }
  ]
  "app" = [
    {
      az   = "us-west-1a",
      cidr = "10.0.2.0/24"
    },
    {
      az   = "us-west-1c",
      cidr = "10.0.3.0/24"
    }
  ]
  "data" = [
    {
      az   = "us-west-1a",
      cidr = "10.0.4.0/24"
    }
  ]
}
vpc_cidr = "10.0.0.0/16"
use_ngw  = true

public_sites = [
  {
    name    = "public"
    cpu     = 256
    ram     = 512
    image   = "nginx:latest"
    port    = 80
    domains = ["dev.doorway.housingbayarea.org"]

    health_check = {
      interval     = 10
      valid_status = ["200", "202"]
      path         = "/"
      protocol     = "HTTP"
      timeout      = 5
    }

    env_vars = {
      LISTINGS_QUERY   = "/listings"
      LANGUAGES        = "en,es,zh,vi,tl"
      IDLE_TIMEOUT     = 5
      CACHE_REVALIDATE = 60

      # Not sure if needed
      NODE_ENV = "development"
    }
  }
]

partner_site = {
  name    = "partner"
  cpu     = 256
  ram     = 512
  image   = "nginx:latest"
  port    = 80
  domains = ["partners.dev.doorway.housingbayarea.org"]

  health_check = {}

  env_vars = {
    LISTINGS_QUERY  = "/listings"
    SHOW_DUPLICATES = "false"
    SHOW_LM_LINKS   = "true"

    # Not sure if needed
    NODE_ENV = "development"
  }
}

backend_service = {
  image   = "nginx:latest"
  port    = 3100
  domains = ["api.dev.doorway.housingbayarea.org"]

  env_vars = {
    NODE_ENV       = "development"
    LISTINGS_QUERY = "/listings"
    THROTTLE_TTL   = 60
    THROTTLE_LIMIT = 2

    # Not sure if needed
    NODE_ENV = "development"
  }
}
