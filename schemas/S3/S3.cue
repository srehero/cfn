package S3

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#AccessPoint: CloudFormation.#Resource & {
	Type: "AWS::S3::AccessPoint"
}

#Bucket: CloudFormation.#Resource & {
	Type: "AWS::S3::Bucket"
}

#BucketPolicy: CloudFormation.#Resource & {
	Type: "AWS::S3::BucketPolicy"
}

#MultiRegionAccessPoint: CloudFormation.#Resource & {
	Type: "AWS::S3::MultiRegionAccessPoint"
}

#MultiRegionAccessPointPolicy: CloudFormation.#Resource & {
	Type: "AWS::S3::MultiRegionAccessPointPolicy"
}

#StorageLens: CloudFormation.#Resource & {
	Type: "AWS::S3::StorageLens"
}
