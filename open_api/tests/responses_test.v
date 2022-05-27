import open_api
import os

fn test_responses_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/responses.json')?
	responses := open_api.decode<open_api.Responses>(content)?

	assert responses.len == 2

	mut response := responses['200'] as open_api.Response
	assert response.description == 'a pet to be returned'
	assert 'application/json' in response.content

	response = responses['default'] as open_api.Response
	assert response.description == 'Unexpected error'
	assert 'application/json' in response.content
}
