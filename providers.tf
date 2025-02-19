provider "google" {
  project     = "coc-medimrec-poc"
  region      = "europe-southwest1"
  credentials = file("auth/token.json")
}
