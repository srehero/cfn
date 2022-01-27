package ApiGatewayV2

import (
  "github.com/srehero/cfn-cue/schemas/CloudFormation"
)

#DomainName: CloudFormation.#Resource & {
  Type: "AWS::ApiGatewayV2::DomainName"
}