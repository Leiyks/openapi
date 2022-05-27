import open_api
import os

fn test_encoding_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/encoding.json')?
	encoding := open_api.decode<open_api.Encoding>(content)?

	assert encoding.content_type == 'image/png, image/jpeg'
	assert encoding.headers.len == 1
	assert encoding.style == 'form'
	assert encoding.explode == true

	header := encoding.headers['X-Rate-Limit-Limit'] as open_api.Header
	assert header.description == 'The number of allowed requests in the current period'
}
