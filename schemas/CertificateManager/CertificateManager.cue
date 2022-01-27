package CertificateManager

import (
  "github.com/srehero/cfn-cue/schemas/CloudFormation"
)

#Certificate: CloudFormation.#Resource & {
  Type: "AWS::CertificateManager::Certificate"
}