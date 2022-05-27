import open_api
import os

fn test_operation_struct() ? {
	content := os.read_file(@VMODROOT + '/open_api/testdata/operation.json')?
	operation := open_api.decode<open_api.Operation>(content)?

	assert operation.tags.len == 1
	assert operation.summary == 'Updates a pet in the store with form data'
	assert operation.operation_id == 'updatePetWithForm'
	assert operation.parameters.len == 2

	parameter := operation.parameters[0] as open_api.Parameter
	assert parameter.name == 'petId'

	ref := operation.parameters[1] as open_api.Reference
	assert ref.ref == 'Here_is_a_ref'

	assert operation.responses.len == 2
	assert operation.security.len == 1
}
