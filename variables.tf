variable "apikey" {
  sensitive = true
}

variable "type" {
  default = "cx11"
}

variable "image" {
  default = "debian-11"
}

variable "datacenter" {
  default = "nbg1-dc3"
}
