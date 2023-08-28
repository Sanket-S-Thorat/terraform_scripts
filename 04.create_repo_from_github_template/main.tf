
# Configuration options
resource "github_repository" "repo" {
  name        = var.repo_name
  description = var.repo_description
  visibility  = var.visibility
  template {
    owner                = var.owner
    repository           = var.template_name
    include_all_branches = true
  }
}

resource "github_branch_default" "main" {
  repository = var.repo_name
  branch     = "main"
}

resource "github_branch_protection" "default" {
  repository_id                   = github_repository.repo.id
  pattern                         = github_branch_default.main.branch
  require_conversation_resolution = true
  enforce_admins                  = true

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}
