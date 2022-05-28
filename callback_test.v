module openapi

import os

fn test_callback_struct() ? {
	content := os.read_file(@VMODROOT + '/testdata/callback.json')?
	components := decode<Components>(content)?
	callback := components.callbacks['test1'] as Callback

	assert callback.len == 2
	assert callback['some_url'].summary == 'summary1'
	assert callback['other_url'].summary == 'summary2'
}
