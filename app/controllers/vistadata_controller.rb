class VistadataController < ApplicationController
	require 'net/http'
	require 'uri'
	require 'json'
	# require 'barby'
	# require 'barby/barcode/code_128'	
	# require 'barby/outputter/ascii_outputter'
	# require 'barby/outputter/html_outputter'
	# require 'bunny'
	skip_before_filter :verify_authenticity_token, :only => [:query_vista_data, :query_from_mobil]
	def index
		if params.has_key?(:submitQueryForVista)
			firstName||= params[:firstName]
			lastName||= params[:lastName]
			monthOfBirth||= params[:monthOfBirth]
			dayOfBirth||= params[:dayOfBirth]
			yearOfBirth||= params[:yearOfBirth]
			sex||= params[:sex]


			# connect with vista server
			url||= URI.parse("http://10.0.80.173:8080/CacheWebAPI/WebAPI?name=#{lastName},#{firstName}")
			url_image||=URI.parse("http://10.0.80.173:8080/CacheWebAPI/WebAPI?action=radiology")
			req = Net::HTTP::Get.new(url.to_s)
			req_image = Net::HTTP::Get.new(url_image.to_s)			
			res = Net::HTTP.start(url.host, url.port) {|http|
			  http.request(req)
			}
			res_image = Net::HTTP.start(url_image.host, url_image.port) {|http|
			  http.request(req_image)
			}


			# remove HL7 key when sending to tao
			@result= JSON.parse(res.body)[0]
			@result_image = JSON.parse(res_image.body)[0]["STREAM"]
			@result_image= @result_image.delete("\n")
			
			@array_image = []
			array_stringImage = JSON.parse(res_image.body)
			for image in array_stringImage
				formatImage = image["STREAM"].delete("\n")
				@array_image.append(formatImage)
			end
			unless @result.nil?
				@HL7Result||= JSON.generate([ @result["NAME"]
											  .split(',')
											  .map(&:strip)
											  .push(@result["AGE"])
											  .push("<form method='post' action='/queryvista' class='button_to'><div><input type='hidden' name='queryData' value='"+JSON.generate(@result)+"'><input class='button tiny radius success' name='viewDetails' value='View Details' type='submit' /></div></form>")
											  .push("<a href='#'' data-reveal-id='firstModal' class='radius tiny  button'>View Pic</a>")	
											  .push("<select name='dataSourceFrom' id='dataSourceFrom'><option value=Astronaut VistA>Astronaut VistA</option><option value=WorldVistA>WorldVistA</option><option value='OpenVistA'>OpenVistA</option><option value='Osehra-Vista'>Osehra-Vista</option><option value=vxVistA>vxVistA</option><option value=Mckesson>Mckesson</option><option value=Cerner>Cerner</option><option value=Siemens>Siemens</option><option value=Allscripts>Allscripts</option><option value=Epic>Epic</option></select>")
											  .push("<select name='dataSourceTo' id='dataSourceTo' ><option value=Mckesson>Mckesson</option><option value=Cerner>Cerner</option><option value=Siemens>Siemens</option><option value=Allscripts>Allscripts</option><option value=Epic>Epic</option><option value=Astronaut VistA>Astronaut VistA</option><option value=WorldVistA>WorldVistA</option><option value='OpenVistA'>OpenVistA</option><option value='Osehra-Vista'>Osehra-Vista</option><option value=vxVistA>vxVistA</option><</select>")
											  .push("<input type='hidden' name='queryData' id='insertQueryDetail' value='"+JSON.generate(@result)+"'><button class='button tiny radius success' data-reveal-id='secondModal' id='insertDetails' onClick='FaSong();' >Insert</button>")
											])
			else
				@HL7Result||= JSON.generate([["<form method='post' action='/queryvista' class='button_to'><div><input type='hidden' name='queryData' value='"+JSON.generate(ien)+"'><input class='button tiny radius success' name='viewDetails' value='View Details' type='submit' /></div></form>"]])
			end
			respond_to do |format|
		    	format.html
		      	format.js { render :HL7Result => @HL7Result }
		      	format.json { render :json => {:name => "David"}.to_json }
		    end
		end
	end

	def query_vista_data
		if params.has_key?(:viewDetails)
			@result = JSON.parse(params[:queryData])			
			@HL7Result = @result["HL7"][0]
			respond_to do |format|
		      format.html
		      format.js
		    end 
		elsif params.has_key?(:insertDetails)
			@result = JSON.parse(params[:queryData])
			@result.delete("HL7")
			@resultArray = JSON.generate([@result])			
			uri = URI.parse('http://10.0.80.172:8080/CacheWebAPI/WebAPI')
			http = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Post.new(uri.request_uri)
			request.body = @resultArray
			request["Content-Type"] = "application/post"
			postData = http.request(request)
			puts postData.body
			render html: postData.body
		end		
	end

	def query_from_mobil
		if params.has_key?(:submitQueryForVista) and params.has_key?(:ien)
			ien= params[:ien]
			# byebug
			# connect with the vista server
			url||= URI.parse("http://10.0.80.173:8080/CacheWebAPI/WebAPI?ien=#{ien}")
			# url_image||=URI.parse("http://10.0.80.173:8080/CacheWebAPI/WebAPI?action=radiology")
			req = Net::HTTP::Get.new(url.to_s)
			# req_image = Net::HTTP::Get.new(url_image.to_s)			
			res = Net::HTTP.start(url.host, url.port) {|http|
			  http.request(req)
			}
			# res_image = Net::HTTP.start(url_image.host, url_image.port) {|http|
			#   http.request(req_image)
			# }


			# remove HL7 key when sending to tao
			@result= JSON.parse(res.body)[0]
			# @result_image = JSON.parse(res_image.body)[0]["STREAM"]
			# @result_image= @result_image.delete("\n")

			# @array_image = []
			# array_stringImage = JSON.parse(res_image.body)
			# for image in array_stringImage
			# 	formatImage = image["STREAM"].delete("\n")
			# 	@array_image.append(formatImage)
			# end
			# gon.array_image = @array_image

			
			unless @result.nil?
				@HL7Result||= JSON.generate([ @result["NAME"]
											  .split(',')
											  .map(&:strip)
											  .push(@result["AGE"])
											  .push("<form method='post' action='/queryvista' class='button_to'><div><input type='hidden' name='queryData' value='"+JSON.generate(@result)+"'><input class='button tiny radius success' name='viewDetails' value='View Details' type='submit' /></div></form>")
											  .push("<a href='#'' data-reveal-id='firstModal' class='radius tiny  button'>View Pic</a>")	
											  .push("<select name='dataSourceFrom' id='dataSourceFrom'><option value=Astronaut VistA>Astronaut VistA</option><option value=WorldVistA>WorldVistA</option><option value='OpenVistA'>OpenVistA</option><option value='Osehra-Vista'>Osehra-Vista</option><option value=vxVistA>vxVistA</option></select>")
											  .push("<select name='dataSourceTo' id='dataSourceTo' ><option value=Mckesson>Mckesson</option><option value=Cerner>Cerner</option><option value=Siemens>Siemens</option><option value=Allscripts>Allscripts</option><option value=Epic>Epic</option></select>")
											  .push("<input type='hidden' name='queryData' id='insertQueryDetail' value='"+JSON.generate(@result)+"'><button class='button tiny radius success' id='insertDetails' onClick='FaSong();' >Insert</button>")
											])
				gon.HL7Result = @HL7Result
			else
				@HL7Result||= JSON.generate([["<form method='post' action='/queryvista' class='button_to'><div class='row'><fieldset><legend>No Record In the Database Create New One</legend><div class='small-8 colums' ><input type='hidden' name='queryData' value='1'><div class='row'><div class='small-3 columns'><label for='right-label' class='right inline'>First Name</label></div><div class='small-9 columns'><input type='text' id='right-label' name='NewRecordFName' placeholder='First Name'></div></div><div class='row'><div class='small-3 columns'><label for='right-label' class='right inline'>Last Name</label></div><div class='small-9 columns'><input type='text' id='right-label' name='NewRecordLName' placeholder='Last Name'></div></div><div class='row'><input class='small-offset-3 small-9 colums button tiny radius success' name='Create New' value='View Details' type='submit' /></div></div></fieldset></div></form>"]])
			end
			respond_to do |format|
		      	format.json { render :json => @HL7Result }
		      	# render :json => {:HL7Result => @HL7Result}.to_json

		    end
		end
	end
end
