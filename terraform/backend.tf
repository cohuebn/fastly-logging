terraform {
  backend "remote" {
    workspaces {
      name = "fastly-logging"
    }
  }
}
