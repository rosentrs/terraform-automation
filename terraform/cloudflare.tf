# Add a record to the domain
resource "cloudflare_record" "example" {
  zone_id = var.cloudflare_zone_id
  name    = "terraform"
  value   = "192.0.2.1"
  type    = "A"
  #ttl     = 3600
}

# Add a record requiring a data map
resource "cloudflare_record" "_sip_tls" {
  zone_id = var.cloudflare_zone_id
  name    = "_sip._tls"
  type    = "SRV"

  data {
    service  = "_sip"
    proto    = "_tls"
    name     = "terraform-srv"
    priority = 0
    weight   = 0
    port     = 443
    target   = "lab4.cloud"
  }
}
#################################################

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}

provider "cloudflare" {
  api_token = "cloudflare_token"
}

variable "zone_id" {
  default = "7251154421fecc874c3953bb8a0f89a4"
}

variable "account_id" {
  default = "ee1a6e00dd69a9a4e535923601d3f178"
}

variable "domain" {
  default = "lab4.cloud"
}

resource "cloudflare_record" "lab4.cloud" {
  zone_id = var.zone_id
  name    = "lab4.cloud"
  value   = "${hcloud.IPAddress}"
  type    = "A"
  proxied = true
}
