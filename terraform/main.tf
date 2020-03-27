terraform {
  # Версия terraform
  required_version = "0.12.24"
}
provider "google" {
  version = "2.15"
  project = var.project
  region  = var.region
}
resource "google_compute_project_metadata_item" "ssh-keys" {
  key = "ssh-keys"
  value = "kkostenko:${file(var.public_key_path)}appuser1:${file(var.public_key_path)}"
}
resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "f1-micro"
  zone         = "europe-west1-b"
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    # путь до публичного ключа
    ssh-keys = "kkostenko:${file(var.public_key_path)}"
  }
  allow_stopping_for_update = true
  connection {
    type  = "ssh"
    host  = self.network_interface[0].access_config[0].nat_ip
    user  = "kkostenko"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }
  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }
  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}
resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}
