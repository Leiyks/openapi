import openapi

fn test_header_struct() ? {
	content := '{ "description": "details", "schema": { "type": "integer" } }'
	header := openapi.decode<openapi.Header>(content)?

	assert header.name == ''
	assert header.location == ''
	assert header.description == 'details'
	assert header.required == false
	assert header.style == 'simple'
	assert header.explode == false
}

fn test_header_struct_with_name() ? {
	content := '{ "name": "here", "description": "details", "schema": { "type": "integer" } }'
	header := openapi.decode<openapi.Header>(content) or { return }
	assert false
}

fn test_header_struct_with_in() ? {
	content := '{ "in": "query", "description": "details", "schema": { "type": "integer" } }'
	header := openapi.decode<openapi.Header>(content) or { return }
	assert false
}
