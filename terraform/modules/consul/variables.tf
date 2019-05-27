variable "server_count" {
  default     = "2"
  description = "The number of Consul servers to launch."
}

variable image {
  type = "string"
}

variable size {
  type = "string"
}

variable region {
  type = "string"
  default = "lon1"
}

variable "ssh_fingerprint" {}
variable "pvt_key" {}