import openapi
import os

fn test_operation_struct() ? {
	content := os.read_file(@VMODROOT + '/testdata/operation.json')?
	operation := openapi.decode<openapi.Operation>(content)?

	assert operation.tags.len == 1
	assert operation.summary == 'Updates a pet in the store with form data'
	assert operation.operation_id == 'updatePetWithForm'
	assert operation.parameters.len == 2

	parameter := operation.parameters[0] as openapi.Parameter
	assert parameter.name == 'petId'

	ref := operation.parameters[1] as openapi.Reference
	assert ref.ref == 'Here_is_a_ref'

	assert operation.responses.len == 2
	assert operation.security.len == 1
}
