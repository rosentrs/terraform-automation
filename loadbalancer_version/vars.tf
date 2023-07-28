
variable "server_name" {
  default = "server_name"
}
variable "ssh_key_name" {
  default = "ssh_key_name"
}
variable "cloudflare_token" {
  default = "cloudflare_token"
}
variable "cloudflare_zone_id" {
  default = "cloudflare_zone_id"
}
variable "hcloud_token" {
  default = "hcloud_token"
}
variable "cloudflare_api_key" {
  default = "cloudflare_api_key"
}
variable "num_servers" {
  description = "Number of servers to create"
  type        = number
  default     = 3
}