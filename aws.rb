require 'aws-sdk'
require 'json'
require 'aws-sdk-ec2'  # v2: require 'aws-sdk'
require 'aws-sdk-rds'

creds = {
	'AccessKeyId' 		=> 'AKIAIZTPJRG2UDP7PQ3Q',
	'SecretAccessKey'	=> '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'
}

Aws::Credentials.new(creds['AccessKeyId'], creds['SecretAccessKey'])
aws_cred = Aws::Credentials.new(creds['AccessKeyId'], creds['SecretAccessKey'])

aws_client = Aws::S3::Client.new(
	access_key_id: creds['access_key_id'],
	secret_access_key: creds['secret_access_key']
)




require 'aws-sdk-ec2'  # v2: require 'aws-sdk'
require 'aws-sdk-rds' 

ec2 = Aws::EC2::Client.new(region: 'us-east-1')

puts "Amazon EC2 region(s) (and their endpoint(s)) that are currently available to you:\n\n"
describe_regions_result = ec2.describe_regions()

describe_regions_result.regions.each do |region|
  puts "#{region.region_name} (#{region.endpoint})"  
end

puts "\nAmazon EC2 availability zone(s) that are available to you for your current region:\n\n"
describe_availability_zones_result = ec2.describe_availability_zones()

describe_availability_zones_result.availability_zones.each do |zone|
  puts "#{zone.zone_name} is #{zone.state}"
  if zone.messages.count > 0
    zone.messages.each do |message|
      "  #{message.message}"
    end
  end
end


s3_client = Aws::S3::Client.new
s3_client.create_bucket(bucket: 'my-new-bucket')

s3_client.create_bucket(Bucket='zxvxdvx.gsdrgerrrczxczxcgggzxczxczxchjghgj',CreateBucketConfiguration={'LocationConstraint': AWS_DEFAULT_REGION}
##<struct Aws::S3::Types::ListBucketsOutput buckets=[#<struct Aws::S3::Types::Bucket name="test.bucket.dp", creation_date=2018-10-31 12:27:09 UTC>], owner=#<struct Aws::S3::Types::Owner display_name=nil, id="66359841fa8729a4d5a88b222ef029dc0619c5eb9b77840c04b7164c2c3cf9f1">>


s3_client = Aws::S3::Client.new(
	access_key_id: creds['access_key_id'],
	secret_access_key: creds['secret_access_key']
)

s3_client.list_buckets

s3_client.list_buckets.buckets.each do |bucket|
        puts "#{bucket.name}\t#{bucket.creation_date}"
end


s3_client.create_bucket(bucket: 'my-new-bucket.dp.vivek', acl: 'private')

s3_client.get_objects(bucket: 'test.bucket.dp').contents.each do |object|
        puts "#{object.key}\t#{object.size}\t#{object.last-modified}"
end




