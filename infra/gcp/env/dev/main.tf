resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "terraform-subnetwork"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Allows SSH from anywhere (be cautious with this in production)
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnetwork.self_link
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    ssh-keys = "terraform:${file("~/.ssh/dev_deployer.pub")}"
  }
}

output "vm_instance" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}