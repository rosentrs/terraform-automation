terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = ">= 0.13"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}


