variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
}

variable "regions" {
  type    = list(string)
  default = ["nyc1", "sfo3", "ams3"]
}

variable "cluster_names" {
  type    = list(string)
  default = ["hub", "prod", "dev", "internal", "core"]
}

variable "node_count" {
  type    = number
  default = 3
}

variable "node_size" {
  type    = string
  default = "s-2vcpu-4gb"
}

variable "ssh_pub_key" {
  description = "Public SSH key for DigitalOcean"
  type        = string
  sensitive   = true
}

variable "ssh_key_id" {
  description = "Name for the SSH key in DigitalOcean"
  type        = string
}
