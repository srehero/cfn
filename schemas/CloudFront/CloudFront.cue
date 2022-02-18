package CloudFront

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#CachePolicy: CloudFormation.#Resource & {
	Type: "AWS::CloudFront::CachePolicy"
}

#CloudFrontOriginAccessIdentity: CloudFormation.#Resource & {
	Type: "AWS::CloudFront::CloudFrontOriginAccessIdentity"
}

#Distribution: CloudFormation.#Resource & {
	Type: "AWS::CloudFront::Distribution"
}

#Function: CloudFormation.#Resource & {
	Type: "AWS::CloudFront::Function"
}

#KeyGroup: CloudFormation.#Resource & {
	Type: "AWS::CloudFront::KeyGroup"
}

#OriginRequestPolicy: CloudFormation.#Resource & {
	Type: "AWS::CloudFront::OriginRequestPolicy"
}

#PublicKey: CloudFormation.#Resource & {
	Type: "AWS::CloudFront::PublicKey"
}

#RealtimeLogConfig: CloudFormation.#Resource & {
	Type: "AWS::CloudFront::RealtimeLogConfig"
}

#ResponseHeadersPolicy: CloudFormation.#Resource & {
	Type: "AWS::CloudFront::ResponseHeadersPolicy"
}

#StreamingDistribution: CloudFormation.#Resource & {
	Type: "AWS::CloudFront::StreamingDistribution"
}
