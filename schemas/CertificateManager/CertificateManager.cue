package CertificateManager

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#Certificate: CloudFormation.#Resource & {
	Type: "AWS::CertificateManager::Certificate"
}
