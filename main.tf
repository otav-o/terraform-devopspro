terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# copiar da documentação (terraform repository) e editar
resource "digitalocean_droplet" "jenkins" {
  image  = "ubuntu-22-04-x64"
  name   = "jenkins"
  region = var.region
  size   = "s-2vcpu-2gb"
  # observar que este campo foi declarado como data source no bloco seguinte
  ssh_keys = [data.digitalocean_ssh_key.jornada.id]
}
# vincular uma chave existente ao droplet
data "digitalocean_ssh_key" "jornada" {
  name = var.ssh_key_name
}

resource "digitalocean_kubernetes_cluster" "meucluster" {
  name    = "meucluster"
  region  = "nyc1"
  version = "1.25.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

variable "region" {
  default = ""
}

variable "do_token" {
  default = ""
}

variable "ssh_key_name" {
  default = ""
}

output "jenkins_ip" {
  value = digitalocean_droplet.jenkins.ipv4_address
}

# depois é só copiar para o seu kubeconfig local (~/.kube/kube_config) para poder acessar
resource "local_file" "kubeconfig" {
  content  = digitalocean_kubernetes_cluster.meucluster.kube_config.0.raw_config
  filename = "kube_config.yaml"
}