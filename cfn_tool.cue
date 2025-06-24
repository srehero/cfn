package cfn

import (
	"tool/cli"
	"tool/exec"
	"tool/file"
	"github.com/srehero/cfn/config"
)

command: "cfn.deploy": {
	create_tmp_file: exec.Run & {
		cmd: ["bash", "-c", "mktemp | tr -d '\n'"]
		stdout: string
	}

	get_aws_account: exec.Run & {
		cmd: ["bash", "-c", "aws sts get-caller-identity --query 'Account' --output text | tr -d '\n'"]
		stdout: string
	}

	get_aws_region: exec.Run & {
		cmd: ["bash", "-c", "aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]' | tr -d '\n'"]
		stdout: string
	}

	continue_with_aws_credentials: exec.Run & {
		continue: string
		if get_aws_account.stdout != "" {
			continue: "true"
		}
		if get_aws_account.stdout == "" {
			continue: "false"
		}
		cmd: [continue]
		$after: [get_aws_account, get_aws_region]
	}

	continue_with_bucket: exec.Run & {
		command: [...string]
		bucket: config.template_bucket[get_aws_account.stdout][get_aws_region.stdout]
		if bucket != _|_ {
			command: ["bash", "-c", "aws s3api head-bucket --bucket \(bucket)"]
		}
		if bucket == _|_ {
			command: ["true"]
		}
		cmd: command
		stdout: string
		$after: [get_aws_account, get_aws_region]
	}

	ask_for_stack_name: cli.Ask & {
		prompt:   "Stack?"
		response: string
		$after: [continue_with_aws_credentials, continue_with_bucket]
	}

	export_template: exec.Run & {
		cmd: ["bash", "-c", "cue export ./... -e 'stack[\"\(ask_for_stack_name.response)\"]'"]
		stdout: string
		$after: ask_for_stack_name
	}

	export_tags: exec.Run & {
		cmd: ["bash", "-c", "cue export ./... -e 'stack[\"\(ask_for_stack_name.response)\"].Metadata.Tags' 2> /dev/null | jq -r 'to_entries | map([\"\\(.key)=\\(.value)\"]) | flatten | join(\" \")' | tr -d '\n'"]
		stdout: string
		$after: ask_for_stack_name
	}

	write_template: file.Append & {
		filename: create_tmp_file.stdout
		contents: export_template.stdout
		$after: export_template
	}

	read_template: file.Read & {
		filename: create_tmp_file.stdout
		contents: string
		$after:   write_template
	}

	print_template: cli.Print & {
		text: read_template.contents
		$after: read_template
	}

	ask_to_deploy: cli.Ask & {
		prompt:   "Deploy this template? (yes/no)"
		response: bool
		$after:   print_template
	}

	continue_with_deploy: exec.Run & {
		continue: string
		if ask_to_deploy.response {
			continue: "true"
		}
		if !ask_to_deploy.response {
			continue: "false"
		}
		cmd: [continue]
	}

	deploy_stack: exec.Run & {
		bucket: string
		if config.template_bucket[get_aws_account.stdout][get_aws_region.stdout] != _|_ {
			bucket: "--s3-bucket \(config.template_bucket[get_aws_account.stdout][get_aws_region.stdout])"
		}
		if config.template_bucket[get_aws_account.stdout][get_aws_region.stdout] == _|_ {
			bucket: ""
		}

		tags: string
		if export_tags.stdout != "" && export_tags.stdout != _|_ {
			tags: "--tags \(export_tags.stdout)"
		}
		if export_tags.stdout == "" || export_tags.stdout == _|_ {
			tags: ""
		}

		cmd: ["bash", "-c", "aws cloudformation deploy --no-execute-changeset --stack-name \(ask_for_stack_name.response) --template-file \(create_tmp_file.stdout) \(bucket) \(tags) --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM || true"]
		$after: continue_with_deploy
	}
}
