module openapi

import os

fn test_basic_info_struct() ? {
	content := '{ "title": "random", "version": "1.0.1" }'
	info := decode<Info>(content)?
	assert info.title == 'random'
	assert info.version == '1.0.1'
}

fn test_info_struct_without_required() ? {
	content := '{ "title": "random" }'
	info := decode<Info>(content) or { return }
	assert false
}

fn test_full_info_struct() ? {
	content := os.read_file(@VMODROOT + '/testdata/info.json')?
	info := decode<Info>(content)?
	assert info.title == 'Sample Pet Store App'
	assert info.version == '1.0.1'
	assert info.description == 'This is a sample server for a pet store.'
	assert info.terms_of_service == 'http://example.com/terms/'
	assert info.contact.name == 'API Support'
	assert info.contact.url == 'http://www.example.com/support'
	assert info.contact.email == 'support@example.com'
	assert info.license.name == 'Apache 2.0'
	assert info.license.url == 'https://www.apache.org/licenses/LICENSE-2.0.html'
}
