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
    },
    {
      az   = "us-west-1c",
      cidr = "10.0.5.0/24"
    }
  ]
}
vpc_cidr = "10.0.0.0/16"
use_ngw  = true

dns = {
  default_ttl = 30

  zones = {
    "doorway.housingbayarea.org" = {
      id = "Z07765371R2XJ4P3TZMGA"

      additional_records = []
    }
  }
}

certs = {
  "doorway" = {
    domain = "dev.doorway.housingbayarea.org"
    alt_names = [
      "*.dev.doorway.housingbayarea.org"
    ]
  }
}

albs = {
  public = {
    subnet_group   = "public"
    enable_logging = false

    listeners = {
      "http" = {
        port           = 80
        default_action = "force-tls"
        allowed_ips    = ["0.0.0.0/0"]
      }

      "https" = {
        port        = 443
        allowed_ips = ["0.0.0.0/0"]

        tls = {
          default_cert     = "doorway"
          additional_certs = []
        }
      }
    }
  }
}

database = {
  db_name = "bloom"
  type    = "rds" # rds, aurora-serverless
  #type                     = "aurora-serverless"
  subnet_group             = "data"
  engine_version           = "13.8"
  instance_class           = "db.t3.micro"
  port                     = 5432
  prevent_deletion         = false
  apply_change_immediately = false
  username                 = "doorway"
  #password = "doorway-pass"

  maintenance_window = "Sat:23:00-Sun:04:00"

  storage = {
    min     = 20
    max     = 50
    encrypt = true
  }

  backups = {
    retention = 30
    window    = "00:00-01:00"
  }

  serverless_capacity = {
    min = 0.5
    max = 3.0
  }
}

public_sites = [
  {
    name = "public"
    port = 3000

    task = {
      cpu   = 256
      ram   = 512
      image = "364076391763.dkr.ecr.us-west-1.amazonaws.com/doorway-dev/public:run"

      env_vars = {
        JURISDICTION_NAME = "Bay Area"
        LISTINGS_QUERY    = "/listings"
        LANGUAGES         = "en,es,zh,vi,tl"
        IDLE_TIMEOUT      = 5
        CACHE_REVALIDATE  = 60
      }
    }

    service = {
      subnet_group = "app"

      albs = {
        "public" = {
          listeners = {
            "https" = {
              domains = [
                "dev.doorway.housingbayarea.org"
              ]
            }
          }
        }
      }

      health_check = {
        interval     = 10
        valid_status = ["200", "202"]
        path         = "/"
        protocol     = "HTTP"
        timeout      = 5
      }
    }
  }
]

partner_site = {
  name = "partner"
  port = 3001

  task = {
    cpu   = 256
    ram   = 512
    image = "364076391763.dkr.ecr.us-west-1.amazonaws.com/doorway-dev/partners:run"

    env_vars = {
      LISTINGS_QUERY  = "/listings"
      SHOW_DUPLICATES = "false"
      SHOW_LM_LINKS   = "true"
    }
  }

  service = {
    subnet_group = "app"

    albs = {
      "public" = {
        listeners = {
          "https" = {
            domains = [
              "partners.dev.doorway.housingbayarea.org"
            ]
          }
        }
      }
    }

    health_check = {}
  }
}

backend_api = {
  name = "backend"
  port = 3100

  task = {
    cpu = 256
    # more ram is needed for yarn db:migrations:run
    # can reduce when separate task is avaiable
    ram   = 2048
    image = "364076391763.dkr.ecr.us-west-1.amazonaws.com/doorway-dev/backend:run"

    env_vars = {
      LISTINGS_QUERY  = "/listings"
      SHOW_DUPLICATES = "false"
      SHOW_LM_LINKS   = "true"
    }
  }

  service = {
    subnet_group = "app"

    albs = {
      "public" = {
        listeners = {
          "https" = {
            domains = [
              "backend.dev.doorway.housingbayarea.org"
            ]
          }
        }
      }
    }

    health_check = {
      interval     = 30
      valid_status = ["200", "202"]
      path         = "/jurisdictions"
      protocol     = "HTTP"
      timeout      = 5
    }
  }
}
