package Route53

import (
  "github.com/srehero/cfn-cue/CloudFormation"
)

#HostedZone: CloudFormation.#Resource & {
  Type: "AWS::Route53::HostedZone"
}