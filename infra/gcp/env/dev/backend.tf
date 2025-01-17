terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  credentials = file("./credentials.json")
  region      = "europe-west6"
  zone        = "europe-west6-b"
  project     = "terrafrom-gcp-444314"
}