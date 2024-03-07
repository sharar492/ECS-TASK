variable "cidr_block" {
    type = string
    description = "cidr block range"
    default = "10.0.0.0/16"
}

variable "cidr_for_subnet1" {
    type = string
    description = "cidr for subnet 1 range"
    default = "10.0.0.0/24"
}

variable "cidr_for_subnet2" {
    type = string
    description = "cidr for subnet 2 range"
    default = "10.0.1.0/24"
}
