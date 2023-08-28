resource "github_repository" "new_repo" {
  name = var.repo_name
  description = var.repo_description
  visibility = var.visibility
}