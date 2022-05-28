module openapi

import os

fn test_responses_struct() ? {
	content := os.read_file(@VMODROOT + '/testdata/responses.json')?
	responses := decode<Responses>(content)?

	assert responses.len == 2

	mut response := responses['200'] as Response
	assert response.description == 'a pet to be returned'
	assert 'application/json' in response.content

	response = responses['default'] as Response
	assert response.description == 'Unexpected error'
	assert 'application/json' in response.content
}
