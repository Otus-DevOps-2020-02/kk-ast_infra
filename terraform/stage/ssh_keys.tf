resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "kkostenko:${file(var.public_key_path)}appuser1:${file(var.public_key_path)}"
}
