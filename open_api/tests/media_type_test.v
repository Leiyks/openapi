import open_api
import os

fn test_media_type_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/media_type.json')?
	media_type := open_api.decode<open_api.MediaType>(content)?

	assert media_type.examples.len == 3
	assert 'cat' in media_type.examples
	assert 'dog' in media_type.examples
	assert 'frog' in media_type.examples

	tmp := media_type.examples['frog'] as open_api.Reference
	assert tmp.ref == '#/components/examples/frog-example'
}
