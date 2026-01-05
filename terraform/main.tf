resource "google_integrations_client" "fao_dr" {
  provider = google-beta
  location = "europe-west1"
  project  = var.project_id
}

resource "null_resource" "deploy_integration" {
  depends_on = [google_integrations_client.fao_dr]

  triggers = {
    json_hash = sha256(file("${path.module}/integration.json"))
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy_integration.sh ${var.project_id} europe-west1 send-email-notifications ${path.module}/integration.json"
  }
}
