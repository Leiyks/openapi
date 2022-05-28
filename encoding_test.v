module openapi

import os

fn test_encoding_struct() ? {
	content := os.read_file(@VMODROOT + '/testdata/encoding.json')?
	encoding := decode<Encoding>(content)?

	assert encoding.content_type == 'image/png, image/jpeg'
	assert encoding.headers.len == 1
	assert encoding.style == 'form'
	assert encoding.explode == true

	header := encoding.headers['X-Rate-Limit-Limit'] as Header
	assert header.description == 'The number of allowed requests in the current period'
}
