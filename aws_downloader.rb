#-------------------------------------------------------------------------------------
#
#Aws file list download and file download here
#
#---------------------------------------------------

module RioAwsDownload
	KEY_FILE_LOC ||= 'E:\git\poc_demo\keys.txt'
	
	def self.aws_credentials
		key_contents 	= File.read(KEY_FILE_LOC)
		keys 			= key_contents.split(',')
		aws_credentials = {'access_key_id' => keys[0], 'secret_access_key' => keys[1]}
		aws_credentials
	end
	
	def self.get_client
		creds 		= aws_credentials
		s3_client 	= Aws::S3::Client.new(
						access_key_id: creds['access_key_id'],
						secret_access_key: creds['secret_access_key']
					)
		return s3_client
	end
	
	#-------------------------------------------------------------------
	#Inputs :
	#------------
	#	folder_prefix 	: prefix of the folder_files
	#	bucket_name 	: defaults to test bucket
	#Return :
	#------------
	# 	folders and files in the current folder
	#-------------------------------------------------------------------
	def self.get_folder_files folder_prefix, bucket_name='test.rio.assets' 
		s3_client	= get_client
		bucket_objs = s3_client.list_objects_v2(
					{	bucket: bucket_name, 
						prefix: folder_prefix}
					)
		folder_files 	=[];
		current_files	= []
		if bucket_objs.contents.length > 1
			bucket_objs.contents.each{|x| folder_files << x.key}
			folder_files.each { |name|
				name.slice!(folder_prefix)
				fname = name.split('/')[0]
				current_files << fname unless current_files.include?(fname)
			}
			current_files.reject!{ |e| e.to_s.empty? }.compact! #removes nil and empty strings
		end
		current_files
	end 
	
	#Only for skp....write separate method for other files
	def self.download_skp file_path, bucket_name='test.rio.assets' 
		s3_client	= get_client
		temp_dir 	= ENV['TEMP']
		file_name 	= File.basename(file_path)
		target_path = temp_dir + "\\" + file_name
		begin
			resp 	= s3_client.get_object(bucket: bucket_name, key: file_path, response_target: target_path)
			puts "File download success"
			return target_path
		rescue Aws::S3::Errors::NoSuchKey
			puts "File Does not exist"
			return nil
		end
		return nil
	end
	
end
