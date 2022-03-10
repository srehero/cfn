package S3

#SecureBucket: {
	AccessControl: "Private"
	BucketEncryption: {
		ServerSideEncryptionConfiguration: [{
			ServerSideEncryptionByDefault: SSEAlgorithm: "AES256"
		}]
	}
	PublicAccessBlockConfiguration: {
		BlockPublicAcls: "TRUE"
		BlockPublicPolicy: "TRUE"
		IgnorePublicAcls: "TRUE"
		RestrictPublicBuckets: "TRUE"
	}
}
