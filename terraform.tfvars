terragrunt = {
  terraform {
    source = "../terraform"

    extra_arguments "requires-vars" {
      commands = [
        "plan",
        "destroy",
      ]

      arguments = [
        "-var",
        "uuid=${get_env("UUID", "7cd948b5-c58c-498a-a934-48040609d7ea")}",
        "-var",
        "env=${get_env("ENV", "training")}",
        "-var",
        "aws_region=${get_env("AWS_REGION", "us-east-1")}",
        "-var",
        "ssh_key=${get_env("SSH_KEY", "")}",
        "-var",
        "ssh_key_pair=${get_env("SSH_KEY_PAIR", "")}",
      ]
    }

    extra_arguments "requires-plan" {
      commands = [
        "plan",
      ]

      arguments = [
        "-out",
        "${get_tfvars_dir()}/plan-${get_env("UUID", "7cd948b5-c58c-498a-a934-48040609d7ea")}-${get_env("ENV", "training")}.out",
      ]
    }

    extra_arguments "apply" {
      commands = [
        "apply",
      ]

      arguments = [
        "${get_tfvars_dir()}/plan-${get_env("UUID", "7cd948b5-c58c-498a-a934-48040609d7ea")}-${get_env("ENV", "training")}.out",
      ]
    }
  }

  remote_state {
    backend = "s3"

    config {
      bucket     = "${get_env("UUID", "7cd948b5-c58c-498a-a934-48040609d7ea")}-terraform-${get_env("ENV", "training")}"
      key        = "${path_relative_to_include()}/terraform.tfstate"
      region     = "${get_env("AWS_REGION", "us-east-1")}"
      encrypt    = true
      lock_table = "${get_env("UUID", "7cd948b5-c58c-498a-a934-48040609d7ea")}-terraform-${get_env("ENV", "training")}"
    }
  }
}
