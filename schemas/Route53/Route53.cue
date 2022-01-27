package Route53

import (
  "github.com/srehero/cfn-cue/schemas/CloudFormation"
)

#HostedZone: CloudFormation.#Resource & {
  Type: "AWS::Route53::HostedZone"
}