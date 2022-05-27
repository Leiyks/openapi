module openapi

import x.json2 { Any }
import json

pub struct Operation {
pub mut:
	external_docs ExternalDocumentation
	operation_id  string
	request_body  ObjectRef<RequestBody>
	tags          []string
	summary       string
	description   string
	parameters    []ObjectRef<Parameter>
	responses     Responses
	callbacks     map[string]ObjectRef<Callback>
	deprecated    bool
	security      []SecurityRequirement
	servers       []Server
}

pub fn (mut operation Operation) from_json(json Any) ? {
	object := json.as_map()
	check_required<Operation>(object, 'responses')?

	for key, value in json.as_map() {
		match key {
			'externalDocs' {
				operation.external_docs = decode<ExternalDocumentation>(value.json_str())?
			}
			'operationId' {
				operation.operation_id = value.str()
			}
			'requestBody' {
				operation.request_body = from_json<RequestBody>(value)?
			}
			'tags' {
				operation.tags = decode_array_string(value.json_str())?
			}
			'summary' {
				operation.summary = value.str()
			}
			'description' {
				operation.description = value.str()
			}
			'parameters' {
				operation.parameters = decode<[]ObjectRef<Parameter>>(value.json_str())?
			}
			'responses' {
				operation.responses = decode<Responses>(value.json_str())?
			}
			'callbacks' {
				operation.callbacks = decode_map_sumtype<Callback>(value.json_str(), fake_predicat)?
			}
			'deprecated' {
				operation.deprecated = value.bool()
			}
			'security' {
				operation.security = decode_array<SecurityRequirement>(value.json_str())?
			}
			'servers' {
				operation.servers = decode_array<Server>(value.json_str())?
			}
			else {}
		}
	}
	operation.validate(object)?
}

fn (mut operation Operation) validate(object map[string]Any) ? {
	mut checked := map[string]string{}
	for parameter in operation.parameters {
		if parameter is Reference {
			continue
		}
		param := parameter as Parameter
		if param.name in checked && checked[param.name] == param.location {
			return error('Failed Operation decoding: parameter with identical "name" and "in" found.')
		}
		checked[param.name] = param.location
	}
}

pub fn (operation Operation) get_path_parameters() []Parameter {
	mut parameters := []Parameter{}

	for parameter in operation.parameters {
		if parameter is Parameter {
			param := Parameter{
				...parameter
			}
			if param.location == 'path' {
				parameters << param
			}
		}
	}

	return parameters
}

pub fn (operation Operation) get_request_body() RequestBody {
	if operation.request_body is RequestBody {
		return RequestBody{
			...operation.request_body
		}
	}
	return RequestBody{}
}

pub struct ExternalDocumentation {
pub mut:
	description string
	url         string
}

pub fn (mut external_doc ExternalDocumentation) from_json(json Any) ? {
	object := json.as_map()
	check_required<ExternalDocumentation>(object, 'url')?

	for key, value in object {
		match key {
			'description' {
				external_doc.description = value.str()
			}
			'url' {
				external_doc.url = value.str()
			}
			else {}
		}
	}

	if external_doc.url != '' && !check_email_regex(external_doc.url) {
		return error('Failed ExternalDocumentation decoding: "url" do not match url regex expression.')
	}
}
