terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }
}

outbound_access = false
