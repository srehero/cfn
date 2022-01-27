package CertificateManager

import (
  "github.com/srehero/cfn-cue/CloudFormation"
)

#Certificate: CloudFormation.#Resource & {
  Type: "AWS::CertificateManager::Certificate"
}