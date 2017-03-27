extends Node

#Go to requestb.in and create a session to test
#If the adress is http://requestb.in/1cjj8ax1, put "1cjj8ax1" bellow
const request_page = "/1cjj8ax1"

var HTTP = HTTPClient.new()

func connect_to_server():
	var socket_address = HTTP.connect("requestb.in",80)
	assert(socket_address==OK)
	
	while(HTTP.get_status() == HTTPClient.STATUS_CONNECTING or HTTP.get_status() == HTTPClient.STATUS_RESOLVING):
		HTTP.poll()
		print("Connecting...")
		OS.delay_msec(500)
		
	assert(HTTP.get_status() == HTTPClient.STATUS_CONNECTED)
	print("Conection Result: ", status_as_string(HTTP.get_status()))

	
func send_test_POST(POST_body):
	#It doesn't work!
	#var Content_Length = var2bytes(POST_body).size()
	#It Works!
	var Content_Length = 222 #Limit for this body?
	
	var POST_headers = ["Content-Type: application/json", 
						"Content-Length: " + str(Content_Length)]
						
	var POST_request = HTTP.request_raw(HTTPClient.METHOD_POST, request_page, POST_headers, POST_body)
	assert(POST_request == OK)
	
	while(HTTP.get_status() == HTTPClient.STATUS_REQUESTING):
		HTTP.poll()
		print("Requesting...")
		OS.delay_msec(300)
	
	#Error happens here when Content_Length > 222 for this fake_data
	assert(HTTP.get_status() == HTTPClient.STATUS_BODY or HTTP.get_status() == HTTPClient.STATUS_CONNECTED)
	
	#SERVER RESPONSE IF SUCCESS
	if (HTTP.has_response()):
		print("\n\nPOST requesting: SUCCESS!")
		var headers = HTTP.get_response_headers_as_dictionary()
		var response_code = HTTP.get_response_code()
		print("\nResponse Code: ", response_code)
		print("Response Headers:\n", headers)
		
		if (HTTP.is_response_chunked()):
			print("\nResponse is Chunked!")
		else:
			var body_lengthl = HTTP.get_response_body_length()
			print("\nResponse Length: ", body_lengthl)
			
		var read_buffer = RawArray()

		while(HTTP.get_status()==HTTPClient.STATUS_BODY):
			HTTP.poll()
			var chunk = HTTP.read_response_body_chunk()
			if (chunk.size()==0):
				OS.delay_usec(1000)
			else:
				read_buffer = read_buffer + chunk
		print("Bytes Got: ", read_buffer.size())
	else:
		print("\n\nPOST requesting: FAILED!")
	
#DATA TO SEND
func get_mock_data():
	var fake_data = {
		"fake_data": 
		[
		{
			"something": "purchase",
			"session": {
				"time": "2010-07-09T03:19:20.041Z",
				"id": "12345678910"
			},
			"otherTime": "2014-07-09T03:17:42.772Z",
			"attributes": {
				"_item_total_price": "$1000.99",
				"_product_id":"9876543210"
			}
		}
		]
	}
	return(fake_data.to_json().to_utf8())
	
#JUST TO BE MORE INFORMATIVE
func status_as_string(k):
	if k == 0:
		return "STATUS_DISCONNECTED"
	elif k == 1:
		return "STATUS_RESOLVING"
	elif k == 2:
		return "STATUS_CANT_RESOLVE"
	elif k == 3:
		return "STATUS_CONNECTING"
	elif k == 4:
		return "STATUS_CANT_CONNECT"
	elif k == 5:
		return "STATUS_CONNECTED"
	elif k == 6:
		return "STATUS_REQUESTING"
	elif k == 7:
		return "STATUS_BODY"
	elif k == 8:
		return "STATUS_CONNECTION_ERROR"
	elif k == 9:
		return "STATUS_SSL_HANDSHAKE_ERROR"
	else:
		return "UNHANDLED ERROR"
